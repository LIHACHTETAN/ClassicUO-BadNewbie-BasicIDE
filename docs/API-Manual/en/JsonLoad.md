# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Reads a JSON file.

## Exact syntax

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## Parameters

- `fileName` — Required file path. Relative paths start in the main script folder, including calls from an Include file. Absolute paths are accepted.
- `defaultValue` — Optional fallback used only when the file or its parent folder is missing. Returned as an independent JSON round-trip copy. Invalid JSON, encoding or access errors are not hidden.

## Returns

Any, with the same mapping as JsonParse; missing files require defaultValue or raise an error.

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Reads a JSON file.

#### 1. LoadCore

Required file path. Relative paths start in the main script folder, including calls from an Include file. Absolute paths are accepted. Optional fallback used only when the file or its parent folder is missing. Returned as an independent JSON round-trip copy. Invalid JSON, encoding or access errors are not hidden.

Any, with the same mapping as JsonParse; missing files require defaultValue or raise an error.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; function `LoadCore`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# Reads a JSON file.
#
# Any, with the same mapping as JsonParse; missing files require defaultValue or raise an error.

Option Explicit On
Sub Main()
    # Run Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Parameter and execution notes:**

- Run Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# Reads a JSON file.
#
# Any, with the same mapping as JsonParse; missing files require defaultValue or raise an error.

Option Explicit On
Sub Main()
    # Run Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent
    # copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Parameter and execution notes:**

- Run Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# Reads a JSON file.
#
# Any, with the same mapping as JsonParse; missing files require defaultValue or raise an error.

Option Explicit On
Sub Main()
    # Run Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Parameter and execution notes:**

- Run Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
