# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Cerca una grafica/colore in un contenitore o sul terreno e restituisce un ID corrispondente.

## Sintassi esatta

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## Parametri

- `ObjType` — Graphic/body, non il serial di un oggetto. 0..65534 indica una grafica; -1 o 0xFFFF qualsiasi grafica. Anche altri Integer negativi sono jolly.
- `Color` — Hue, non quantità. 0 indica senza tinta; -1 o 0xFFFF qualsiasi hue. Anche altri Integer negativi eliminano il filtro.
- `Container` — Terreno: UO.Ground(), 0, -1, 0xFFFFFFFF o stringa ground. Zaino: backpack o il suo serial. Ammessi serial decimali/hex e nomi AddObject. my seleziona tutto l’inventario posseduto, equipaggiamento e borse annidate compresi. Un nome sconosciuto genera un errore di script. Controllare il serial risolto: 0 esplicito seleziona il terreno. Preferire ground/backpack alle convenzioni numeriche diverse tra API.
- `InSub` — TRUE/FALSE (1/0), obbligatorio. FALSE cerca il contenuto diretto di un contenitore preciso; TRUE anche le borse annidate caricate. Nessun effetto sul terreno. my comprende già tutto l’inventario posseduto.

## Restituisce

Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità, array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né stabilità.

## Comportamento

- Tutti e quattro gli argomenti posizionali sono obbligatori.
- Sul terreno valgono FindDistance/FindVertical dello script; self è escluso, Item e Mobile corrispondenti sono inclusi. Un contenitore preciso non applica questi limiti di distanza/altezza. Ignore e oggetti distrutti sono sempre esclusi.
- Prima della scansione si azzerano FindItem, FindCount, FindFullQuantity e GetFoundItems. Una ricerca vuota lascia zeri e un array vuoto. FindFullQuantity somma max(1, Amount) per Item e 1 per Mobile. FindQuantity legge la quantità attuale di FindItem. Salvare GetFoundItems prima che un’altra ricerca sostituisca lo stato.
- Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.
- Solo dati già ricevuti: non apre contenitori, non carica celle e non trasferisce oggetti. Nessun risultato non prova che il forziere sia vuoto sul server. Controllare Connected quando serve una connessione attiva; la ricerca legge lo stato locale.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). Il riferimento descrive l’ultimo ID e lo zaino come ripiego per contenitori invalidi. Qui si conserva il primo risultato locale; un nome sconosciuto non seleziona lo zaino. Ground accetta anche 0; FindDistance locale parte da 18, massimo 255.

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

#### 4. FindType

Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.

Sul terreno valgono FindDistance/FindVertical dello script; self è escluso, Item e Mobile corrispondenti sono inclusi. Un contenitore preciso non applica questi limiti di distanza/altezza. Ignore e oggetti distrutti sono sempre esclusi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindType`.

#### 5. MatchesFindIdentity

Graphic/body, non il serial di un oggetto. 0..65534 indica una grafica; -1 o 0xFFFF qualsiasi grafica. Anche altri Integer negativi sono jolly. Hue, non quantità. 0 indica senza tinta; -1 o 0xFFFF qualsiasi hue. Anche altri Integer negativi eliminano il filtro.

Il bridge percorre una volta gli Item caricati, poi i Mobile se è selezionato il terreno. Devono corrispondere tipo, colore e almeno un contenitore. Ogni oggetto viene registrato una volta; nessuna scansione completa del mondo per ogni combinazione.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `MatchesFindIdentity`.

#### 6. MatchesFindContainer

TRUE/FALSE (1/0), obbligatorio. FALSE cerca il contenuto diretto di un contenitore preciso; TRUE anche le borse annidate caricate. Nessun effetto sul terreno. my comprende già tutto l’inventario posseduto.

Sul terreno valgono FindDistance/FindVertical dello script; self è escluso, Item e Mobile corrispondenti sono inclusi. Un contenitore preciso non applica questi limiti di distanza/altezza. Ignore e oggetti distrutti sono sempre esclusi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `MatchesFindContainer`.

#### 7. RegisterFound

Prima della scansione si azzerano FindItem, FindCount, FindFullQuantity e GetFoundItems. Una ricerca vuota lascia zeri e un array vuoto. FindFullQuantity somma max(1, Amount) per Item e 1 per Mobile. FindQuantity legge la quantità attuale di FindItem. Salvare GetFoundItems prima che un’altra ricerca sostituisca lo stato.

Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità, array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né stabilità.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `RegisterFound`.

Solo dati già ricevuti: non apre contenitori, non carica celle e non trasferisce oggetti. Nessun risultato non prova che il forziere sia vuoto sul server. Controllare Connected quando serve una connessione attiva; la ricerca legge lo stato locale.


## Esempi

### Contenuto diretto dello zaino

```vb
# Contenuto diretto dello zaino
#
# Cerca una grafica/colore in un contenitore o sul terreno e restituisce un ID corrispondente.
#
# Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità,
# array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come
# un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né
# stabilità.

SUB Main()
    # 0x0EED è oro; -1 qualsiasi hue; backpack/FALSE esclude borse annidate. Stampa primo ID hex
    # senza 0x, oggetti e unità. Pile da 20 e 50 producono 2 oggetti e 70 unità.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- 0x0EED è oro; -1 qualsiasi hue; backpack/FALSE esclude borse annidate. Stampa primo ID hex senza 0x, oggetti e unità. Pile da 20 e 50 producono 2 oggetti e 70 unità.

### Funzione completa di ricerca temporanea sul terreno

```vb
# Funzione completa di ricerca temporanea sul terreno
#
# Cerca una grafica/colore in un contenitore o sul terreno e restituisce un ID corrispondente.
#
# Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità,
# array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come
# un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né
# stabilità.

SUB Main()
    # radius=5 e height=10 valgono dentro FindGoldNearSelf. Finally ripristina entrambi anche con
    # Return o errore. Restituisce un serial d’oro o 0; Main verifica <> 0.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- radius=5 e height=10 valgono dentro FindGoldNearSelf. Finally ripristina entrambi anche con Return o errore. Restituisce un serial d’oro o 0; Main verifica <> 0.

### Contenitore nominato e borse interne

```vb
# Contenitore nominato e borse interne
#
# Cerca una grafica/colore in un contenitore o sul terreno e restituisce un ID corrispondente.
#
# Integer: serial del primo risultato locale, oppure 0 senza risultati. Non grafica, quantità,
# array o Boolean. Verificare result <> 0, non result = TRUE o result = 1. Una pila conta come
# un oggetto; un Mobile come un oggetto e un’unità. L’ordine non garantisce vicinanza né
# stabilità.

SUB Main()
    # GetSerial risolve backpack; il controllo di zero evita il terreno accidentale. AddObject salva
    # search_bag. TRUE include borse interne. GetFoundItems copia la lista; IsObjectExists
    # ricontrolla ogni ID.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- GetSerial risolve backpack; il controllo di zero evita il terreno accidentale. AddObject salva search_bag. TRUE include borse interne. GetFoundItems copia la lista; IsObjectExists ricontrolla ogni ID.
