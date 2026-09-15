# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Declare collega un nome Basic a un export di una DLL nativa Windows x64. Il sottoinsieme descritto funziona nel client compilato senza generare codice durante l’esecuzione; non include tutta l’interoperabilità VB.NET.

## Sintassi esatta

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Parametri

- `name / Public / Private` — Nome locale senza distinzione tra maiuscole e minuscole, chiamato senza UO. Dichiarazione a livello di file o Module, senza corpo e senza End Function/End Sub. Public predefinito; Private dentro Module. Non può sostituire comandi Basic/UO integrati: scegliere un altro nome con Alias.
- `Lib / library.dll` — Nome o percorso .dll obbligatorio. I nomi di sistema semplici vengono cercati prima in System32; gli altri percorsi relativi partono dal file della dichiarazione, anche Include. Ammessi percorsi assoluti. Directory corrente e PATH non vengono cercati. Le dipendenze possono trovarsi accanto alla DLL o in System32.
- `Alias / export` — Nome export esatto e sensibile alle maiuscole, facoltativo; altrimenti nome locale semplice. Ordinali non supportati. Deve essere una funzione nativa Windows x64 con firma identica, non un metodo .NET gestito.
- `Ansi / Unicode / Auto` — Ansi predefinito copia nella codifica ANSI Windows, con possibile perdita di caratteri non rappresentabili. Unicode usa UTF-16. Entrambi cercano il nome esatto. Auto usa UTF-16, prova il nome esatto e poi aggiunge W. Non rileva la vera codifica dell’export: preferire Unicode con export W esplicito.
- `ByVal arg As Type` — Da zero a quattro parametri con ByVal e As Integer, Double, Boolean o String espliciti. Integer: 32 bit con segno; Double: 64 bit; Boolean: BOOL Windows a 32 bit, non bool C/C++. String è una copia temporanea di sola lettura terminata da NUL, massimo 1048576 unità UTF-16 senza NUL interno. La DLL non deve conservare il puntatore né scrivere nel buffer. Argomenti nominati tramite nomi locali. Non supportati ByRef, Optional, ParamArray, array, strutture e puntatori.
- `As ResultType / Sub` — Function richiede As Integer, Double o Boolean. Sub non ha As e produce Unit. Gli argomenti Integer/Boolean devono già essere Integer; Double accetta anche Integer. Usare CInt/CDbl/CStr esplicitamente se necessario. Stringhe, puntatori e interi a 64 bit restituiti richiedono un adattatore nativo con firma supportata.

## Restituisce

Integer restituisce un numero a 32 bit con segno, il cui significato dipende dalla funzione nativa. Double restituisce un valore a virgola mobile a 64 bit. As Boolean normalizza zero in 0/False e ogni altro BOOL in 1/True: per questi flag 1/0 e True/False sono equivalenti nei confronti. Sub non restituisce valori (Unit). Esempi: 1, "3:8", "missing export:1".

## Comportamento

- Dichiarazioni non supportate vengono rifiutate prima dell’esecuzione con SC031. Limiti: 256 dichiarazioni e 64 librerie caricate per script principale. Analisi e completamento non caricano DLL. La vera firma nativa non è ricavabile: dichiarazioni errate possono bloccare il client.
- La prima chiamata carica la DLL; quelle successive riutilizzano libreria e indirizzo. Gli argomenti si valutano una volta nell’ordine sorgente e poi si ordinano per nome. Try/Catch intercetta errori di caricamento, architettura, export e conversione; le violazioni della memoria nativa non sono normali errori recuperabili.
- Le stringhe temporanee si liberano dopo ogni chiamata, anche in caso di errore di conversione. Le librerie si liberano al termine, errore o annullamento dello script principale. Chiudere soltanto l’IDE mantiene attivi script e librerie.
- Chiamate sincrone nel worker dello script. Pausa e arresto vengono verificati prima e dopo; una DLL che non restituisce controllo non è interrompibile dal motore. Usare operazioni brevi e Basic Wait per attendere. Non supportati DLL gestite, callback in Basic, export variadici e API arbitrarie a puntatori.

## Esempi

### 1. ID del processo

```vb
# ClientProcessId chiama GetCurrentProcessId in kernel32.dll senza parametri. Main salva l’ID Windows numerico in processId. Il confronto processId > 0 restituisce 1/True; l’ID non è Boolean né un seriale UO.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

ClientProcessId chiama GetCurrentProcessId in kernel32.dll senza parametri. Main salva l’ID Windows numerico in processId. Il confronto processId > 0 restituisce 1/True; l’ID non è Boolean né un seriale UO.

### 2. Testo, potenza e nomi

```vb
# TextLength(text) passa UTF-16 a lstrlenW e restituisce la lunghezza. Power(value, exponent) chiama pow con due Double. Describe("ore", 2, 3) riceve tre argomenti, scrive quelli nominati di Power in ordine inverso e restituisce "3:8". Tutte le funzioni ausiliarie sono complete.
Option Explicit On
Declare Unicode Function TextLength Lib "kernel32.dll" Alias "lstrlenW"(ByVal text As String) As Integer
Declare Function Power Lib "ucrtbase.dll" Alias "pow"(ByVal value As Double, ByVal exponent As Double) As Double

Function Describe(ByVal text As String, ByVal value As Double, ByVal exponent As Double) As String
    Dim length = TextLength(text:=text)
    Dim powered = Power(exponent:=exponent, value:=value)
    Return CStr(length) & ":" & CStr(powered)
End Function

Sub Main()
    Return Describe("ore", 2, 3)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

TextLength(text) passa UTF-16 a lstrlenW e restituisce la lunghezza. Power(value, exponent) chiama pow con due Double. Describe("ore", 2, 3) riceve tre argomenti, scrive quelli nominati di Power in ordine inverso e restituisce "3:8". Tutte le funzioni ausiliarie sono complete.

### 3. Export mancante

```vb
# NativeDemo.MissingExport indica volutamente un export assente. TryRead intercetta l’errore, imposta status="missing export" e Finally imposta finished=1. Main restituisce "missing export:1". Private limita la dichiarazione al modulo. Finally riguarda gli errori ordinari, senza garantire pulizia script dopo un annullamento di emergenza.
Option Explicit On
Module NativeDemo
    Private Declare Function MissingExport Lib "kernel32.dll" Alias "BasicManualMissingExport_71cf"() As Integer
    Public Function TryRead() As String
        Dim status = "unexpected export"
        Dim finished = 0
        Try
            MissingExport()
        Catch problem
            status = "missing export"
        Finally
            finished = 1
        End Try
        Return status & ":" & CStr(finished)
    End Function
End Module

Sub Main()
    Return NativeDemo.TryRead()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

NativeDemo.MissingExport indica volutamente un export assente. TryRead intercetta l’errore, imposta status="missing export" e Finally imposta finished=1. Main restituisce "missing export:1". Private limita la dichiarazione al modulo. Finally riguarda gli errori ordinari, senza garantire pulizia script dopo un annullamento di emergenza.


### Funzioni interne: dalla chiamata al risultato

Declare collega un nome Basic a un export di una DLL nativa Windows x64. Il sottoinsieme descritto funziona nel client compilato senza generare codice durante l’esecuzione; non include tutta l’interoperabilità VB.NET.

#### 1. ExternalDeclaration

Dichiarazioni non supportate vengono rifiutate prima dell’esecuzione con SC031. Limiti: 256 dichiarazioni e 64 librerie caricate per script principale. Analisi e completamento non caricano DLL. La vera firma nativa non è ricavabile: dichiarazioni errate possono bloccare il client.

`source -> typed declaration -> SC031 on unsupported ABI`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; funzione `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Nome o percorso .dll obbligatorio. I nomi di sistema semplici vengono cercati prima in System32; gli altri percorsi relativi partono dal file della dichiarazione, anche Include. Ammessi percorsi assoluti. Directory corrente e PATH non vengono cercati. Le dipendenze possono trovarsi accanto alla DLL o in System32.

`first call -> absolute DLL path -> cached library -> exact export`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; funzione `LibraryPath / GetCallable`.

#### 3. Invoke

Da zero a quattro parametri con ByVal e As Integer, Double, Boolean o String espliciti. Integer: 32 bit con segno; Double: 64 bit; Boolean: BOOL Windows a 32 bit, non bool C/C++. String è una copia temporanea di sola lettura terminata da NUL, massimo 1048576 unità UTF-16 senza NUL interno. La DLL non deve conservare il puntatore né scrivere nel buffer. Argomenti nominati tramite nomi locali. Non supportati ByRef, Optional, ParamArray, array, strutture e puntatori.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; funzione `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function richiede As Integer, Double o Boolean. Sub non ha As e produce Unit. Gli argomenti Integer/Boolean devono già essere Integer; Double accetta anche Integer. Usare CInt/CDbl/CStr esplicitamente se necessario. Stringhe, puntatori e interi a 64 bit restituiti richiedono un adattatore nativo con firma supportata.

`Windows x64 argument slots -> native call -> declared result`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; funzione `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Le stringhe temporanee si liberano dopo ogni chiamata, anche in caso di errore di conversione. Le librerie si liberano al termine, errore o annullamento dello script principale. Chiudere soltanto l’IDE mantiene attivi script e librerie.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; funzione `Dispose`.

Integer restituisce un numero a 32 bit con segno, il cui significato dipende dalla funzione nativa. Double restituisce un valore a virgola mobile a 64 bit. As Boolean normalizza zero in 0/False e ogni altro BOOL in 1/True: per questi flag 1/0 e True/False sono equivalenti nei confronti. Sub non restituisce valori (Unit). Esempi: 1, "3:8", "missing export:1".

<!-- implementation references (not callable script procedures):
Runtime/ExternalDeclaration.cs: type and declaration validation
Analysis/ExternalDeclarationValidator.cs: SC031
Runtime/ExternalLibraries.cs: LibraryPath / GetCallable / Invoke / Dispose
Runtime/ExternalCallSites.cs: CallInteger / CallDouble / CallVoid
Runtime/Interpreter.cs: CallSubrutine / CallObserved
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/declare-statement
https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
-->
