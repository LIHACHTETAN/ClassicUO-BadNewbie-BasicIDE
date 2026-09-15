# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Creates an explicit JSON null value.

## Exact syntax

```text
JsonNull() -> Object
```

## Parameters

No parameters.

## Returns

Object JsonNull: serializes as null. It is neither zero nor an empty String. Test JsonKind(value)="null".

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Creates an explicit JSON null value.

#### 1. JsonNullObject



Object JsonNull: serializes as null. It is neither zero nor an empty String. Test JsonKind(value)="null".

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; function `JsonNullObject`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonNull · 1

```vb
# JsonNull · 1
#
# Creates an explicit JSON null value.
#
# Object JsonNull: serializes as null. It is neither zero nor an empty String. Test
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Run Main. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Parameter and execution notes:**

- Run Main. JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# Creates an explicit JSON null value.
#
# Object JsonNull: serializes as null. It is neither zero nor an empty String. Test
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Run Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Parameter and execution notes:**

- Run Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# Creates an explicit JSON null value.
#
# Object JsonNull: serializes as null. It is neither zero nor an empty String. Test
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Run Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Parameter and execution notes:**

- Run Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .
