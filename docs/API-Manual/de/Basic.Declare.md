# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Declare verbindet einen Basic-Prozedurnamen mit einem Export einer nativen Windows-x64-DLL. Der beschriebene Umfang funktioniert auch im kompilierten Client ohne Laufzeit-Codegenerierung; vollständiges VB.NET-Interop ist damit nicht gemeint.

## Genaue Syntax

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Parameter

- `name / Public / Private` — Lokaler Name ohne Beachtung der Großschreibung; Aufruf ohne UO. Deklaration auf Datei- oder Module-Ebene, ohne Rumpf und End Function/End Sub. Standard Public; Private innerhalb eines Moduls. Eingebaute Basic-/UO-Namen dürfen nicht ersetzt werden: anderen Namen mit Alias wählen.
- `Lib / library.dll` — Erforderlicher .dll-Dateiname oder Pfad. Ein einfacher Systemname wird zuerst in System32 gesucht; andere relative Pfade gelten relativ zur deklarierenden Datei, auch einer Include-Datei. Absolute Pfade sind erlaubt. Arbeitsverzeichnis und PATH werden nicht durchsucht. Abhängigkeiten können neben der DLL oder in System32 liegen.
- `Alias / export` — Optionaler exakter Exportname mit Beachtung der Großschreibung; sonst einfacher lokaler Name. Keine Exportnummern. Erforderlich ist eine native Windows-x64-Funktion mit exakt passender Signatur, keine verwaltete .NET-Methode.
- `Ansi / Unicode / Auto` — Standard Ansi kopiert Texte in die Windows-ANSI-Codierung; nicht darstellbare Zeichen können verloren gehen. Unicode verwendet UTF-16. Beide suchen den exakten Namen. Auto verwendet UTF-16, versucht den exakten Namen und dann dessen W-Variante. Die tatsächliche Exportcodierung wird nicht erkannt: für Unicode-APIs Unicode und einen expliziten W-Export verwenden.
- `ByVal arg As Type` — Null bis vier Parameter, jeweils ausdrücklich ByVal und As Integer, Double, Boolean oder String. Integer: vorzeichenbehaftete 32 Bit; Double: 64 Bit; Boolean: 32-Bit-Windows-BOOL, kein C/C++-bool. String ist eine temporäre, nur lesbare, NUL-terminierte Eingabekopie mit höchstens 1048576 UTF-16-Einheiten ohne eingebettetes NUL. DLL darf den Zeiger weder speichern noch beschreiben. Benannte Argumente verwenden lokale Parameternamen. Kein ByRef, Optional, ParamArray, Array, Structure oder Zeiger.
- `As ResultType / Sub` — Function benötigt As Integer, Double oder Boolean; Sub besitzt keine As-Klausel und liefert Unit. Integer-/Boolean-Argumente müssen Integer sein; Double akzeptiert auch Integer. Bei Bedarf bewusst CInt/CDbl/CStr verwenden. Rückgabe von Strings, Zeigern oder 64-Bit-Ganzzahlen erfordert eine native Adapter-DLL mit unterstützter Signatur.

## Rückgabewert

Integer liefert eine vorzeichenbehaftete 32-Bit-Zahl mit der Bedeutung der DLL-Funktion, nicht automatisch Erfolg. Double liefert einen 64-Bit-Gleitkommawert. As Boolean normalisiert null zu 0/False und jeden anderen BOOL zu 1/True; nur für solche Flags sind Vergleiche mit 1/0 und True/False gleichwertig. Sub liefert keinen Wert (Unit). Beispiele: 1, "3:8", "missing export:1".

## Verhalten

- Nicht unterstützte Deklarationen werden vor dem Start mit SC031 abgewiesen. Grenzen: 256 Deklarationen und 64 geladene Bibliotheken pro Hauptskript. Analyse und IDE-Vervollständigung laden keine DLL. Die echte Exportsignatur ist unbekannt; eine falsche Deklaration kann den Client abstürzen lassen.
- Erster Aufruf lädt die DLL; spätere Aufrufe verwenden Bibliothek und Exportadresse erneut. Argumente werden einmal in Quellreihenfolge ausgewertet und danach nach Namen geordnet. Lade-, Architektur-, Export- und Konvertierungsfehler sind mit Try/Catch abfangbar. Native Speicherverletzungen sind keine gewöhnlichen Skriptfehler.
- Temporäre Strings werden nach jedem Aufruf einschließlich Konvertierungsfehlern freigegeben. Bibliotheken werden beim Ende, Fehler oder Abbruch des Hauptskripts freigegeben. Alleiniges Schließen der IDE lässt Skript und Bibliotheken weiterlaufen.
- Synchroner Aufruf im Skript-Worker. Pause/Stopp werden davor und danach geprüft; eine nie zurückkehrende DLL-Funktion kann die Engine nicht unterbrechen. Kurze native Operationen und Basic Wait zum Warten verwenden. Keine verwalteten DLLs, Basic-Rückrufe, variadischen Exporte oder beliebigen Zeiger-APIs.

## Beispiele

### 1. Prozess-ID lesen

```vb
# ClientProcessId ruft GetCurrentProcessId aus kernel32.dll ohne Parameter auf. Main speichert die numerische Windows-ID in processId. Erst processId > 0 liefert 1/True; die ID selbst ist weder Boolean noch UO-Seriennummer.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Erläuterung der Parameter und Ausführung:**

ClientProcessId ruft GetCurrentProcessId aus kernel32.dll ohne Parameter auf. Main speichert die numerische Windows-ID in processId. Erst processId > 0 liefert 1/True; die ID selbst ist weder Boolean noch UO-Seriennummer.

### 2. Text, Potenz und benannte Argumente

```vb
# TextLength(text) übergibt UTF-16 an lstrlenW und liefert die Länge. Power(value, exponent) ruft pow mit zwei Double-Werten auf. Describe("ore", 2, 3) erhält drei Argumente, schreibt die benannten Power-Argumente in umgekehrter Reihenfolge und liefert "3:8". Alle Hilfsfunktionen sind vollständig gezeigt.
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

**Erläuterung der Parameter und Ausführung:**

TextLength(text) übergibt UTF-16 an lstrlenW und liefert die Länge. Power(value, exponent) ruft pow mit zwei Double-Werten auf. Describe("ore", 2, 3) erhält drei Argumente, schreibt die benannten Power-Argumente in umgekehrter Reihenfolge und liefert "3:8". Alle Hilfsfunktionen sind vollständig gezeigt.

### 3. Fehlender Export

```vb
# NativeDemo.MissingExport nennt absichtlich einen fehlenden Export. TryRead fängt den Fehler ab, setzt status auf "missing export" und Finally setzt finished=1. Main liefert "missing export:1". Private hält die Deklaration im Modul. Dieses Finally beschreibt normale Fehlerbehandlung, keine garantierte Skriptbereinigung nach Notabbruch.
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

**Erläuterung der Parameter und Ausführung:**

NativeDemo.MissingExport nennt absichtlich einen fehlenden Export. TryRead fängt den Fehler ab, setzt status auf "missing export" und Finally setzt finished=1. Main liefert "missing export:1". Private hält die Deklaration im Modul. Dieses Finally beschreibt normale Fehlerbehandlung, keine garantierte Skriptbereinigung nach Notabbruch.


### Interne Funktionen: vom Aufruf zum Ergebnis

Declare verbindet einen Basic-Prozedurnamen mit einem Export einer nativen Windows-x64-DLL. Der beschriebene Umfang funktioniert auch im kompilierten Client ohne Laufzeit-Codegenerierung; vollständiges VB.NET-Interop ist damit nicht gemeint.

#### 1. ExternalDeclaration

Nicht unterstützte Deklarationen werden vor dem Start mit SC031 abgewiesen. Grenzen: 256 Deklarationen und 64 geladene Bibliotheken pro Hauptskript. Analyse und IDE-Vervollständigung laden keine DLL. Die echte Exportsignatur ist unbekannt; eine falsche Deklaration kann den Client abstürzen lassen.

`source -> typed declaration -> SC031 on unsupported ABI`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; Funktion `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Erforderlicher .dll-Dateiname oder Pfad. Ein einfacher Systemname wird zuerst in System32 gesucht; andere relative Pfade gelten relativ zur deklarierenden Datei, auch einer Include-Datei. Absolute Pfade sind erlaubt. Arbeitsverzeichnis und PATH werden nicht durchsucht. Abhängigkeiten können neben der DLL oder in System32 liegen.

`first call -> absolute DLL path -> cached library -> exact export`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; Funktion `LibraryPath / GetCallable`.

#### 3. Invoke

Null bis vier Parameter, jeweils ausdrücklich ByVal und As Integer, Double, Boolean oder String. Integer: vorzeichenbehaftete 32 Bit; Double: 64 Bit; Boolean: 32-Bit-Windows-BOOL, kein C/C++-bool. String ist eine temporäre, nur lesbare, NUL-terminierte Eingabekopie mit höchstens 1048576 UTF-16-Einheiten ohne eingebettetes NUL. DLL darf den Zeiger weder speichern noch beschreiben. Benannte Argumente verwenden lokale Parameternamen. Kein ByRef, Optional, ParamArray, Array, Structure oder Zeiger.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; Funktion `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function benötigt As Integer, Double oder Boolean; Sub besitzt keine As-Klausel und liefert Unit. Integer-/Boolean-Argumente müssen Integer sein; Double akzeptiert auch Integer. Bei Bedarf bewusst CInt/CDbl/CStr verwenden. Rückgabe von Strings, Zeigern oder 64-Bit-Ganzzahlen erfordert eine native Adapter-DLL mit unterstützter Signatur.

`Windows x64 argument slots -> native call -> declared result`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; Funktion `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Temporäre Strings werden nach jedem Aufruf einschließlich Konvertierungsfehlern freigegeben. Bibliotheken werden beim Ende, Fehler oder Abbruch des Hauptskripts freigegeben. Alleiniges Schließen der IDE lässt Skript und Bibliotheken weiterlaufen.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; Funktion `Dispose`.

Integer liefert eine vorzeichenbehaftete 32-Bit-Zahl mit der Bedeutung der DLL-Funktion, nicht automatisch Erfolg. Double liefert einen 64-Bit-Gleitkommawert. As Boolean normalisiert null zu 0/False und jeden anderen BOOL zu 1/True; nur für solche Flags sind Vergleiche mit 1/0 und True/False gleichwertig. Sub liefert keinen Wert (Unit). Beispiele: 1, "3:8", "missing export:1".

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
