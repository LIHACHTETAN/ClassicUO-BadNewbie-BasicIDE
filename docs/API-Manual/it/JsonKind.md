# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Identifica il tipo compatibile con JSON.

## Sintassi esatta

```text
JsonKind(value:Any) -> String
```

## Parametri

- `value` — Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati.

## Restituisce

String:number, string, array, object, boolean, null o unsupported. Controlla solo il tipo esterno.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Identifica il tipo compatibile con JSON.

#### 1. Kind

Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati.

String:number, string, array, object, boolean, null o unsupported. Controlla solo il tipo esterno.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; funzione `Kind`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonKind · 1

```vb
# JsonKind · 1
#
# Identifica il tipo compatibile con JSON.
#
# String:number, string, array, object, boolean, null o unsupported. Controlla solo il tipo
# esterno.

Option Explicit On
Sub Main()
    # Eseguire Main. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Identifica il tipo compatibile con JSON.
#
# String:number, string, array, object, boolean, null o unsupported. Controlla solo il tipo
# esterno.

Option Explicit On
Sub Main()
    # Eseguire Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Identifica il tipo compatibile con JSON.
#
# String:number, string, array, object, boolean, null o unsupported. Controlla solo il tipo
# esterno.

Option Explicit On
Sub Main()
    # Eseguire Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
