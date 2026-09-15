# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

AS records a scalar variable’s conversion rule. The stored runtime kinds are Integer, Decimal, String, Array, Object and Unit (no value). Boolean uses Integer 1/0. This Basic dialect has its own storage rules; an alias does not imply the corresponding VB.NET storage width.

## Exact syntax

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## Parameters

- `name` — Declared variable name. Reading it gives its current stored value; each subsequent assignment applies its AS conversion again.
- `type` — Integer, Long, Short, Byte: signed 32-bit Integer, range -2147483648…2147483647; Short and Byte do not impose narrower limits. Double, Single, Decimal: binary 64-bit floating point, internally named Decimal; this is not exact decimal arithmetic. String: text. Boolean, Bool: logical Integer 1/0. Variant, Object: retain the supplied value kind without requiring an object instance. Names are case-insensitive.
- `value` — Optional initial value. Numeric literals, text, a variable or function result can be converted. AS describes the declaration; call CInt(value), CDbl(value), CStr(value) or CBool(value) when an explicit conversion expression is needed.

## Returns

AS itself returns nothing. A variable read returns its stored kind and value. Numeric Boolean results use TRUE=1 and FALSE=0. A count of 2 is nonzero, but 2=TRUE is false: use count<>0 or CBool(count) to test whether any items exist.

## Behavior

- Without an initializer, typed VAR gives 0 for integral/Boolean types, floating 0 for Double/Single/Decimal, and empty text for String. Untyped VAR and VAR AS Variant/Object give Unit. Scalar DIM inserts a default initializer: empty text for String, otherwise 0. Unit remains Unit when assigned through AS.
- AS Integer truncates an in-range fractional number toward zero. CInt/CLng instead round midpoint values away from zero: 2.6 becomes 3, while AS Integer stores 2. Integer text must be a complete decimal integer or 0x hexadecimal; "2.6" is not integer text. Keep values in range before conversion.
- AS Boolean compares the original value with numeric zero. A nonzero number becomes 1; zero becomes 0. It does not parse words: even the text "false" becomes 1. CBool instead performs numeric conversion first; use numeric/logical values, or explicitly compare text with the expected word.
- AS String uses the runtime text representation. AS Double/Single/Decimal parses numeric text using a dot decimal separator. Numeric AS conversion maps Array to 0 but rejects Object and invalid numeric text with an error catchable by TRY/CATCH. In contrast, CInt/CLng/CDbl/CSng/CBool use a permissive numeric reader: an unrecognized string, Array, Object or Unit becomes 0 before conversion. Check IsNumeric(value) before relying on text conversion.
- A declaration evaluates the initializer, chooses the AS conversion and stores the result plus type name. Later assignment repeats the conversion. Floating values are approximate; do not assume exact monetary decimal storage. See VAR / DIM for scope and CONST for binding protection.
- A declared Structure name is also supported after As. VAR and DIM with that type and no initializer create its default fields. Only that declared structure type is accepted; different structure types are not converted to one another. See Structure / New for nested copies and reference fields.

## Examples

### 1. Assignment conversion versus rounding

```vb
# source=2.6 is floating point. whole AS Integer stores 2; CInt(source) returns 3 into rounded. Main returns 2*10+3=23 so the two conversions can be checked together.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**Parameter and execution notes:**

source=2.6 is floating point. whole AS Integer stores 2; CInt(source) returns 3 into rounded. Main returns 2*10+3=23 so the two conversions can be checked together.

### 2. A count and a Boolean are different

```vb
# count=2 is an item count. hasItems AS Boolean becomes 1. count=TRUE is false because TRUE is exactly 1; count<>0 is true. Main returns hasItems=1, meaning that some items exist, not that their count is one.
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**Parameter and execution notes:**

count=2 is an item count. hasItems AS Boolean becomes 1. count=TRUE is false because TRUE is exactly 1; count<>0 is true. Main returns hasItems=1, meaning that some items exist, not that their count is one.

### 3. Variant keeps the value kind

```vb
# value AS Variant first stores Integer 7, then String "ore". text AS String starts empty. CStr(12) produces text "12"; joining text with text produces "ore12", returned by Main. Variant permits the kind change.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**Parameter and execution notes:**

value AS Variant first stores Integer 7, then String "ore". text AS String starts empty. CStr(12) produces text "12"; joining text with text produces "ore12", returned by Main. Variant permits the kind change.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
