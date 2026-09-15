# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Crea un valore JSON null esplicito.

## Sintassi esatta

```text
JsonNull() -> Object
```

## Parametri

Nessun parametro.

## Restituisce

Oggetto JsonNull, serializzato come null, non0 né String vuota. Verifica:JsonKind(value)="null".

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Crea un valore JSON null esplicito.

#### 1. JsonNullObject



Oggetto JsonNull, serializzato come null, non0 né String vuota. Verifica:JsonKind(value)="null".

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; funzione `JsonNullObject`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonNull · 1

```vb
# JsonNull · 1
#
# Crea un valore JSON null esplicito.
#
# Oggetto JsonNull, serializzato come null, non0 né String vuota.
# Verifica:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Eseguire Main. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# Crea un valore JSON null esplicito.
#
# Oggetto JsonNull, serializzato come null, non0 né String vuota.
# Verifica:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Eseguire Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# Crea un valore JSON null esplicito.
#
# Oggetto JsonNull, serializzato come null, non0 né String vuota.
# Verifica:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Eseguire Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .
