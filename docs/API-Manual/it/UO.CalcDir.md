# UO.CalcDir

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Calcola la direzione tra due punti del mondo senza muovere il personaggio.

## Sintassi esatta

```text
UO.CalcDir(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parametri

- `Xfrom` — X iniziale.
- `Yfrom` — Y iniziale.
- `Xto` — X di destinazione.
- `Yto` — Y di destinazione.

## Restituisce

Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100. Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come direzione di un passo.

## Comportamento

- Calcolo puro senza pacchetti, attese, caricamento mappe, ostacoli, Z o controllo del mondo. Non trova un percorso praticabile né garantisce l’arrivo. I punti devono condividere il sistema di coordinate; una deviazione può essere più lunga.
- Servono tutti e quattro i parametri: coordinate mondiali Integer nell’intervallo documentato 0..65535. Any indica l’adattatore, non un ID. Nessun valore predefinito, coordinata del contenitore, quinto Z o overload con un solo oggetto.
- Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze. Entrambe le differenze nulle danno 100.

### Funzioni interne: dalla chiamata al risultato

Il terzo esempio ricostruisce l’algoritmo in una funzione dello script; non rappresenta una funzione interna richiamata con quel nome.

#### 1. ExecuteStealthCompatibility

L’adattatore legge gli argomenti 0..3 come interi Xfrom,Yfrom,Xto,Yto e chiama la funzione di calcolo.

Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100. Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come direzione di un passo.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. CalculateDirection

`CalculateDirection: dx=Math.Sign(toX-fromX); dy=Math.Sign(toY-fromY); identical ->100; axis/sign branches ->0..7.`

Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze. Entrambe le differenze nulle danno 100.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `CalculateDirection`.

Calcolo puro senza pacchetti, attese, caricamento mappe, ostacoli, Z o controllo del mondo. Non trova un percorso praticabile né garantisce l’arrivo. I punti devono condividere il sistema di coordinate; una deviazione può essere più lunga.


## Esempi

### Calcolo diretto

```vb
# Calcolo diretto
#
# Calcola la direzione tra due punti del mondo senza muovere il personaggio.
#
# Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100.
# Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come
# direzione di un passo.

SUB Main()
    # Da (100,100) a (101,100) aumenta solo X. Main restituisce Integer 2, est, senza movimento.
    # Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100.
    # Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come
    # direzione di un passo.
    # Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta
    # verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze.
    # Entrambe le differenze nulle danno 100.

    Return UO.CalcDir(100,100,101,100)
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Da (100,100) a (101,100) aumenta solo X. Main restituisce Integer 2, est, senza movimento.
- Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100. Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come direzione di un passo.
- Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze. Entrambe le differenze nulle danno 100.

### Interpretare il risultato

```vb
# Interpretare il risultato
#
# Calcola la direzione tra due punti del mondo senza muovere il personaggio.
#
# Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100.
# Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come
# direzione di un passo.

SUB Main()
    # Entrambi i punti (100,100) danno direction=100 e Main restituisce "already there". Punti
    # diversi usano l’altro ramo. Confrontare con 100, non True.
    # Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100.
    # Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come
    # direzione di un passo.
    # Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta
    # verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze.
    # Entrambe le differenze nulle danno 100.

    Dim direction=UO.CalcDir(100,100,100,100)
    If direction=100 Then
        Return "already there"
    End If
    Return "different point"
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Entrambi i punti (100,100) danno direction=100 e Main restituisce "already there". Punti diversi usano l’altro ramo. Confrontare con 100, non True.
- Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100. Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come direzione di un passo.
- Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze. Entrambe le differenze nulle danno 100.

### Algoritmo completo

```vb
# Algoritmo completo
#
# Calcola la direzione tra due punti del mondo senza muovere il personaggio.
#
# Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100.
# Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come
# direzione di un passo.

SUB Main()
    # Da (20,20) a (19,21), X diminuisce e Y aumenta. UO.CalcDir e RebuildDirection restituiscono 5;
    # Main restituisce "5:5". L’aiutante completo mostra ogni ramo con gli stessi quattro parametri.
    # Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100.
    # Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come
    # direzione di un passo.
    # Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta
    # verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze.
    # Entrambe le differenze nulle danno 100.

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

**Spiegazione dei parametri e dell’esecuzione:**

- Da (20,20) a (19,21), X diminuisce e Y aumenta. UO.CalcDir e RebuildDirection restituiscono 5; Main restituisce "5:5". L’aiutante completo mostra ogni ramo con gli stessi quattro parametri.
- Codice Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Punti uguali restituiscono 100. Non è Boolean: 0 significa nord, non errore; 1 nord-est, non successo. Non usare 100 come direzione di un passo.
- Sottrae l’origine dalla destinazione e controlla i segni. Y diminuisce verso nord, X aumenta verso est. Cambiare entrambi gli assi sceglie una diagonale indipendentemente dalle ampiezze. Entrambe le differenze nulle danno 100.
