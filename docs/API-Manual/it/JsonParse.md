# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Converte testo JSON in valori Basic.

## Sintassi esatta

```text
JsonParse(text:String) -> Any
```

## Parametri

- `text` — String JSON obbligatoria: un valore completo. Chiavi uniche sensibili alle maiuscole. Commenti e virgole finali causano errori.

## Restituisce

Any: oggetto→Dictionary, array→List, testo→String, numero→Integer o Decimal(Double), true/false→JsonBoolean, null→JsonNull. Non indica il successo.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

### Funzioni interne: dalla chiamata al risultato

Converte testo JSON in valori Basic.

#### 1. Parse

String JSON obbligatoria: un valore completo. Chiavi uniche sensibili alle maiuscole. Commenti e virgole finali causano errori.

Any: oggetto→Dictionary, array→List, testo→String, numero→Integer o Decimal(Double), true/false→JsonBoolean, null→JsonNull. Non indica il successo.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; funzione `Parse`.

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.


## Esempi

### JsonParse · 1

```vb
# JsonParse · 1
#
# Converte testo JSON in valori Basic.
#
# Any: oggetto→Dictionary, array→List, testo→String, numero→Integer o Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Non indica il successo.

Option Explicit On
Sub Main()
    # Eseguire Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Converte testo JSON in valori Basic.
#
# Any: oggetto→Dictionary, array→List, testo→String, numero→Integer o Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Non indica il successo.

Option Explicit On
Sub Main()
    # Eseguire Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null;
    # index2 → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Converte testo JSON in valori Basic.
#
# Any: oggetto→Dictionary, array→List, testo→String, numero→Integer o Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Non indica il successo.

Option Explicit On
Sub Main()
    # Eseguire Main. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Main. text={"x":1,"x":2} → Catch → "duplicate key".
