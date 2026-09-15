# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Lädt eine Basic-Datei und fordert deren öffentliche Sub Main an.

## Genaue Syntax

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## Parameter

- `ScriptPath` — Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.

## Rückgabewert

Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) = Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.

## Verhalten

- Laufende und pausierte Ausführungen zählen; abgeschlossene oder bereits abgebrochene werden ausgeschlossen. Der Aufrufer zählt normalerweise mit. Nur geladene IDE-Tabs sind keine Ausführungen.
- Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.
- Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.
- GetScriptsList liefert Indizes, GetScriptsCount eine Anzahl, GetScriptState einen dreistufigen Zustand. Werte nicht vertauschen oder jede Zahl ungleich null als true interpretieren.
- Die genannten Worker.bas-Dateien zuvor separat erstellen. Ungültige/unlesbare Pfade, ungeeignete Main, deaktiviertes Basic oder abgelehnte Parallelstarts scheitern. Ein noch stoppender Lauf kann einen verzögerten Neustart bewirken; Annahme ist kein Abschluss. Kurze Skripte können vor dem Lesen der Anzahl schon enden.

### Interne Funktionen: vom Aufruf zum Ergebnis

Es folgen tatsächliche Clientmethoden. Die Basic-Beispiele enthalten vollständige Helfer; interne C#-Methodennamen sind keine zusätzlichen Skriptbefehle.

#### 1. ExecuteStealthCompatibility

Die Runtime ruft den registrierten UO-Befehl auf und verpackt das Brückenergebnis als Integer, String oder Array.

Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) = Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. StartScript

Die Brücke verwendet den Ausführungsmanager dieses Clients.

Die genannten Worker.bas-Dateien zuvor separat erstellen. Ungültige/unlesbare Pfade, ungeeignete Main, deaktiviertes Basic oder abgelehnte Parallelstarts scheitern. Ein noch stoppender Lauf kann einen verzögerten Neustart bewirken; Annahme ist kein Abschluss. Kurze Skripte können vor dem Lesen der Anzahl schon enden.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; Funktion `StartScript`.

Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.


## Beispiele

### Erster Aufruf und Ergebnis

```vb
# Erster Aufruf und Ergebnis
#
# Lädt eine Basic-Datei und fordert deren öffentliche Sub Main an.
#
# Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) =
# Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.

SUB Main()
    # Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente.
    # Print-Texte sind Beispielmeldungen.
    # Die genannten Worker.bas-Dateien zuvor separat erstellen. Ungültige/unlesbare Pfade,
    # ungeeignete Main, deaktiviertes Basic oder abgelehnte Parallelstarts scheitern. Ein noch
    # stoppender Lauf kann einen verzögerten Neustart bewirken; Annahme ist kein Abschluss. Kurze
    # Skripte können vor dem Lesen der Anzahl schon enden.
    # Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) =
    # Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.
    # Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses
    # Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die
    # Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente. Print-Texte sind Beispielmeldungen.
- Die genannten Worker.bas-Dateien zuvor separat erstellen. Ungültige/unlesbare Pfade, ungeeignete Main, deaktiviertes Basic oder abgelehnte Parallelstarts scheitern. Ein noch stoppender Lauf kann einen verzögerten Neustart bewirken; Annahme ist kein Abschluss. Kurze Skripte können vor dem Lesen der Anzahl schon enden.
- Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) = Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.
- Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.

### Schleife oder Bedingung

```vb
# Schleife oder Bedingung
#
# Lädt eine Basic-Datei und fordert deren öffentliche Sub Main an.
#
# Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) =
# Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.

SUB Main()
    # Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff
    # die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
    # Die genannten Worker.bas-Dateien zuvor separat erstellen. Ungültige/unlesbare Pfade,
    # ungeeignete Main, deaktiviertes Basic oder abgelehnte Parallelstarts scheitern. Ein noch
    # stoppender Lauf kann einen verzögerten Neustart bewirken; Annahme ist kein Abschluss. Kurze
    # Skripte können vor dem Lesen der Anzahl schon enden.
    # Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) =
    # Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.
    # Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses
    # Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die
    # Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
- Die genannten Worker.bas-Dateien zuvor separat erstellen. Ungültige/unlesbare Pfade, ungeeignete Main, deaktiviertes Basic oder abgelehnte Parallelstarts scheitern. Ein noch stoppender Lauf kann einen verzögerten Neustart bewirken; Annahme ist kein Abschluss. Kurze Skripte können vor dem Lesen der Anzahl schon enden.
- Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) = Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.
- Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Lädt eine Basic-Datei und fordert deren öffentliche Sub Main an.
#
# Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) =
# Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.

SUB Main()
    # Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten
    # API-Befehl zu unterscheiden.
    # TryStartBasic vergleicht mit 65535 und liefert true/false. Es wartet nicht auf Abschluss und
    # macht aus der Anzahl keinen Index.
    # Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) =
    # Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.
    # Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses
    # Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die
    # Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten API-Befehl zu unterscheiden.
- TryStartBasic vergleicht mit 65535 und liefert true/false. Es wartet nicht auf Abschluss und macht aus der Anzahl keinen Index.
- Integer: Anzahl aktiver Ausführungen nach angenommener Startanforderung; 65535 (0xFFFF) = Startfehler. Kein neuer Skriptindex, Boolean oder Abschlussnachweis.
- Erforderlicher String ScriptPath. Relative Pfade beginnen im AutoLoad-Verzeichnis dieses Clients; absolute Pfade sind erlaubt. Pfade mit Leerzeichen in Anführungszeichen setzen. Die Datei benötigt unterstütztes Basic und eine öffentliche Sub Main ohne erforderliche Argumente.
