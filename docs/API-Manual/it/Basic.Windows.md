# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Windows.bas è un modulo Basic modificabile con sei funzioni pubbliche per processo, brevi intervalli e dimensioni del desktop. Sotto sono mostrati tutto il codice e i Declare privati; Main da solo non basta.

## Sintassi esatta

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Parametri

- `Include / Windows.bas` — Include "Windows.bas" carica Scripts/Include/Windows.bas. Per una cartella script separata copiare il modulo nella sottocartella Include. Il pacchetto contiene Main.bas e Include/Windows.bas. Chiamate con Windows., senza UO.; è un modulo script.
- `ProcessId()` — ProcessId(), senza argomenti, restituisce l’ID Windows del processo client come Integer, non un seriale UO o ID di connessione.
- `Milliseconds()` — Milliseconds(), senza argomenti, restituisce Double 0..4294967295, cioè GetTickCount senza segno a 32 bit. Ai risultati nativi negativi aggiunge 4294967296.0. Il contatore riparte circa ogni 49,7 giorni; non è ora civile o timer ad alta precisione.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) riceve un valore salvato di Milliseconds() come Double e restituisce millisecondi trascorsi Double. Fuori da 0..4294967295 genera un errore. Una differenza negativa riceve 4294967296.0, gestendo un solo giro. Usare intervalli inferiori a un giro; la funzione non attende.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight(), senza argomenti, restituiscono Integer del monitor principale tramite metriche 0/1 nel contesto DPI del processo. Non sono celle UO né dimensioni della finestra di gioco.
- `DesktopBounds()` — DesktopBounds() restituisce un nuovo Dictionary con chiavi stringa X, Y, Width, Height e valori Integer, letti con Item("X") ecc. Le metriche 76–79 comprendono tutti i monitor; X/Y possono essere negativi. Modificare il Dictionary non modifica finestre.

## Restituisce

ID e dimensioni: Integer. Tempi: quantità Double in millisecondi, non Boolean. DesktopBounds: Object (Dictionary) con valori Integer. Include e dichiarazioni senza risultato. Main di ogni esempio restituisce 1/True dopo il controllo; 0/False significa controllo fallito, non una conversione automatica di ogni numero nativo.

## Comportamento

- Richiede Windows x64. NativeTicks, NativeProcessId e NativeMetric sono i Declare privati mostrati sotto; vedere Basic.Declare per DLL ed errori. Nessun traffico di gioco, cambio opzioni o movimento.
- Si leggono valori attuali. Milliseconds normalmente si aggiorna ogni 10–16 ms. Non riconosce più giri o valori di un’altra sessione Windows. Usare per brevi operazioni; la durata esatta di Wait non è garantita.
- Copiare Main.bas con Include/Windows.bas; il codice si modifica nella IDE. DesktopBounds crea ogni volta una copia indipendente. Disposizione dei monitor e DPI possono cambiare i risultati successivi.

## Esempi

### 1. Processo e contatore

```vb
# Main carica Windows.bas, legge ProcessId() e salva Milliseconds() in startedAt. AndAlso verifica ID positivo e intervallo 0..4294967295, restituendo 1/True. I numeri reali dipendono dal computer.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Main carica Windows.bas, legge ProcessId() e salva Milliseconds() in startedAt. AndAlso verifica ID positivo e intervallo 0..4294967295, restituendo 1/True. I numeri reali dipendono dal computer.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 2. Misurare un’attesa

```vb
# MeasureWait(delayMilliseconds) rifiuta valori negativi, salva il contatore, chiama Wait e restituisce ElapsedMilliseconds(startMilliseconds:=startedAt). Main passa 15 e verifica elapsed >= 0; il tempo reale può superare 15 ms. Tutti gli ausiliari e la gestione del giro sono mostrati.
Option Explicit On
Include "Windows.bas"

Function MeasureWait(ByVal delayMilliseconds As Integer) As Double
    If delayMilliseconds < 0 Then
        Throw "delayMilliseconds must be non-negative"
    End If
    Dim startedAt = Windows.Milliseconds()
    Wait(delayMilliseconds)
    Return Windows.ElapsedMilliseconds(startMilliseconds:=startedAt)
End Function

Sub Main()
    Dim elapsed = MeasureWait(15)
    Return elapsed >= 0
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

MeasureWait(delayMilliseconds) rifiuta valori negativi, salva il contatore, chiama Wait e restituisce ElapsedMilliseconds(startMilliseconds:=startedAt). Main passa 15 e verifica elapsed >= 0; il tempo reale può superare 15 ms. Tutti gli ausiliari e la gestione del giro sono mostrati.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 3. Geometria del desktop

```vb
# Main legge X/Y/Width/Height con Item da un Dictionary indipendente e confronta le dimensioni con il monitor principale. Quelle principali devono essere positive e il desktop almeno altrettanto grande. left/top possono essere negativi e non sono coordinate di movimento UO.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim desktop = Windows.DesktopBounds()
    Dim left = desktop.Item("X")
    Dim top = desktop.Item("Y")
    Dim width = desktop.Item("Width")
    Dim height = desktop.Item("Height")
    Dim primaryWidth = Windows.ScreenWidth()
    Dim primaryHeight = Windows.ScreenHeight()
    Return width >= primaryWidth AndAlso height >= primaryHeight AndAlso primaryWidth > 0 AndAlso primaryHeight > 0
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Main legge X/Y/Width/Height con Item da un Dictionary indipendente e confronta le dimensioni con il monitor principale. Quelle principali devono essere positive e il desktop almeno altrettanto grande. left/top possono essere negativi e non sono coordinate di movimento UO.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```


### Funzioni interne: dalla chiamata al risultato

Windows.bas è un modulo Basic modificabile con sei funzioni pubbliche per processo, brevi intervalli e dimensioni del desktop. Sotto sono mostrati tutto il codice e i Declare privati; Main da solo non basta.

#### 1. ProcessId / Milliseconds

Milliseconds(), senza argomenti, restituisce Double 0..4294967295, cioè GetTickCount senza segno a 32 bit. Ai risultati nativi negativi aggiunge 4294967296.0. Il contatore riparte circa ogni 49,7 giorni; non è ora civile o timer ad alta precisione.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Sorgente del progetto: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; funzione `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) riceve un valore salvato di Milliseconds() come Double e restituisce millisecondi trascorsi Double. Fuori da 0..4294967295 genera un errore. Una differenza negativa riceve 4294967296.0, gestendo un solo giro. Usare intervalli inferiori a un giro; la funzione non attende.

`validate start -> now - start -> if negative add one wrap -> Double`

Sorgente del progetto: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; funzione `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() restituisce un nuovo Dictionary con chiavi stringa X, Y, Width, Height e valori Integer, letti con Item("X") ecc. Le metriche 76–79 comprendono tutti i monitor; X/Y possono essere negativi. Modificare il Dictionary non modifica finestre.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Sorgente del progetto: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; funzione `ScreenWidth / ScreenHeight / DesktopBounds`.

ID e dimensioni: Integer. Tempi: quantità Double in millisecondi, non Boolean. DesktopBounds: Object (Dictionary) con valori Integer. Include e dichiarazioni senza risultato. Main di ogni esempio restituisce 1/True dopo il controllo; 0/False significa controllo fallito, non una conversione automatica di ogni numero nativo.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
