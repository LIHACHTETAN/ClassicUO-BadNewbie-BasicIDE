# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Cerca grafiche, colori e contenitori alternativi in un passaggio e restituisce un ID. GetFoundItems fornisce la lista completa.

## Sintassi esatta

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## Parametri

- `ObjTypes` — Graphic/body, non il serial di un oggetto. 0..65534 indica una grafica; -1 o 0xFFFF qualsiasi grafica. Anche altri Integer negativi sono jolly.
- `Colors` — Hue, non quantità. 0 indica senza tinta; -1 o 0xFFFF qualsiasi hue. Anche altri Integer negativi eliminano il filtro.
- `Containers` — Terreno: UO.Ground(), 0, -1, 0xFFFFFFFF o stringa ground. Zaino: backpack o il suo serial. Ammessi serial decimali/hex e nomi AddObject. my seleziona tutto l’inventario posseduto, equipaggiamento e borse annidate compresi. Un nome sconosciuto genera un errore di script. Controllare il serial risolto: 0 esplicito seleziona il terreno. Preferire ground/backpack alle convenzioni numeriche diverse tra API.
- `InSub` — TRUE/FALSE (1/0), obbligatorio. FALSE cerca il contenuto diretto di un contenitore preciso; TRUE anche le borse annidate caricate. Nessun effetto sul terreno. my comprende già tutto l’inventario posseduto.

## Restituisce

Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità, array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né stabilità.

## Comportamento

- Passare un Array; uno scalare è accettato come un elemento. DIM values[1] crea gli indici 0 e 1: assegnarli tutti. Tipi e colori sono alternative indipendenti, non coppie per indice. Un jolly ovunque, oppure un array tipi/colori vuoto, elimina quel filtro. Un array contenitori vuoto seleziona l’inventario posseduto. Ripetizioni e sovrapposizioni non duplicano gli ID.
- Tutti e quattro gli argomenti posizionali sono obbligatori.
- Sul terreno valgono FindDistance/FindVertical dello script; self è escluso, Item e Mobile corrispondenti sono inclusi. Un contenitore preciso non applica questi limiti di distanza/altezza. Ignore e oggetti distrutti sono sempre esclusi.
- Prima della scansione si azzerano FindItem, FindCount, FindFullQuantity e GetFoundItems. Una ricerca vuota lascia zeri e un array vuoto. FindFullQuantity somma max(1, Amount) per Item e 1 per Mobile. FindQuantity legge la quantità attuale di FindItem. Salvare GetFoundItems prima che un’altra ricerca sostituisca lo stato.
- Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.
- Solo dati già ricevuti: non apre contenitori, non carica celle e non trasferisce oggetti. Nessun risultato non prova che il forziere sia vuoto sul server. Controllare Connected quando serve una connessione attiva; la ricerca legge lo stato locale.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). Il riferimento descrive l’ultimo ID e lo zaino come ripiego per contenitori invalidi. Qui si conserva il primo risultato locale; un nome sconosciuto non seleziona lo zaino. Ground accetta anche 0; FindDistance locale parte da 18, massimo 255.

### Funzioni interne: dalla chiamata al risultato

Fasi reali, non ulteriori comandi pubblici. FindGoldNearSelf e SearchTypesIn sono funzioni di script interamente definite sotto.

#### 1. ExecuteStealthCompatibility

Il runtime converte i filtri numerici e risolve separatamente i nomi; il terreno diventa l’ambito mondo interno del bridge.

Tutti e quattro gli argomenti posizionali sono obbligatori.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

Terreno: UO.Ground(), 0, -1, 0xFFFFFFFF o stringa ground. Zaino: backpack o il suo serial. Ammessi serial decimali/hex e nomi AddObject. my seleziona tutto l’inventario posseduto, equipaggiamento e borse annidate compresi. Un nome sconosciuto genera un errore di script. Controllare il serial risolto: 0 esplicito seleziona il terreno. Preferire ground/backpack alle convenzioni numeriche diverse tra API.

Il runtime converte i filtri numerici e risolve separatamente i nomi; il terreno diventa l’ambito mondo interno del bridge.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

Prima della scansione si azzerano FindItem, FindCount, FindFullQuantity e GetFoundItems. Una ricerca vuota lascia zeri e un array vuoto. FindFullQuantity somma max(1, Amount) per Item e 1 per Mobile. FindQuantity legge la quantità attuale di FindItem. Salvare GetFoundItems prima che un’altra ricerca sostituisca lo stato.

Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità, array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né stabilità.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `ResetFindResults`.

#### 4. BuildFindIdentityMask

Passare un Array; uno scalare è accettato come un elemento. DIM values[1] crea gli indici 0 e 1: assegnarli tutti. Tipi e colori sono alternative indipendenti, non coppie per indice. Un jolly ovunque, oppure un array tipi/colori vuoto, elimina quel filtro. Un array contenitori vuoto seleziona l’inventario posseduto. Ripetizioni e sovrapposizioni non duplicano gli ID.

Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `BuildFindIdentityMask`.

#### 5. FindTypes

Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.

Sul terreno valgono FindDistance/FindVertical dello script; self è escluso, Item e Mobile corrispondenti sono inclusi. Un contenitore preciso non applica questi limiti di distanza/altezza. Ignore e oggetti distrutti sono sempre esclusi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body, non il serial di un oggetto. 0..65534 indica una grafica; -1 o 0xFFFF qualsiasi grafica. Anche altri Integer negativi sono jolly. Hue, non quantità. 0 indica senza tinta; -1 o 0xFFFF qualsiasi hue. Anche altri Integer negativi eliminano il filtro.

Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `MatchesFindIdentity`.

#### 7. MatchesFindContainer

TRUE/FALSE (1/0), obbligatorio. FALSE cerca il contenuto diretto di un contenitore preciso; TRUE anche le borse annidate caricate. Nessun effetto sul terreno. my comprende già tutto l’inventario posseduto.

Sul terreno valgono FindDistance/FindVertical dello script; self è escluso, Item e Mobile corrispondenti sono inclusi. Un contenitore preciso non applica questi limiti di distanza/altezza. Ignore e oggetti distrutti sono sempre esclusi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `MatchesFindContainer`.

#### 8. RegisterFound

Prima della scansione si azzerano FindItem, FindCount, FindFullQuantity e GetFoundItems. Una ricerca vuota lascia zeri e un array vuoto. FindFullQuantity somma max(1, Amount) per Item e 1 per Mobile. FindQuantity legge la quantità attuale di FindItem. Salvare GetFoundItems prima che un’altra ricerca sostituisca lo stato.

Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità, array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né stabilità.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `RegisterFound`.

Solo dati già ricevuti: non apre contenitori, non carica celle e non trasferisce oggetti. Nessun risultato non prova che il forziere sia vuoto sul server. Controllare Connected quando serve una connessione attiva; la ricerca legge lo stato locale.


## Esempi

### Due grafiche sul terreno

```vb
# Due grafiche sul terreno
#
# Cerca grafiche, colori e contenitori alternativi in un passaggio e restituisce un ID.
# GetFoundItems fornisce la lista completa.
#
# Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità,
# array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come
# un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né
# stabilità.

SUB Main()
    # types contiene oro 0x0EED e perla nera 0x0F7A; color=-1 accetta ogni hue, Ground seleziona il
    # mondo. FALSE qui non cambia nulla. Valgono i limiti correnti. Stampa ID, oggetti e unità.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- types contiene oro 0x0EED e perla nera 0x0F7A; color=-1 accetta ogni hue, Ground seleziona il mondo. FALSE qui non cambia nulla. Valgono i limiti correnti. Stampa ID, oggetti e unità.

### Oro nello zaino e sul terreno

```vb
# Oro nello zaino e sul terreno
#
# Cerca grafiche, colori e contenitori alternativi in un passaggio e restituisce un ID.
# GetFoundItems fornisce la lista completa.
#
# Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità,
# array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come
# un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né
# stabilità.

SUB Main()
    # types contiene solo oro, colors tutti gli hue. Containers contiene backpack e terreno; TRUE
    # include borse interne. Stampa oggetti/pile e unità dei due ambiti senza duplicare oggetti.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- types contiene solo oro, colors tutti gli hue. Containers contiene backpack e terreno; TRUE include borse interne. Stampa oggetti/pile e unità dei due ambiti senza duplicare oggetti.

### Funzione completa con lista salvata

```vb
# Funzione completa con lista salvata
#
# Cerca grafiche, colori e contenitori alternativi in un passaggio e restituisce un ID.
# GetFoundItems fornisce la lista completa.
#
# Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità,
# array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come
# un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né
# stabilità.

SUB Main()
    # SearchTypesIn(container,firstType,secondType) restituisce Array<Integer>, mentre il comando
    # integrato restituisce un unico Integer ID. Il codice completo riempie gli array, cerca
    # ricorsivamente e copia subito GetFoundItems. Main controlla e stampa ciascun ID.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- SearchTypesIn(container,firstType,secondType) restituisce Array<Integer>, mentre il comando integrato restituisce un unico Integer ID. Il codice completo riempie gli array, cerca ricorsivamente e copia subito GetFoundItems. Main controlla e stampa ciascun ID.
