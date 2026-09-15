# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Cerca gli oggetti caricati in una precisa cella X/Y della mappa corrente.

## Sintassi esatta

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## Parametri

- `X` — coordinata orizzontale del mondo, Integer 0..65535. Obbligatoria; non è una posizione in pixel nella finestra del contenitore.
- `Y` — coordinata verticale del mondo, Integer 0..65535. Obbligatoria. Nessun parametro aggiuntivo per Z, mappa, tipo o raggio.

## Restituisce

Integer: serial del primo oggetto corrispondente nell’elenco di questo client. 0 indica nessun risultato, personaggio assente/rimosso o coordinate fuori da 0..65535. È un ID, non un tipo, una quantità o un Boolean. Conserva tutti i 32 bit: verificare <> 0, non = TRUE o > 0. Lo stesso ID diventa FindItem().

## Comportamento

- Esamina Items non rimossi a terra e Mobiles, incluso il personaggio presente nella cella. Esclude contenuto dei contenitori ed equipaggiamento: i loro X/Y non sono coordinate del mondo. Esclude i serial ignorati.
- Sono ammesse tutte le altezze Z agli X/Y esatti. FindDistance e FindVertical non limitano questa ricerca. Vede solo oggetti caricati del mondo corrente; non carica terreno, elementi statici o altre mappe. Non invia pacchetti, apre target o sposta oggetti.
- Ogni chiamata cancella prima la ricerca precedente. FindCount() conta gli oggetti, FindFullQuantity() somma le unità nelle pile (un Mobile vale uno), GetFoundItems() fornisce i serial. Prima Items, poi Mobiles, nell’ordine corrente delle collezioni. Salvare l’elenco prima di un’altra ricerca.
- Riferimento: [Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/). Ordine e filtri descritti sopra si riferiscono a questo client.

### Funzioni interne: dalla chiamata al risultato

Questi sono i passaggi interni reali. CountGraphicAt è una funzione di script definita per intero, non un altro comando integrato.

#### 1. ExecuteStealthCompatibility

Il percorso registrato converte i due argomenti X/Y posizionali o nominati e restituisce l’Integer del bridge.

Integer: serial del primo oggetto corrispondente nell’elenco di questo client. 0 indica nessun risultato, personaggio assente/rimosso o coordinate fuori da 0..65535. È un ID, non un tipo, una quantità o un Boolean. Conserva tutti i 32 bit: verificare <> 0, non = TRUE o > 0. Lo stesso ID diventa FindItem().

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

Sul thread del gioco cancella i risultati, verifica personaggio e coordinate e cerca gli Items a terra e i Mobiles corrispondenti. Il contenuto dei contenitori è escluso.

Esamina Items non rimossi a terra e Mobiles, incluso il personaggio presente nella cella. Esclude contenuto dei contenitori ed equipaggiamento: i loro X/Y non sono coordinate del mondo. Esclude i serial ignorati.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindAtCoord`.

#### 3. RegisterFound

Ogni risultato aumenta il contatore e aggiunge il serial. Il primo resta FindItem; Item.Amount contribuisce almeno una unità, un Mobile una.

Ogni chiamata cancella prima la ricerca precedente. FindCount() conta gli oggetti, FindFullQuantity() somma le unità nelle pile (un Mobile vale uno), GetFoundItems() fornisce i serial. Prima Items, poi Mobiles, nell’ordine corrente delle collezioni. Salvare l’elenco prima di un’altra ricerca.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `RegisterFound`.

Sono ammesse tutte le altezze Z agli X/Y esatti. FindDistance e FindVertical non limitano questa ricerca. Vede solo oggetti caricati del mondo corrente; non carica terreno, elementi statici o altre mappe. Non invia pacchetti, apre target o sposta oggetti.


## Esempi

### Leggere un ID

```vb
# Leggere un ID
#
# Cerca gli oggetti caricati in una precisa cella X/Y della mappa corrente.
#
# Integer: serial del primo oggetto corrispondente nell’elenco di questo client. 0 indica nessun
# risultato, personaggio assente/rimosso o coordinate fuori da 0..65535. È un ID, non un tipo,
# una quantità o un Boolean. Conserva tutti i 32 bit: verificare <> 0, non = TRUE o > 0. Lo
# stesso ID diventa FindItem().

SUB Main()
    # 1445 e 1690 sono X/Y di esempio: sostituirli con la propria cella. id conserva un serial, HEX
    # lo formatta. <> 0 controlla un risultato, non una quantità.

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- 1445 e 1690 sono X/Y di esempio: sostituirli con la propria cella. id conserva un serial, HEX lo formatta. <> 0 controlla un risultato, non una quantità.

### Esaminare la cella del personaggio

```vb
# Esaminare la cella del personaggio
#
# Cerca gli oggetti caricati in una precisa cella X/Y della mappa corrente.
#
# Integer: serial del primo oggetto corrispondente nell’elenco di questo client. 0 indica nessun
# risultato, personaggio assente/rimosso o coordinate fuori da 0..65535. È un ID, non un tipo,
# una quantità o un Boolean. Conserva tutti i 32 bit: verificare <> 0, non = TRUE o > 0. Lo
# stesso ID diventa FindItem().

SUB Main()
    # x/y provengono dal personaggio; ids salva l’elenco. Ogni ID identifica un oggetto, anche una
    # pila intera. GetType(id) legge graphic/body. Nessun oggetto viene selezionato o usato.

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- x/y provengono dal personaggio; ids salva l’elenco. Ogni ID identifica un oggetto, anche una pila intera. GetType(id) legge graphic/body. Nessun oggetto viene selezionato o usato.

### Funzione completa CountGraphicAt

```vb
# Funzione completa CountGraphicAt
#
# Cerca gli oggetti caricati in una precisa cella X/Y della mappa corrente.
#
# Integer: serial del primo oggetto corrispondente nell’elenco di questo client. 0 indica nessun
# risultato, personaggio assente/rimosso o coordinate fuori da 0..65535. È un ID, non un tipo,
# una quantità o un Boolean. Conserva tutti i 32 bit: verificare <> 0, non = TRUE o > 0. Lo
# stesso ID diventa FindItem().

SUB Main()
    # CountGraphicAt(x, y, graphic) cerca una volta e conta negli ID salvati gli oggetti con quella
    # grafica. graphic=0x0EED indica oro. Restituisce un numero di oggetti/pile, non la somma delle
    # unità né true/false; una pila vale uno. Definizione completa dopo Main.

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- CountGraphicAt(x, y, graphic) cerca una volta e conta negli ID salvati gli oggetti con quella grafica. graphic=0x0EED indica oro. Restituisce un numero di oggetti/pile, non la somma delle unità né true/false; una pila vale uno. Definizione completa dopo Main.
