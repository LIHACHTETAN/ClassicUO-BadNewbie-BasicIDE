# JSON / Config.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Config.bas è incluso in Scripts/Include. Collocare Include/Config.bas accanto allo script principale e usare Include "Config.bas". Combina JSON persistente con impostazioni predefinite indipendenti.

## Sintassi esatta

```text
Include "Config.bas"
settings = Config.Load(fileName, defaults)
Config.Save(fileName, settings)
enabled = Config.GetFlag(settings, key, fallback=False)
Config.SetFlag(settings, key, value)
JsonParse(text) / JsonStringify(value[, indented=0])
JsonLoad(fileName[, defaultValue]) / JsonSave(fileName, value[, indented=1])
JsonKind(value) / JsonBoolean(value) / JsonNull() / flag.Value()
```

## Parametri

- `fileName` — Percorso obbligatorio. I percorsi relativi partono dalla cartella dello script principale, anche dentro Include. Ammessi percorsi assoluti.
- `defaults (Config.Load)` — Dictionary predefinito obbligatorio per Config.Load. La copia profonda JSON riceve le chiavi salvate al primo livello. L’originale non cambia. defaults non può essere omesso.
- `defaultValue (JsonLoad)` — Valore alternativo facoltativo solo se manca il file o la cartella. Copia indipendente tramite JSON. Errori di dati, codifica e accesso non vengono nascosti.
- `settings / value` — Numero, String, array, List, Dictionary, JsonBoolean o JsonNull. Chiavi Dictionary di tipo String. Riferimenti condivisi ammessi, cicli vietati.
- `indented` — Flag Integer:0 compatto, diverso da0 con rientri. Predefinito:Stringify=0, Save=1.
- `key / fallback` — Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.

## Restituisce

Config.Load(fileName, defaults) restituisce un nuovo Dictionary: le chiavi salvate al primo livello sostituiscono una copia profonda dei valori predefiniti. Gli oggetti annidati sono sostituiti interamente. Config.Save(fileName, settings) salva esplicitamente, senza risultato. Config.GetFlag(settings, key, fallback=False) restituisce1/True o0/False; valori esistenti non booleani causano errori. Config.SetFlag(settings, key, value) modifica solo la memoria, senza risultato. Load/Save richiedono Dictionaries con chiavi String. Private RequireObject verifica il tipo esterno; JSON controlla tutto il contenuto.

## Comportamento

- Funzioni Basic locali senza UO., nessun pacchetto di gioco. JsonParse/JsonStringify lavorano in memoria. Basic True diventa il numero1; usare JsonBoolean(True) per JSON true. JsonNull() distingue null da0.
- Solo numeri finiti. Interi oltre ±9007199254740991 rifiutati: salvare ID grandi come Strings. Altri numeri con precisione Double. UTF-8 rigoroso: BOM accettato in ingresso, assente in uscita. Unicode non valido: errore.
- Limiti:1048576 unità UTF-16,4MiB di byte,64 contenitori annidati,100000 nodi. Superamento: errore. Lettura/analisi crea nuove raccolte; salvataggio non clona oggetti in memoria.
- Save verifica tutto, crea cartelle, scrive un file temporaneo vicino, svuota il buffer e sposta/sostituisce. Errore/annullamento prima della sostituzione conserva il file precedente. Rimuove il temporaneo se il sistema lo permette. Sostituzioni concluse non vengono annullate.
- Pausa/stop controllati ogni256 valori, tra blocchi4096 byte/caratteri e prima della sostituzione. Nessun thread aggiuntivo; chiamate OS non interrotte forzatamente. Scritture concorrenti: vince l’ultima sostituzione riuscita; non è una transazione database.

## Esempi

### 1. Valori predefiniti indipendenti

```vb
# fileName=missing-settings.json, defaults contiene delay=350. Se manca il file, Load copia defaults. Cambiare il risultato in125 conserva350 nei valori iniziali. Risultato:"125:350". Rinominare o rimuovere il vecchio file di esempio per questa prova.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim defaults=Dictionary()
    defaults["delay"]=350
    Dim settings=Config.Load("missing-settings.json", defaults)
    settings["delay"]=125
    Return CStr(settings["delay"]) & ":" & CStr(defaults["delay"])
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

fileName=missing-settings.json, defaults contiene delay=350. Se manca il file, Load copia defaults. Cambiare il risultato in125 conserva350 nei valori iniziali. Risultato:"125:350". Rinominare o rimuovere il vecchio file di esempio per questa prova.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 2. Salvare e rileggere

```vb
# SetFlag crea un booleano JSON. Save crea/sostituisce demo-settings.json; Load lo rilegge. GetFlag restituisce Integer1, delay=350. Risultato:"1:350".
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["delay"]=350
    Config.SetFlag(settings, "enabled", True)
    Config.Save("demo-settings.json", settings)
    Dim loaded=Config.Load("demo-settings.json", Dictionary())
    Return CStr(Config.GetFlag(loaded, "enabled")) & ":" & CStr(loaded["delay"])
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

SetFlag crea un booleano JSON. Save crea/sostituisce demo-settings.json; Load lo rilegge. GetFlag restituisce Integer1, delay=350. Risultato:"1:350".

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 3. Verificare i flag

```vb
# enabled=1 è un numero, non JSON true. GetFlag lo rifiuta; Catch restituisce "invalid flag". SetFlag(settings,"enabled",True) imposterebbe il tipo corretto. Nessun file modificato.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["enabled"]=1
    Try
        Dim enabled=Config.GetFlag(settings, "enabled")
    Catch problem
        Return "invalid flag"
    End Try
    Return "unexpected"
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

enabled=1 è un numero, non JSON true. GetFlag lo rifiuta; Catch restituisce "invalid flag". SetFlag(settings,"enabled",True) imposterebbe il tipo corretto. Nessun file modificato.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

<!-- implementation references (not callable script procedures):
Runtime/BasicJson.cs: Parse / Read / Stringify / Write / LoadCore / Save / Resolve / Budget
Runtime/ObjectTypes/JsonPrimitiveObjects.cs: Value
src/ClassicUO.Client/Scripts/Include/Config.bas: RequireObject / Load / Save / GetFlag / SetFlag
https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-dom
-->
