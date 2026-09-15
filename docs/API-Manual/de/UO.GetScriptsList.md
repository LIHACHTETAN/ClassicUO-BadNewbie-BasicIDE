# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liefert die aktuellen numerischen Skriptindizes.

## Genaue Syntax

```text
UO.GetScriptsList() -> Array
```

## Parameter

Keine Parameter.

## Rückgabewert

Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen oder Textdatensätze.

## Verhalten

- Laufende und pausierte Ausführungen zählen; abgeschlossene oder bereits abgebrochene werden ausgeschlossen. Der Aufrufer zählt normalerweise mit. Nur geladene IDE-Tabs sind keine Ausführungen.
- Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.
- Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.
- GetScriptsList liefert Indizes, GetScriptsCount eine Anzahl, GetScriptState einen dreistufigen Zustand. Werte nicht vertauschen oder jede Zahl ungleich null als true interpretieren.
- Keine Argumente. Jedes numerische Element kann an den Getter für Name, Pfad oder Zustand übergeben werden. Änderungen am zurückgegebenen Array steuern keine Skripte.

### Interne Funktionen: vom Aufruf zum Ergebnis

Es folgen tatsächliche Clientmethoden. Die Basic-Beispiele enthalten vollständige Helfer; interne C#-Methodennamen sind keine zusätzlichen Skriptbefehle.

#### 1. ExecuteStealthCompatibility

Die Runtime ruft den registrierten UO-Befehl auf und verpackt das Brückenergebnis als Integer, String oder Array.

Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen oder Textdatensätze.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

Die Brücke verwendet den Ausführungsmanager dieses Clients.

Keine Argumente. Jedes numerische Element kann an den Getter für Name, Pfad oder Zustand übergeben werden. Änderungen am zurückgegebenen Array steuern keine Skripte.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; Funktion `GetScriptsList`.

Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.


## Beispiele

### Erster Aufruf und Ergebnis

```vb
# Erster Aufruf und Ergebnis
#
# Liefert die aktuellen numerischen Skriptindizes.
#
# Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen
# oder Textdatensätze.

SUB Main()
    # Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente.
    # Print-Texte sind Beispielmeldungen.
    # Keine Argumente. Jedes numerische Element kann an den Getter für Name, Pfad oder Zustand
    # übergeben werden. Änderungen am zurückgegebenen Array steuern keine Skripte.
    # Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen
    # oder Textdatensätze.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente. Print-Texte sind Beispielmeldungen.
- Keine Argumente. Jedes numerische Element kann an den Getter für Name, Pfad oder Zustand übergeben werden. Änderungen am zurückgegebenen Array steuern keine Skripte.
- Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen oder Textdatensätze.

### Schleife oder Bedingung

```vb
# Schleife oder Bedingung
#
# Liefert die aktuellen numerischen Skriptindizes.
#
# Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen
# oder Textdatensätze.

SUB Main()
    # Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff
    # die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
    # Keine Argumente. Jedes numerische Element kann an den Getter für Name, Pfad oder Zustand
    # übergeben werden. Änderungen am zurückgegebenen Array steuern keine Skripte.
    # Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen
    # oder Textdatensätze.

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
- Keine Argumente. Jedes numerische Element kann an den Getter für Name, Pfad oder Zustand übergeben werden. Änderungen am zurückgegebenen Array steuern keine Skripte.
- Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen oder Textdatensätze.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Liefert die aktuellen numerischen Skriptindizes.
#
# Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen
# oder Textdatensätze.

SUB Main()
    # Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten
    # API-Befehl zu unterscheiden.
    # FindNamedScript liefert den ersten aktuellen Index mit exakt passendem Anzeigenamen oder -1.
    # Namen können doppelt vorkommen; Positionen können sich ändern.
    # Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen
    # oder Textdatensätze.

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten API-Befehl zu unterscheiden.
- FindNamedScript liefert den ersten aktuellen Index mit exakt passendem Anzeigenamen oder -1. Namen können doppelt vorkommen; Positionen können sich ändern.
- Array aus Integer: Indizes 0..N-1 oder ein leeres Array. Die Elemente sind Zahlen, keine Namen oder Textdatensätze.
