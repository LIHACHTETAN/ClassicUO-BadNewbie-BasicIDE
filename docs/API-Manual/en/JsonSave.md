# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Saves a value to a JSON file.

## Exact syntax

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## Parameters

- `fileName` — Required file path. Relative paths start in the main script folder, including calls from an Include file. Absolute paths are accepted.
- `value` — Value: number, String, array, List, Dictionary, JsonBoolean or JsonNull. Dictionary keys must be Strings; shared references are allowed, circular references are errors.
- `indented` — Integer flag: 0 is compact JSON; nonzero adds indentation. Default: Stringify=0, Save=1.

## Returns

Unit: no return value. Success is normal completion; errors can be caught with Try/Catch.

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Saves a value to a JSON file.

#### 1. Save

Required file path. Relative paths start in the main script folder, including calls from an Include file. Absolute paths are accepted. Value: number, String, array, List, Dictionary, JsonBoolean or JsonNull. Dictionary keys must be Strings; shared references are allowed, circular references are errors. Integer flag: 0 is compact JSON; nonzero adds indentation. Default: Stringify=0, Save=1.

Unit: no return value. Success is normal completion; errors can be caught with Try/Catch.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; function `Save`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonSave · 1

```vb
# JsonSave · 1
#
# Saves a value to a JSON file.
#
# Unit: no return value. Success is normal completion; errors can be caught with Try/Catch.

Option Explicit On
Sub Main()
    # Run Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Parameter and execution notes:**

- Run Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# Saves a value to a JSON file.
#
# Unit: no return value. Success is normal completion; errors can be caught with Try/Catch.

Option Explicit On
Sub Main()
    # Run Main. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Parameter and execution notes:**

- Run Main. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# Saves a value to a JSON file.
#
# Unit: no return value. Success is normal completion; errors can be caught with Try/Catch.

Option Explicit On
Sub Main()
    # Run Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad
    # → original Integer7.

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

**Parameter and execution notes:**

- Run Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
