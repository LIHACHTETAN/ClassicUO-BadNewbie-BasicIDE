# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Calcola la distanza in caselle come maggiore differenza assoluta fra X e Y.

## Sintassi esatta

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parametri

- `Xfrom` — X iniziale.
- `Yfrom` — Y iniziale.
- `Xto` — X di destinazione.
- `Yto` — Y di destinazione.

## Restituisce

Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.

## Comportamento

- Calcolo puro senza pacchetti, attese, caricamento mappe, ostacoli, Z o controllo del mondo. Non trova un percorso praticabile né garantisce l’arrivo. I punti devono condividere il sistema di coordinate; una deviazione può essere più lunga.
- Servono tutti e quattro i parametri: coordinate mondiali Integer nell’intervallo documentato 0..65535. Any indica l’adattatore, non un ID. Nessun valore predefinito, coordinata del contenitore, quinto Z o overload con un solo oggetto.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

### Funzioni interne: dalla chiamata al risultato

Il terzo esempio ricostruisce l’algoritmo in una funzione dello script; non rappresenta una funzione interna richiamata con quel nome.

#### 1. ExecuteStealthCompatibility

L’adattatore legge gli argomenti 0..3 come interi Xfrom,Yfrom,Xto,Yto e chiama la funzione di calcolo.

Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `GetDistance`.

Calcolo puro senza pacchetti, attese, caricamento mappe, ostacoli, Z o controllo del mondo. Non trova un percorso praticabile né garantisce l’arrivo. I punti devono condividere il sistema di coordinate; una deviazione può essere più lunga.


## Esempi

### Calcolo diretto

```vb
# Calcolo diretto
#
# Calcola la distanza in caselle come maggiore differenza assoluta fra X e Y.
#
# Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è
# un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.

SUB Main()
    # Da (100,100) a (103,104), le differenze assolute sono 3 e 4: Main restituisce Integer 4.
    # Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è
    # un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza
    # euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

    Return UO.Dist(100,100,103,104)
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Da (100,100) a (103,104), le differenze assolute sono 3 e 4: Main restituisce Integer 4.
- Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

### Interpretare il risultato

```vb
# Interpretare il risultato
#
# Calcola la distanza in caselle come maggiore differenza assoluta fra X e Y.
#
# Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è
# un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.

SUB Main()
    # Fra (100,100) e (101,99), distanza 1 e confronto distance<=2 uguale a True=1. In "1:1" il
    # primo numero è distanza, il secondo un risultato logico.
    # Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è
    # un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza
    # euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Fra (100,100) e (101,99), distanza 1 e confronto distance<=2 uguale a True=1. In "1:1" il primo numero è distanza, il secondo un risultato logico.
- Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

### Algoritmo completo

```vb
# Algoritmo completo
#
# Calcola la distanza in caselle come maggiore differenza assoluta fra X e Y.
#
# Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è
# un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.

SUB Main()
    # UO.Dist e RebuildTileDistance restituiscono 4; Main restituisce "4:4". L’aiutante completo
    # calcola Abs delle differenze e restituisce la maggiore. È codice d’esempio, non un altro
    # comando API.
    # Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è
    # un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza
    # euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- UO.Dist e RebuildTileDistance restituiscono 4; Main restituisce "4:4". L’aiutante completo calcola Abs delle differenze e restituisce la maggiore. È codice d’esempio, non un altro comando API.
- Distanza Integer non negativa per coordinate valide. 0 indica stessi XY, 1 una casella. Non è un successo Boolean. Il confronto separato distance<=2 produce 1/True o 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Scambiare i punti non cambia il risultato. Non è distanza euclidea, somma delle differenze o lunghezza del percorso attorno a un ostacolo.
