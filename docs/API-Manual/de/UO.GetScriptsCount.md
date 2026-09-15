# UO.GetScriptsCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Zählt aktive Ausführungen dieses Clients.

## Genaue Syntax

```text
UO.GetScriptsCount() -> Integer
```

## Parameter

Keine Parameter.

## Rückgabewert

Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean und kein Index.

## Verhalten

- Laufende und pausierte Ausführungen zählen; abgeschlossene oder bereits abgebrochene werden ausgeschlossen. Der Aufrufer zählt normalerweise mit. Nur geladene IDE-Tabs sind keine Ausführungen.
- Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.
- Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.
- GetScriptsList liefert Indizes, GetScriptsCount eine Anzahl, GetScriptState einen dreistufigen Zustand. Werte nicht vertauschen oder jede Zahl ungleich null als true interpretieren.
- Keine Argumente. Das Zählen sortiert die Liste nicht und verändert keinen Lauf.

### Interne Funktionen: vom Aufruf zum Ergebnis

Es folgen tatsächliche Clientmethoden. Die Basic-Beispiele enthalten vollständige Helfer; interne C#-Methodennamen sind keine zusätzlichen Skriptbefehle.

#### 1. ExecuteStealthCompatibility

Die Runtime ruft den registrierten UO-Befehl auf und verpackt das Brückenergebnis als Integer, String oder Array.

Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean und kein Index.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetScriptsCount

Die Brücke verwendet den Ausführungsmanager dieses Clients.

Keine Argumente. Das Zählen sortiert die Liste nicht und verändert keinen Lauf.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetScriptsCount`.

#### 3. GetScriptsCount

`_running.Count(entry => !entry.Value.Cancellation.IsCancellationRequested)`

Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; Funktion `GetScriptsCount`.

Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.


## Beispiele

### Erster Aufruf und Ergebnis

```vb
# Erster Aufruf und Ergebnis
#
# Zählt aktive Ausführungen dieses Clients.
#
# Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean
# und kein Index.

SUB Main()
    # Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente.
    # Print-Texte sind Beispielmeldungen.
    # Keine Argumente. Das Zählen sortiert die Liste nicht und verändert keinen Lauf.
    # Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean
    # und kein Index.

    Dim count=UO.GetScriptsCount()
    UO.Print(CStr(count))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente. Print-Texte sind Beispielmeldungen.
- Keine Argumente. Das Zählen sortiert die Liste nicht und verändert keinen Lauf.
- Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean und kein Index.

### Schleife oder Bedingung

```vb
# Schleife oder Bedingung
#
# Zählt aktive Ausführungen dieses Clients.
#
# Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean
# und kein Index.

SUB Main()
    # Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff
    # die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
    # Keine Argumente. Das Zählen sortiert die Liste nicht und verändert keinen Lauf.
    # Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean
    # und kein Index.

    Dim before=UO.GetScriptsCount()
    Wait(250)
    Dim after=UO.GetScriptsCount()
    UO.Print(CStr(after-before))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
- Keine Argumente. Das Zählen sortiert die Liste nicht und verändert keinen Lauf.
- Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean und kein Index.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Zählt aktive Ausführungen dieses Clients.
#
# Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean
# und kein Index.

SUB Main()
    # Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten
    # API-Befehl zu unterscheiden.
    # HasOtherScripts vergleicht mit 1, weil der Aufrufer normalerweise selbst einen Eintrag belegt.
    # Nur der Helfer liefert true/false.
    # Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean
    # und kein Index.

    If HasOtherScripts() Then
        UO.Print("Other executions are active")
    Else
        UO.Print("No other active executions")
    End If
END SUB

Function HasOtherScripts() As Boolean
    Dim count=UO.GetScriptsCount()
    Return count > 1
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten API-Befehl zu unterscheiden.
- HasOtherScripts vergleicht mit 1, weil der Aufrufer normalerweise selbst einen Eintrag belegt. Nur der Helfer liefert true/false.
- Integer >= 0: Anzahl aktiver Ausführungen einschließlich pausierter. Eine Anzahl, kein Boolean und kein Index.
