# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest den Quelldateipfad einer aktiven Ausführung.

## Genaue Syntax

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## Parameter

- `ScriptIndex` — Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

## Rückgabewert

String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine gewöhnliche Datei besitzen.

## Verhalten

- Laufende und pausierte Ausführungen zählen; abgeschlossene oder bereits abgebrochene werden ausgeschlossen. Der Aufrufer zählt normalerweise mit. Nur geladene IDE-Tabs sind keine Ausführungen.
- Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.
- Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.
- GetScriptsList liefert Indizes, GetScriptsCount eine Anzahl, GetScriptState einen dreistufigen Zustand. Werte nicht vertauschen oder jede Zahl ungleich null als true interpretieren.
- ScriptIndex=0 wählt den ersten aktuellen Lauf. Der Getter liest den Quellpfad; er öffnet, speichert oder startet die Datei nicht.

### Interne Funktionen: vom Aufruf zum Ergebnis

Es folgen tatsächliche Clientmethoden. Die Basic-Beispiele enthalten vollständige Helfer; interne C#-Methodennamen sind keine zusätzlichen Skriptbefehle.

#### 1. ExecuteStealthCompatibility

Die Runtime ruft den registrierten UO-Befehl auf und verpackt das Brückenergebnis als Integer, String oder Array.

String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine gewöhnliche Datei besitzen.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

Die Brücke verwendet den Ausführungsmanager dieses Clients.

ScriptIndex=0 wählt den ersten aktuellen Lauf. Der Getter liest den Quellpfad; er öffnet, speichert oder startet die Datei nicht.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; Funktion `GetScriptPath`.

Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.


## Beispiele

### Erster Aufruf und Ergebnis

```vb
# Erster Aufruf und Ergebnis
#
# Liest den Quelldateipfad einer aktiven Ausführung.
#
# String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben
# normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine
# gewöhnliche Datei besitzen.

SUB Main()
    # Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente.
    # Print-Texte sind Beispielmeldungen.
    # ScriptIndex=0 wählt den ersten aktuellen Lauf. Der Getter liest den Quellpfad; er öffnet,
    # speichert oder startet die Datei nicht.
    # String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben
    # normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine
    # gewöhnliche Datei besitzen.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente. Print-Texte sind Beispielmeldungen.
- ScriptIndex=0 wählt den ersten aktuellen Lauf. Der Getter liest den Quellpfad; er öffnet, speichert oder startet die Datei nicht.
- String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine gewöhnliche Datei besitzen.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

### Schleife oder Bedingung

```vb
# Schleife oder Bedingung
#
# Liest den Quelldateipfad einer aktiven Ausführung.
#
# String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben
# normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine
# gewöhnliche Datei besitzen.

SUB Main()
    # Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff
    # die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
    # ScriptIndex=0 wählt den ersten aktuellen Lauf. Der Getter liest den Quellpfad; er öffnet,
    # speichert oder startet die Datei nicht.
    # String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben
    # normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine
    # gewöhnliche Datei besitzen.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
- ScriptIndex=0 wählt den ersten aktuellen Lauf. Der Getter liest den Quellpfad; er öffnet, speichert oder startet die Datei nicht.
- String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine gewöhnliche Datei besitzen.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Liest den Quelldateipfad einer aktiven Ausführung.
#
# String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben
# normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine
# gewöhnliche Datei besitzen.

SUB Main()
    # Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten
    # API-Befehl zu unterscheiden.
    # ReadScriptPath verwendet fallback nur bei leerem Pfad. Der Helfer ist keine neue
    # GetScriptPath-Überladung.
    # String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben
    # normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine
    # gewöhnliche Datei besitzen.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten API-Befehl zu unterscheiden.
- ReadScriptPath verwendet fallback nur bei leerem Pfad. Der Helfer ist keine neue GetScriptPath-Überladung.
- String: gespeicherter Quelldateipfad oder "" bei fehlendem Index. Dateiausführungen haben normalerweise einen vollständigen Pfad; Befehle oder Quelltext im Speicher müssen keine gewöhnliche Datei besitzen.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.
