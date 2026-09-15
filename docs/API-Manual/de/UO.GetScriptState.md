# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest den Ausführungszustand für einen Index.

## Genaue Syntax

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## Parameter

- `ScriptIndex` — Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

## Rückgabewert

Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit 1 oder 2 vergleichen.

## Verhalten

- Laufende und pausierte Ausführungen zählen; abgeschlossene oder bereits abgebrochene werden ausgeschlossen. Der Aufrufer zählt normalerweise mit. Nur geladene IDE-Tabs sind keine Ausführungen.
- Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.
- Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.
- GetScriptsList liefert Indizes, GetScriptsCount eine Anzahl, GetScriptState einen dreistufigen Zustand. Werte nicht vertauschen oder jede Zahl ungleich null als true interpretieren.
- Manuelle/Debugger-Pause und konfigurierte Pause bei Verbindungsabbruch zählen. Zustand 1 beweist weder aktuelle CPU-Arbeit noch eingehende Serverdaten.

### Interne Funktionen: vom Aufruf zum Ergebnis

Es folgen tatsächliche Clientmethoden. Die Basic-Beispiele enthalten vollständige Helfer; interne C#-Methodennamen sind keine zusätzlichen Skriptbefehle.

#### 1. ExecuteStealthCompatibility

Die Runtime ruft den registrierten UO-Befehl auf und verpackt das Brückenergebnis als Integer, String oder Array.

Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit 1 oder 2 vergleichen.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetScriptState

Die Brücke verwendet den Ausführungsmanager dieses Clients.

Manuelle/Debugger-Pause und konfigurierte Pause bei Verbindungsabbruch zählen. Zustand 1 beweist weder aktuelle CPU-Arbeit noch eingehende Serverdaten.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; Funktion `GetScriptState`.

Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.


## Beispiele

### Erster Aufruf und Ergebnis

```vb
# Erster Aufruf und Ergebnis
#
# Liest den Ausführungszustand für einen Index.
#
# Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit
# 1 oder 2 vergleichen.

SUB Main()
    # Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente.
    # Print-Texte sind Beispielmeldungen.
    # Manuelle/Debugger-Pause und konfigurierte Pause bei Verbindungsabbruch zählen. Zustand 1
    # beweist weder aktuelle CPU-Arbeit noch eingehende Serverdaten.
    # Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit
    # 1 oder 2 vergleichen.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente. Print-Texte sind Beispielmeldungen.
- Manuelle/Debugger-Pause und konfigurierte Pause bei Verbindungsabbruch zählen. Zustand 1 beweist weder aktuelle CPU-Arbeit noch eingehende Serverdaten.
- Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit 1 oder 2 vergleichen.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

### Schleife oder Bedingung

```vb
# Schleife oder Bedingung
#
# Liest den Ausführungszustand für einen Index.
#
# Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit
# 1 oder 2 vergleichen.

SUB Main()
    # Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff
    # die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
    # Manuelle/Debugger-Pause und konfigurierte Pause bei Verbindungsabbruch zählen. Zustand 1
    # beweist weder aktuelle CPU-Arbeit noch eingehende Serverdaten.
    # Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit
    # 1 oder 2 vergleichen.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
- Manuelle/Debugger-Pause und konfigurierte Pause bei Verbindungsabbruch zählen. Zustand 1 beweist weder aktuelle CPU-Arbeit noch eingehende Serverdaten.
- Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit 1 oder 2 vergleichen.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Liest den Ausführungszustand für einen Index.
#
# Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit
# 1 oder 2 vergleichen.

SUB Main()
    # Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten
    # API-Befehl zu unterscheiden.
    # IsScriptActive bildet 1 und 2 auf true, 0 auf false ab. GetScriptState selbst bleibt ein
    # numerischer Zustandscode.
    # Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit
    # 1 oder 2 vergleichen.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten API-Befehl zu unterscheiden.
- IsScriptActive bildet 1 und 2 auf true, 0 auf false ab. GetScriptState selbst bleibt ein numerischer Zustandscode.
- Integer-Zustand: 0 = fehlt/unbekannt, 1 = läuft, 2 = pausiert. Kein Boolean: ausdrücklich mit 1 oder 2 vergleichen.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.
