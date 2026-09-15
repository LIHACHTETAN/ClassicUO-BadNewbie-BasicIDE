# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge o modifica la differenza di altezza predefinita ammessa nella ricerca.

## Sintassi esatta

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## Parametri

- `value` — Integer facoltativo. Senza argomento legge; value imposta. Limitato a 0..120; un negativo diventa 0, non illimitato. Nuovo runtime: 2; lo stato ripristinato può differire. I decimali sono troncati verso zero; sono ammesse stringhe numeriche decimal/0x. Usare Integer evita conversioni implicite.

## Restituisce

Senza argomenti: Integer, limite corrente (differenza in unità Z del mondo), non ID, conteggio o Boolean. 0 indica limite zero, non fallimento. Con value: Unit, nessun valore, né TRUE/FALSE né valore precedente. Rileggere FindVertical() dopo la modifica.

## Comportamento

- Altezza: abs(object.Z - player.Z), nelle due direzioni, limite incluso. 0 richiede la stessa Z. Non è il numero del piano né una distanza orizzontale.
- Memorizzato nel runtime dello script, condiviso dalle sue procedure; runtime indipendenti hanno valori separati. Leggere/scrivere non cerca, non cancella FindItem/FindCount/GetFoundItems, non invia pacchetti, non muove il personaggio e non carica oggetti lontani.
- FindTypeEx e FindTypesArrayEx applicano questi limiti a terra, non nei contenitori. Restano tipo, colore, Ignore e oggetti caricati. FindAtCoord ignora entrambi. distance/maxZ espliciti dei comandi estesi possono sostituirli; -1 in quei parametri usa il predefinito, diversamente da assegnare -1 all’impostazione. FindList filtra Z anche nei contenitori; l’eccezione precedente non vale per esso.
- Salvare prima della ricerca temporanea e ripristinare in Finally; nessun annullamento automatico. Finally copre fine normale ed errori intercettabili; non usare l’arresto d’emergenza per la pulizia.
- Riferimento: [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). Questo client conserva valori iniziali/intervalli propri: FindDistance 18 / 0..255; FindVertical 2 / 0..120. Sintassi Basic e filtri estesi descrivono questo progetto.

### Funzioni interne: dalla chiamata al risultato

Passaggi interni reali. CountGroundInRange è una funzione utente completa, non un comando integrato nascosto.

#### 1. ExecuteStealthCompatibility

Senza argomenti legge; con uno converte value e scrive. I metadati distinguono Integer da Unit.

Senza argomenti: Integer, limite corrente (differenza in unità Z del mondo), non ID, conteggio o Boolean. 0 indica limite zero, non fallimento. Con value: Unit, nessun valore, né TRUE/FALSE né valore precedente. Rileggere FindVertical() dopo la modifica.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

Il bridge legge l’impostazione runtime oppure limita e memorizza l’intero, senza esaminare il mondo.

Senza argomenti: Integer, limite corrente (differenza in unità Z del mondo), non ID, conteggio o Boolean. 0 indica limite zero, non fallimento. Con value: Unit, nessun valore, né TRUE/FALSE né valore precedente. Rileggere FindVertical() dopo la modifica.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetFindVertical`.

#### 3. SetFindVertical

Il bridge legge l’impostazione runtime oppure limita e memorizza l’intero, senza esaminare il mondo.

Integer facoltativo. Senza argomento legge; value imposta. Limitato a 0..120; un negativo diventa 0, non illimitato. Nuovo runtime: 2; lo stato ripristinato può differire. I decimali sono troncati verso zero; sono ammesse stringhe numeriche decimal/0x. Usare Integer evita conversioni implicite.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `SetFindVertical`.

#### 4. FindType

La ricerca successiva legge l’impostazione se non è sostituita esplicitamente. Item a terra e Mobile usano i relativi filtri di distanza e altezza.

FindTypeEx e FindTypesArrayEx applicano questi limiti a terra, non nei contenitori. Restano tipo, colore, Ignore e oggetti caricati. FindAtCoord ignora entrambi. distance/maxZ espliciti dei comandi estesi possono sostituirli; -1 in quei parametri usa il predefinito, diversamente da assegnare -1 all’impostazione. FindList filtra Z anche nei contenitori; l’eccezione precedente non vale per esso.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindType`.

#### 5. FindList

La ricerca successiva legge l’impostazione se non è sostituita esplicitamente. Item a terra e Mobile usano i relativi filtri di distanza e altezza.

FindTypeEx e FindTypesArrayEx applicano questi limiti a terra, non nei contenitori. Restano tipo, colore, Ignore e oggetti caricati. FindAtCoord ignora entrambi. distance/maxZ espliciti dei comandi estesi possono sostituirli; -1 in quei parametri usa il predefinito, diversamente da assegnare -1 all’impostazione. FindList filtra Z anche nei contenitori; l’eccezione precedente non vale per esso.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindList`.

Memorizzato nel runtime dello script, condiviso dalle sue procedure; runtime indipendenti hanno valori separati. Leggere/scrivere non cerca, non cancella FindItem/FindCount/GetFoundItems, non invia pacchetti, non muove il personaggio e non carica oggetti lontani.


## Esempi

### Leggere, impostare e osservare i limiti

```vb
# Leggere, impostare e osservare i limiti
#
# Legge o modifica la differenza di altezza predefinita ammessa nella ricerca.
#
# Senza argomenti: Integer, limite corrente (differenza in unità Z del mondo), non ID, conteggio
# o Boolean. 0 indica limite zero, non fallimento. Con value: Unit, nessun valore, né TRUE/FALSE
# né valore precedente. Rileggere FindVertical() dopo la modifica.

SUB Main()
    # previous salva l’impostazione reale. value:=10 imposta un limite normale; 1000 viene ridotto a
    # 120. Print legge separatamente. Finally ripristina previous.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- previous salva l’impostazione reale. value:=10 imposta un limite normale; 1000 viene ridotto a 120. Print legge separatamente. Finally ripristina previous.

### Ricerca temporanea a terra

```vb
# Ricerca temporanea a terra
#
# Legge o modifica la differenza di altezza predefinita ammessa nella ricerca.
#
# Senza argomenti: Integer, limite corrente (differenza in unità Z del mondo), non ID, conteggio
# o Boolean. 0 indica limite zero, non fallimento. Con value: Unit, nessun valore, né TRUE/FALSE
# né valore precedente. Rileggere FindVertical() dopo la modifica.

SUB Main()
    # previous conserva il valore del chiamante. 10 cambia solo FindVertical; l’altro limite resta.
    # 0x0EED: grafica dell’oro; -1: qualsiasi colore; Container=-1: mondo; FALSE: nessuna ricorsione
    # dei contenitori. id è un serial; <> 0 verifica la presenza. FindCount conta oggetti/pile.
    # Finally ripristina il limite, non la lista.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- previous conserva il valore del chiamante. 10 cambia solo FindVertical; l’altro limite resta. 0x0EED: grafica dell’oro; -1: qualsiasi colore; Container=-1: mondo; FALSE: nessuna ricorsione dei contenitori. id è un serial; <> 0 verifica la presenza. FindCount conta oggetti/pile. Finally ripristina il limite, non la lista.

### Funzione completa CountGroundInRange

```vb
# Funzione completa CountGroundInRange
#
# Legge o modifica la differenza di altezza predefinita ammessa nella ricerca.
#
# Senza argomenti: Integer, limite corrente (differenza in unità Z del mondo), non ID, conteggio
# o Boolean. 0 indica limite zero, non fallimento. Con value: Unit, nessun valore, né TRUE/FALSE
# né valore precedente. Rileggere FindVertical() dopo la modifica.

SUB Main()
    # CountGroundInRange(graphic, radius, height) salva entrambi i limiti, imposta radius=5 e
    # height=10, cerca graphic=0x0EED e restituisce FindCount(). Una pila vale un oggetto. Funzione
    # completa dopo Main. Finally ripristina anche con Return; i risultati della ricerca restano
    # disponibili.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- CountGroundInRange(graphic, radius, height) salva entrambi i limiti, imposta radius=5 e height=10, cerca graphic=0x0EED e restituisce FindCount(). Una pila vale un oggetto. Funzione completa dopo Main. Finally ripristina anche con Return; i risultati della ricerca restano disponibili.
