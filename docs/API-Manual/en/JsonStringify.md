# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Converts Basic values into JSON text.

## Exact syntax

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Parameters

- `value` — Value: number, String, array, List, Dictionary, JsonBoolean or JsonNull. Dictionary keys must be Strings; shared references are allowed, circular references are errors.
- `indented` — Integer flag: 0 is compact JSON; nonzero adds indentation. Default: Stringify=0, Save=1.

## Returns

String containing JSON. No file is created.

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Converts Basic values into JSON text.

#### 1. Stringify

Value: number, String, array, List, Dictionary, JsonBoolean or JsonNull. Dictionary keys must be Strings; shared references are allowed, circular references are errors. Integer flag: 0 is compact JSON; nonzero adds indentation. Default: Stringify=0, Save=1.

String containing JSON. No file is created.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; function `Stringify`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Converts Basic values into JSON text.
#
# String containing JSON. No file is created.

Option Explicit On
Sub Main()
    # Run Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Parameter and execution notes:**

- Run Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Converts Basic values into JSON text.
#
# String containing JSON. No file is created.

Option Explicit On
Sub Main()
    # Run Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Parameter and execution notes:**

- Run Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Converts Basic values into JSON text.
#
# String containing JSON. No file is created.

Option Explicit On
Sub Main()
    # Run Main. value=List → value[0]=value → Catch → "cycle".

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

**Parameter and execution notes:**

- Run Main. value=List → value[0]=value → Catch → "cycle".
