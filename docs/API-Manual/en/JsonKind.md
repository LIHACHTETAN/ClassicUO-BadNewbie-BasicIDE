# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Identifies the JSON-compatible kind of a value.

## Exact syntax

```text
JsonKind(value:Any) -> String
```

## Parameters

- `value` — Value: number, String, array, List, Dictionary, JsonBoolean or JsonNull. Dictionary keys must be Strings; shared references are allowed, circular references are errors.

## Returns

String: number, string, array, object, boolean, null or unsupported. This checks the outer kind, not every nested value.

## Behavior

- These are local Basic functions without UO.; they send no game packets. JsonParse/JsonStringify work in memory. Basic True serializes as the number 1; use JsonBoolean(True) for JSON true. JsonNull() preserves null separately from 0.
- Numbers must be finite. Integer-valued numbers outside ±9007199254740991 are rejected; store larger identifiers as Strings. Other numbers use Double precision. UTF-8 is strict; an input BOM is accepted, output has no BOM. Invalid Unicode is rejected.
- Limits: 1048576 UTF-16 code units, 4 MiB file/output bytes, 64 nested containers and 100000 value nodes. Over-limit input raises an error. Loading/parsing creates new collections; saving does not clone your in-memory objects.
- Save validates the whole graph, creates parent folders, writes a unique temporary file beside the destination, flushes it, then moves/replaces it. A failed or cancelled pre-commit write keeps the old destination. It cleans its temporary file; an OS cleanup error can leave that file. Already committed saves are not undone.
- Conversion checks pause/stop every 256 values, file I/O between 4096-byte/character chunks and before commit. No background writer or extra thread is created. Individual OS calls cannot be forcibly interrupted. Concurrent saves use last successful replacement; this is not a database transaction.

### Internal functions: from call to result

Identifies the JSON-compatible kind of a value.

#### 1. Kind

Value: number, String, array, List, Dictionary, JsonBoolean or JsonNull. Dictionary keys must be Strings; shared references are allowed, circular references are errors.

String: number, string, array, object, boolean, null or unsupported. This checks the outer kind, not every nested value.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; function `Kind`.

Config.Load(fileName, defaults) returns a new Dictionary: saved top-level keys override a deep copy of defaults. Nested objects are replaced whole, not recursively merged. Config.Save(fileName, settings) returns no value and saves explicitly. Config.GetFlag(settings, key, fallback=False) returns 1/True or 0/False; an existing non-Boolean value raises an error. Config.SetFlag(settings, key, value) changes memory only and returns no value. Load/Save require Dictionaries with string keys. Private RequireObject checks the outer kind; JSON conversion validates the complete graph.


## Examples

### JsonKind · 1

```vb
# JsonKind · 1
#
# Identifies the JSON-compatible kind of a value.
#
# String: number, string, array, object, boolean, null or unsupported. This checks the outer
# kind, not every nested value.

Option Explicit On
Sub Main()
    # Run Main. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Parameter and execution notes:**

- Run Main. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Identifies the JSON-compatible kind of a value.
#
# String: number, string, array, object, boolean, null or unsupported. This checks the outer
# kind, not every nested value.

Option Explicit On
Sub Main()
    # Run Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Parameter and execution notes:**

- Run Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Identifies the JSON-compatible kind of a value.
#
# String: number, string, array, object, boolean, null or unsupported. This checks the outer
# kind, not every nested value.

Option Explicit On
Sub Main()
    # Run Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Parameter and execution notes:**

- Run Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
