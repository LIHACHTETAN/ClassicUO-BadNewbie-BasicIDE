# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Crea un booleano JSON esplicito.

## Sintassi esatta

```text
JsonBoolean(value:Any) -> Object
```

## Parametri

- `value` — Numero o String numerica:0=false, altrimenti true. Basic True/False equivale a1/0; leggere booleani JSON con flag.Value().

## Restituisce

Oggetto JsonBoolean, serializzato come true/false. Value() restituisce Integer1/True o0/False per If. L’oggetto non è direttamente un flag numerico.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Crea un booleano JSON esplicito.

#### 1. BasicJsonBoolean

Numero o String numerica:0=false, altrimenti true. Basic True/False equivale a1/0; leggere booleani JSON con flag.Value().

Oggetto JsonBoolean, serializzato come true/false. Value() restituisce Integer1/True o0/False per If. L’oggetto non è direttamente un flag numerico.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; funzione `BasicJsonBoolean`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Crea un booleano JSON esplicito.
#
# Oggetto JsonBoolean, serializzato come true/false. Value() restituisce Integer1/True o0/False
# per If. L’oggetto non è direttamente un flag numerico.

Option Explicit On
Sub Main()
    # Eseguire Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Crea un booleano JSON esplicito.
#
# Oggetto JsonBoolean, serializzato come true/false. Value() restituisce Integer1/True o0/False
# per If. L’oggetto non è direttamente un flag numerico.

Option Explicit On
Sub Main()
    # Eseguire Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Crea un booleano JSON esplicito.
#
# Oggetto JsonBoolean, serializzato come true/false. Value() restituisce Integer1/True o0/False
# per If. L’oggetto non è direttamente un flag numerico.

Option Explicit On
Sub Main()
    # Eseguire Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
