# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge un file JSON.

## Sintassi esatta

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## Parametri

- `fileName` — Percorso obbligatorio. I percorsi relativi partono dalla cartella dello script principale, anche dentro Include. Ammessi percorsi assoluti.
- `defaultValue` — Valore alternativo facoltativo solo se manca il file o la cartella. Copia indipendente tramite JSON. Errori di dati, codifica e accesso non vengono nascosti.

## Restituisce

Any come JsonParse. File assente senza defaultValue: errore.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Legge un file JSON.

#### 1. LoadCore

Percorso obbligatorio. I percorsi relativi partono dalla cartella dello script principale, anche dentro Include. Ammessi percorsi assoluti. Valore alternativo facoltativo solo se manca il file o la cartella. Copia indipendente tramite JSON. Errori di dati, codifica e accesso non vengono nascosti.

Any come JsonParse. File assente senza defaultValue: errore.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; funzione `LoadCore`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# Legge un file JSON.
#
# Any come JsonParse. File assente senza defaultValue: errore.

Option Explicit On
Sub Main()
    # Eseguire Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# Legge un file JSON.
#
# Any come JsonParse. File assente senza defaultValue: errore.

Option Explicit On
Sub Main()
    # Eseguire Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# Legge un file JSON.
#
# Any come JsonParse. File assente senza defaultValue: errore.

Option Explicit On
Sub Main()
    # Eseguire Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
