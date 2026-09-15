# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Parses JSON text into Basic values.

## Exact syntax

```text
JsonParse(text:String) -> Any
```

## Parameters

- `text` — Required JSON String. One complete value; objects require unique, case-sensitive keys. Comments and trailing commas are errors.

## Returns

Any: object→Dictionary, array→List, string→String, number→Integer or Decimal (Double), true/false→JsonBoolean, null→JsonNull. It is not a success flag.

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Parses JSON text into Basic values.

#### 1. Parse

Required JSON String. One complete value; objects require unique, case-sensitive keys. Comments and trailing commas are errors.

Any: object→Dictionary, array→List, string→String, number→Integer or Decimal (Double), true/false→JsonBoolean, null→JsonNull. It is not a success flag.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; function `Parse`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonParse · 1

```vb
# JsonParse · 1
#
# Parses JSON text into Basic values.
#
# Any: object→Dictionary, array→List, string→String, number→Integer or Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. It is not a success flag.

Option Explicit On
Sub Main()
    # Run Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Parameter and execution notes:**

- Run Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Parses JSON text into Basic values.
#
# Any: object→Dictionary, array→List, string→String, number→Integer or Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. It is not a success flag.

Option Explicit On
Sub Main()
    # Run Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 →
    # Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Parameter and execution notes:**

- Run Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Parses JSON text into Basic values.
#
# Any: object→Dictionary, array→List, string→String, number→Integer or Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. It is not a success flag.

Option Explicit On
Sub Main()
    # Run Main. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Parameter and execution notes:**

- Run Main. text={"x":1,"x":2} → Catch → "duplicate key".
