# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Restituisce il selettore speciale del terreno per il contenitore di ricerca o la destinazione del trasferimento.

## Sintassi esatta

```text
UO.Ground() -> Integer
```

## Parametri

Nessun parametro.

## Restituisce

Integer, sempre 0. Lo zero indica validamente il terreno, non FALSE, un errore, un ID, una grafica, una mappa o una coordinata. Verificare il risultato della ricerca o del trasferimento, non Ground() come indicatore di successo.

## Comportamento

- Nessun parametro. Ground() da solo non cerca, non sposta, non apre target, non invia pacchetti e non cambia i risultati precedenti. Restituisce 0 anche prima dell’accesso.
- Usarlo in container/destination di FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx o MoveItem. La ricerca vede oggetti caricati senza caricare caselle lontane. X/Y/Z del terreno sono coordinate del mondo, non pixel della finestra del contenitore.
- FindType(type, color) cerca ancora nell’inventario: il secondo argomento è il colore. Terreno: FindType(type, color, UO.Ground()). FindType/MoveItem compatti usano -1 per l’inventario; FindTypeEx/FindTypesArrayEx/CountEx compatibili accettano -1 anche per il terreno. Preferire UO.Ground() o il nome ground alle convenzioni numeriche dei singoli comandi.
- Fonte primaria: [Stealth Ground](https://stealth.od.ua/api/Ground/). Convenzioni ed esempi descrivono questo client.

### Funzioni interne: dalla chiamata al risultato

Operazioni interne reali. FindGroundTypes è una funzione utente completa, non un altro comando integrato.

#### 1. ExecuteStealthCompatibility

La chiamata runtime senza argomenti restituisce Integer 0 senza accedere al bridge.

Integer, sempre 0. Lo zero indica validamente il terreno, non FALSE, un errore, un ID, una grafica, una mappa o una coordinata. Verificare il risultato della ricerca o del trasferimento, non Ground() come indicatore di successo.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

La ricerca compatta traduce 0 esplicito nel terreno interno mantenendo -1 come inventario. L’adattatore compatibile accetta 0 e il vecchio -1 come terreno; i nomi dei contenitori sono risolti separatamente.

FindType(type, color) cerca ancora nell’inventario: il secondo argomento è il colore. Terreno: FindType(type, color, UO.Ground()). FindType/MoveItem compatti usano -1 per l’inventario; FindTypeEx/FindTypesArrayEx/CountEx compatibili accettano -1 anche per il terreno. Preferire UO.Ground() o il nome ground alle convenzioni numeriche dei singoli comandi.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

La ricerca compatta traduce 0 esplicito nel terreno interno mantenendo -1 come inventario. L’adattatore compatibile accetta 0 e il vecchio -1 come terreno; i nomi dei contenitori sono risolti separatamente.

FindType(type, color) cerca ancora nell’inventario: il secondo argomento è il colore. Terreno: FindType(type, color, UO.Ground()). FindType/MoveItem compatti usano -1 per l’inventario; FindTypeEx/FindTypesArrayEx/CountEx compatibili accettano -1 anche per il terreno. Preferire UO.Ground() o il nome ground alle convenzioni numeriche dei singoli comandi.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

La destinazione terreno resta 0. Il bridge usa coordinate del mondo; nel pacchetto di deposito il contenitore è 0xFFFFFFFF. Selettore API e campo del pacchetto sono rappresentazioni diverse.

Sostituire 0x40001001 con il serial di un oggetto accessibile. IsObjectExists verifica che sia caricato. MoveItem(item, amount, destination, X, Y, Z): amount=0 è la pila intera; Ground() è il terreno; GetX/GetY/GetZ leggono la casella del giocatore. result=1 indica richiesta accettata dal client, altrimenti 0; non è Ground() né una conferma del server.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ResolveTransferDestination`.

#### 5. MoveItem

La destinazione terreno resta 0. Il bridge usa coordinate del mondo; nel pacchetto di deposito il contenitore è 0xFFFFFFFF. Selettore API e campo del pacchetto sono rappresentazioni diverse.

Sostituire 0x40001001 con il serial di un oggetto accessibile. IsObjectExists verifica che sia caricato. MoveItem(item, amount, destination, X, Y, Z): amount=0 è la pila intera; Ground() è il terreno; GetX/GetY/GetZ leggono la casella del giocatore. result=1 indica richiesta accettata dal client, altrimenti 0; non è Ground() né una conferma del server.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `MoveItem`.

Nessun parametro. Ground() da solo non cerca, non sposta, non apre target, non invia pacchetti e non cambia i risultati precedenti. Restituisce 0 anche prima dell’accesso.


## Esempi

### Leggere il selettore

```vb
# Leggere il selettore
#
# Restituisce il selettore speciale del terreno per il contenitore di ricerca o la destinazione
# del trasferimento.
#
# Integer, sempre 0. Lo zero indica validamente il terreno, non FALSE, un errore, un ID, una
# grafica, una mappa o una coordinata. Verificare il risultato della ricerca o del
# trasferimento, non Ground() come indicatore di successo.

SUB Main()
    # destination riceve Integer 0; Print lo mostra. Nessun oggetto viene posato.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- destination riceve Integer 0; Print lo mostra. Nessun oggetto viene posato.

### Cercare una pila d’oro a terra

```vb
# Cercare una pila d’oro a terra
#
# Restituisce il selettore speciale del terreno per il contenitore di ricerca o la destinazione
# del trasferimento.
#
# Integer, sempre 0. Lo zero indica validamente il terreno, non FALSE, un errore, un ID, una
# grafica, una mappa o una coordinata. Verificare il risultato della ricerca o del
# trasferimento, non Ground() come indicatore di successo.

SUB Main()
    # 0x0EED: grafica dell’oro; secondo -1: qualsiasi colore. Ground() seleziona il mondo, FALSE
    # esclude la ricorsione. FindTypeEx restituisce un serial o 0; <> 0 verifica quel serial. Si
    # applicano FindDistance/FindVertical e Ignore.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- 0x0EED: grafica dell’oro; secondo -1: qualsiasi colore. Ground() seleziona il mondo, FALSE esclude la ricorsione. FindTypeEx restituisce un serial o 0; <> 0 verifica quel serial. Si applicano FindDistance/FindVertical e Ignore.

### Funzione completa per due grafiche

```vb
# Funzione completa per due grafiche
#
# Restituisce il selettore speciale del terreno per il contenitore di ricerca o la destinazione
# del trasferimento.
#
# Integer, sempre 0. Lo zero indica validamente il terreno, non FALSE, un errore, un ID, una
# grafica, una mappa o una coordinata. Verificare il risultato della ricerca o del
# trasferimento, non Ground() come indicatore di successo.

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) cerca oro 0x0EED e perle nere 0x0F7A
    # con radius=5, height=10. DIM types[1] crea due celle, colors[0] e containers[0] una ciascuno.
    # Una pila è un oggetto; tipi/colori sono alternative e contenitori sovrapposti non duplicano
    # gli ID. Restituisce un array salvato di serial. Finally ripristina i limiti; Main stampa ogni
    # ID. La funzione è completa.

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- FindGroundTypes(firstType, secondType, radius, height) cerca oro 0x0EED e perle nere 0x0F7A con radius=5, height=10. DIM types[1] crea due celle, colors[0] e containers[0] una ciascuno. Una pila è un oggetto; tipi/colori sono alternative e contenitori sovrapposti non duplicano gli ID. Restituisce un array salvato di serial. Finally ripristina i limiti; Main stampa ogni ID. La funzione è completa.

### Posare un oggetto sulla casella del personaggio

```vb
# Posare un oggetto sulla casella del personaggio
#
# Restituisce il selettore speciale del terreno per il contenitore di ricerca o la destinazione
# del trasferimento.
#
# Integer, sempre 0. Lo zero indica validamente il terreno, non FALSE, un errore, un ID, una
# grafica, una mappa o una coordinata. Verificare il risultato della ricerca o del
# trasferimento, non Ground() come indicatore di successo.

SUB Main()
    # Sostituire 0x40001001 con il serial di un oggetto accessibile. IsObjectExists verifica che sia
    # caricato. MoveItem(item, amount, destination, X, Y, Z): amount=0 è la pila intera; Ground() è
    # il terreno; GetX/GetY/GetZ leggono la casella del giocatore. result=1 indica richiesta
    # accettata dal client, altrimenti 0; non è Ground() né una conferma del server.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Sostituire 0x40001001 con il serial di un oggetto accessibile. IsObjectExists verifica che sia caricato. MoveItem(item, amount, destination, X, Y, Z): amount=0 è la pila intera; Ground() è il terreno; GetX/GetY/GetZ leggono la casella del giocatore. result=1 indica richiesta accettata dal client, altrimenti 0; non è Ground() né una conferma del server.
