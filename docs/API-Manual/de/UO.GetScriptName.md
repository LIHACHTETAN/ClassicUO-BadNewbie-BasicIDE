# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest den Anzeigenamen einer aktiven Ausführung.

## Genaue Syntax

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## Parameter

- `ScriptIndex` — Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

## Rückgabewert

String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich einen leeren Namen haben.

## Verhalten

- Laufende und pausierte Ausführungen zählen; abgeschlossene oder bereits abgebrochene werden ausgeschlossen. Der Aufrufer zählt normalerweise mit. Nur geladene IDE-Tabs sind keine Ausführungen.
- Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.
- Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.
- GetScriptsList liefert Indizes, GetScriptsCount eine Anzahl, GetScriptState einen dreistufigen Zustand. Werte nicht vertauschen oder jede Zahl ungleich null als true interpretieren.
- ScriptIndex=0 bezeichnet den ersten aktuellen Lauf, nicht unbedingt den Aufrufer. SetScriptName ändert den Anzeigenamen, nicht den Dateinamen.

### Interne Funktionen: vom Aufruf zum Ergebnis

Es folgen tatsächliche Clientmethoden. Die Basic-Beispiele enthalten vollständige Helfer; interne C#-Methodennamen sind keine zusätzlichen Skriptbefehle.

#### 1. ExecuteStealthCompatibility

Die Runtime ruft den registrierten UO-Befehl auf und verpackt das Brückenergebnis als Integer, String oder Array.

String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich einen leeren Namen haben.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetScriptName

Die Brücke verwendet den Ausführungsmanager dieses Clients.

ScriptIndex=0 bezeichnet den ersten aktuellen Lauf, nicht unbedingt den Aufrufer. SetScriptName ändert den Anzeigenamen, nicht den Dateinamen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

Indizes sind aktuelle Positionen in Startreihenfolge. Starts und Stopps können Positionen verschieben. Einzelne Aufrufe bilden keinen atomaren Gesamtschnappschuss; vor späteren Steuerbefehlen neu lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; Funktion `GetScriptName`.

Das Schließen der Basic IDE entfernt aktive Ausführungen nicht. Diese Befehle betreffen diesen Client, keine anderen Clients oder Windows-Prozesse.


## Beispiele

### Erster Aufruf und Ergebnis

```vb
# Erster Aufruf und Ergebnis
#
# Liest den Anzeigenamen einer aktiven Ausführung.
#
# String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich
# einen leeren Namen haben.

SUB Main()
    # Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente.
    # Print-Texte sind Beispielmeldungen.
    # ScriptIndex=0 bezeichnet den ersten aktuellen Lauf, nicht unbedingt den Aufrufer.
    # SetScriptName ändert den Anzeigenamen, nicht den Dateinamen.
    # String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich
    # einen leeren Namen haben.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Sub Main ausführen. Übergebene 0 ist ein Index; leere Klammern bedeuten keine Argumente. Print-Texte sind Beispielmeldungen.
- ScriptIndex=0 bezeichnet den ersten aktuellen Lauf, nicht unbedingt den Aufrufer. SetScriptName ändert den Anzeigenamen, nicht den Dateinamen.
- String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich einen leeren Namen haben.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

### Schleife oder Bedingung

```vb
# Schleife oder Bedingung
#
# Liest den Anzeigenamen einer aktiven Ausführung.
#
# String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich
# einen leeren Namen haben.

SUB Main()
    # Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff
    # die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
    # ScriptIndex=0 bezeichnet den ersten aktuellen Lauf, nicht unbedingt den Aufrufer.
    # SetScriptName ändert den Anzeigenamen, nicht den Dateinamen.
    # String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich
    # einen leeren Namen haben.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Eigenständiges Beispiel mit mehreren Befehlen. Arrayindizes beginnen bei null; vor dem Zugriff die Länge prüfen. Wait(250) wartet gegebenenfalls 250 Millisekunden.
- ScriptIndex=0 bezeichnet den ersten aktuellen Lauf, nicht unbedingt den Aufrufer. SetScriptName ändert den Anzeigenamen, nicht den Dateinamen.
- String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich einen leeren Namen haben.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Liest den Anzeigenamen einer aktiven Ausführung.
#
# String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich
# einen leeren Namen haben.

SUB Main()
    # Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten
    # API-Befehl zu unterscheiden.
    # DescribeScript prüft den Zustand und verbindet Name und Pfad. Ein Stopp kann dazwischen
    # erfolgen; "missing" stammt vom Helfer, nicht von GetScriptName.
    # String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich
    # einen leeren Namen haben.
    # Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative
    # oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine
    # Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Funktion steht unter Main. Ihre Parameter und Rückgaben sind vom verwendeten API-Befehl zu unterscheiden.
- DescribeScript prüft den Zustand und verbindet Name und Pfad. Ein Stopp kann dazwischen erfolgen; "missing" stammt vom Helfer, nicht von GetScriptName.
- String: Anzeigename oder "", wenn der Index fehlt. Auch ein vorhandener Lauf kann ausdrücklich einen leeren Namen haben.
- Erforderlicher ganzzahliger ScriptIndex ab null aus einem aktuellen GetScriptsList. Negative oder fehlende Indizes liefern den dokumentierten leeren/unbekannten Wert. Keine Gegenstands-Serial, Prozedurnamen oder IDE-Lauf-ID übergeben.
