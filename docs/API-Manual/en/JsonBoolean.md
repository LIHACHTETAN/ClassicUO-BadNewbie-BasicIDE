# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Creates an explicit JSON Boolean.

## Exact syntax

```text
JsonBoolean(value:Any) -> Object
```

## Parameters

- `value` — Numeric flag or numeric String: zero means false, nonzero means true. Basic True/False are 1/0; a parsed JSON Boolean is read with flag.Value().

## Returns

Object JsonBoolean: serializes as true/false. Its Value() method returns Integer 1/True or 0/False for If. Do not use the object itself as a numeric flag.

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Creates an explicit JSON Boolean.

#### 1. BasicJsonBoolean

Numeric flag or numeric String: zero means false, nonzero means true. Basic True/False are 1/0; a parsed JSON Boolean is read with flag.Value().

Object JsonBoolean: serializes as true/false. Its Value() method returns Integer 1/True or 0/False for If. Do not use the object itself as a numeric flag.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; function `BasicJsonBoolean`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Creates an explicit JSON Boolean.
#
# Object JsonBoolean: serializes as true/false. Its Value() method returns Integer 1/True or
# 0/False for If. Do not use the object itself as a numeric flag.

Option Explicit On
Sub Main()
    # Run Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Parameter and execution notes:**

- Run Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Creates an explicit JSON Boolean.
#
# Object JsonBoolean: serializes as true/false. Its Value() method returns Integer 1/True or
# 0/False for If. Do not use the object itself as a numeric flag.

Option Explicit On
Sub Main()
    # Run Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Parameter and execution notes:**

- Run Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Creates an explicit JSON Boolean.
#
# Object JsonBoolean: serializes as true/false. Its Value() method returns Integer 1/True or
# 0/False for If. Do not use the object itself as a numeric flag.

Option Explicit On
Sub Main()
    # Run Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Parameter and execution notes:**

- Run Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
