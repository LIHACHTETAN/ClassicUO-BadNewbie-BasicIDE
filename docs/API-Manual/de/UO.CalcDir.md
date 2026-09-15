# UO.CalcDir

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Berechnet die Richtung zwischen zwei Weltpunkten, ohne die Figur zu bewegen.

## Genaue Syntax

```text
UO.CalcDir(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parameter

- `Xfrom` — X des Startpunkts.
- `Yfrom` — Y des Startpunkts.
- `Xto` — X des Zielpunkts.
- `Yto` — Y des Zielpunkts.

## Rückgabewert

Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals als Schrittrichtung verwenden.

## Verhalten

- Reine Berechnung ohne Pakete, Warten, Kartenladen, Hindernis-, Z- oder Facettenprüfung. Kein begehbarer Weg und keine Ankunftsgarantie. Punkte müssen im gleichen Koordinatensystem liegen; Umwege können länger sein.
- Alle vier Parameter sind nötig: Integer-Weltkoordinaten im dokumentierten Bereich 0..65535. Any bezeichnet den Adapter, keine Objekt-ID. Keine Vorgaben, Containerkoordinaten, fünfte Z-Koordinate oder Ein-Objekt-Überladung.
- Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten. Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen liefern 100.

### Interne Funktionen: vom Aufruf zum Ergebnis

Beispiel 3 rekonstruiert den Algorithmus als Skriptfunktion. Der Interpreter ruft intern nicht diesen Lernhelfer auf.

#### 1. ExecuteStealthCompatibility

Der Adapter liest Argumente 0..3 als ganze Zahlen Xfrom,Yfrom,Xto,Yto und ruft den Berechnungshelfer auf.

Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals als Schrittrichtung verwenden.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. CalculateDirection

`CalculateDirection: dx=Math.Sign(toX-fromX); dy=Math.Sign(toY-fromY); identical ->100; axis/sign branches ->0..7.`

Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten. Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen liefern 100.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `CalculateDirection`.

Reine Berechnung ohne Pakete, Warten, Kartenladen, Hindernis-, Z- oder Facettenprüfung. Kein begehbarer Weg und keine Ankunftsgarantie. Punkte müssen im gleichen Koordinatensystem liegen; Umwege können länger sein.


## Beispiele

### Direkt berechnen

```vb
# Direkt berechnen
#
# Berechnet die Richtung zwischen zwei Weltpunkten, ohne die Figur zu bewegen.
#
# Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein
# Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals
# als Schrittrichtung verwenden.

SUB Main()
    # (100,100) nach (101,100): nur X wächst. Main liefert Integer 2, Osten, ohne Bewegung.
    # Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein
    # Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals
    # als Schrittrichtung verwenden.
    # Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten.
    # Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen
    # liefern 100.

    Return UO.CalcDir(100,100,101,100)
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- (100,100) nach (101,100): nur X wächst. Main liefert Integer 2, Osten, ohne Bewegung.
- Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals als Schrittrichtung verwenden.
- Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten. Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen liefern 100.

### Ergebnis richtig prüfen

```vb
# Ergebnis richtig prüfen
#
# Berechnet die Richtung zwischen zwei Weltpunkten, ohne die Figur zu bewegen.
#
# Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein
# Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals
# als Schrittrichtung verwenden.

SUB Main()
    # Beide Punkte (100,100) ergeben direction=100. Main liefert "already there"; bei verschiedenen
    # Punkten gilt der andere Zweig. Mit 100 vergleichen, nicht mit True.
    # Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein
    # Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals
    # als Schrittrichtung verwenden.
    # Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten.
    # Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen
    # liefern 100.

    Dim direction=UO.CalcDir(100,100,100,100)
    If direction=100 Then
        Return "already there"
    End If
    Return "different point"
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Beide Punkte (100,100) ergeben direction=100. Main liefert "already there"; bei verschiedenen Punkten gilt der andere Zweig. Mit 100 vergleichen, nicht mit True.
- Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals als Schrittrichtung verwenden.
- Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten. Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen liefern 100.

### Vollständiger Skriptalgorithmus

```vb
# Vollständiger Skriptalgorithmus
#
# Berechnet die Richtung zwischen zwei Weltpunkten, ohne die Figur zu bewegen.
#
# Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein
# Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals
# als Schrittrichtung verwenden.

SUB Main()
    # Von (20,20) nach (19,21) sinkt X und steigt Y. UO.CalcDir und RebuildDirection liefern 5, Main
    # "5:5". Der vollständige Helfer zeigt alle Richtungszweige mit denselben vier
    # Koordinatenparametern.
    # Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein
    # Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals
    # als Schrittrichtung verwenden.
    # Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten.
    # Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen
    # liefern 100.

    Dim actual=UO.CalcDir(20,20,19,21)
    Dim rebuilt=RebuildDirection(20,20,19,21)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildDirection(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Xto-Xfrom
    Dim dy = Yto-Yfrom
    If dx=0 AndAlso dy=0 Then
        Return 100
    End If
    If dx=0 Then
        If dy<0 Then
            Return 0
        End If
        Return 4
    End If
    If dy=0 Then
        If dx>0 Then
            Return 2
        End If
        Return 6
    End If
    If dx>0 Then
        If dy<0 Then
            Return 1
        End If
        Return 3
    End If
    If dy>0 Then
        Return 5
    End If
    Return 7
End Function
```

**Erläuterung der Parameter und Ausführung:**

- Von (20,20) nach (19,21) sinkt X und steigt Y. UO.CalcDir und RebuildDirection liefern 5, Main "5:5". Der vollständige Helfer zeigt alle Richtungszweige mit denselben vier Koordinatenparametern.
- Integer-Richtung: 0=N, 1=NO, 2=O, 3=SO, 4=S, 5=SW, 6=W, 7=NW. Gleiche Punkte liefern 100. Kein Boolean: 0 bedeutet Norden, keinen Fehler; 1 bedeutet Nordosten, keinen Erfolg. 100 niemals als Schrittrichtung verwenden.
- Ziel minus Start bilden und Vorzeichen prüfen. Kleineres Y ist Norden, größeres X Osten. Änderungen beider Achsen liefern eine Diagonale unabhängig von der Größe. Zwei Nulldifferenzen liefern 100.
