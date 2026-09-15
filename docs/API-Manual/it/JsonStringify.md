# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Converte valori Basic in testo JSON.

## Sintassi esatta

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Parametri

- `value` — Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati.
- `indented` — Flag Integer:0 compatto, diverso da0 con rientri. Predefinito:Stringify=0, Save=1.

## Restituisce

String JSON, senza creare file.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Converte valori Basic in testo JSON.

#### 1. Stringify

Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati. Flag Integer:0 compatto, diverso da0 con rientri. Predefinito:Stringify=0, Save=1.

String JSON, senza creare file.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; funzione `Stringify`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Converte valori Basic in testo JSON.
#
# String JSON, senza creare file.

Option Explicit On
Sub Main()
    # Eseguire Main. value=Dictionary(name="ore",count=3), indented=0 → String
    # {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Converte valori Basic in testo JSON.
#
# String JSON, senza creare file.

Option Explicit On
Sub Main()
    # Eseguire Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Converte valori Basic in testo JSON.
#
# String JSON, senza creare file.

Option Explicit On
Sub Main()
    # Eseguire Main. value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=List → value[0]=value → Catch → "cycle".
