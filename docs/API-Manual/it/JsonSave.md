# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Salva un valore in un file JSON.

## Sintassi esatta

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## Parametri

- `fileName` — Percorso obbligatorio. I percorsi relativi partono dalla cartella dello script principale, anche dentro Include. Ammessi percorsi assoluti.
- `value` — Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati.
- `indented` — Flag Integer:0 compatto, diverso da0 con rientri. Predefinito:Stringify=0, Save=1.

## Restituisce

Unit: nessun risultato. Il completamento normale indica successo; gestire errori con Try/Catch.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Salva un valore in un file JSON.

#### 1. Save

Percorso obbligatorio. I percorsi relativi partono dalla cartella dello script principale, anche dentro Include. Ammessi percorsi assoluti. Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati. Flag Integer:0 compatto, diverso da0 con rientri. Predefinito:Stringify=0, Save=1.

Unit: nessun risultato. Il completamento normale indica successo; gestire errori con Try/Catch.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; funzione `Save`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonSave · 1

```vb
# JsonSave · 1
#
# Salva un valore in un file JSON.
#
# Unit: nessun risultato. Il completamento normale indica successo; gestire errori con
# Try/Catch.

Option Explicit On
Sub Main()
    # Eseguire Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# Salva un valore in un file JSON.
#
# Unit: nessun risultato. Il completamento normale indica successo; gestire errori con
# Try/Catch.

Option Explicit On
Sub Main()
    # Eseguire Main. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# Salva un valore in un file JSON.
#
# Unit: nessun risultato. Il completamento normale indica successo; gestire errori con
# Try/Catch.

Option Explicit On
Sub Main()
    # Eseguire Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
