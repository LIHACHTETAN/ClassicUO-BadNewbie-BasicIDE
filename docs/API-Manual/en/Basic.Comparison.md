# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Comparison operators test two values and produce a logical result. Use that result in IF, assign it to a variable, or return it from a helper function.

## Exact syntax

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## Parameters

- `left` — Left value: a literal, declared variable, expression or function result.
- `right` — Right value. Numeric ordering requires Integer or Decimal operands; equality also supports other value kinds.
- `operator` — = and == mean equal inside an expression; <> means unequal; < and > are strict ordering; <= and >= include equality. A standalone name = expression statement assigns instead of comparing.

## Returns

Integer 1 (TRUE) when the comparison holds, otherwise Integer 0 (FALSE). For this result, result=1 and result=TRUE are equivalent, as are result=0 and result=FALSE. A count or ID is different: 2 is nonzero but 2=TRUE is false. Use count<>0 to test for a nonzero count.

## Behavior

- Integer and Decimal compare numerically across kinds: 5=5.0 is true. Text is not converted: "5"=5 is false. String equality is ordinal and case-sensitive: "Ore"<>"ore". Ordering text, arrays, objects or Unit with <, >, <=, >= raises an error.
- Equality on arrays and native objects compares identity, not contents. Two Unit values are equal; Unit is not numeric zero. Different kinds are unequal except compatible Integer/Decimal pairs. NaN is unequal even to itself and all numeric ordering comparisons with it are false.
- Arithmetic is evaluated before comparison. Comparison chains run left to right: 1<3<2 means (1<3)<2 and is true. To test a range, write (low<=value) AND (value<=high). Parentheses make the intended grouping explicit.
- Binary floating-point calculations can round: avoid exact equality for approximate measurements. Compare Abs(actual-expected)<=tolerance with a nonnegative tolerance suitable for the task. This is a script policy, not an automatic tolerance in the operators.
- This project additionally supports value equality: = compares the same declared type and corresponding fields; <> is its inverse. Reference fields compare identity. This is an engine extension, not a claim that arbitrary VB.NET structures support =. Cached hashes and a visited-pair set prevent repeated expansion of shared nested values.

## Examples

### 1. Inclusive range and TRUE

```vb
# InRange receives value=4, low=2, high=5. Both comparisons return 1, AND combines them to 1, and Main checks accepted=TRUE. The helper and caller are complete; Main returns 1.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**Parameter and execution notes:**

InRange receives value=4, low=2, high=5. Both comparisons return 1, AND combines them to 1, and Main checks accepted=TRUE. The helper and caller are complete; Main returns 1.

### 2. Text, numbers and letter case

```vb
# sameCase compares "Ore" with "ore" and becomes 0. sameKind compares "5" with Integer 5 and becomes 0. converted explicitly uses CDbl("5") and becomes 1. CStr builds the returned diagnostic string "0:0:1".
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**Parameter and execution notes:**

sameCase compares "Ore" with "ore" and becomes 0. sameKind compares "5" with Integer 5 and becomes 0. converted explicitly uses CDbl("5") and becomes 1. CStr builds the returned diagnostic string "0:0:1".

### 3. Approximate decimal equality

```vb
# NearlyEqual receives 0.1+0.2, expected=0.3 and tolerance=0.000001. Negative tolerance is rejected. Abs computes the magnitude of the difference; <= accepts differences within tolerance. Main returns 1. Every helper parameter is supplied explicitly.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**Parameter and execution notes:**

NearlyEqual receives 0.1+0.2, expected=0.3 and tolerance=0.000001. Negative tolerance is rejected. Abs computes the magnitude of the difference; <= accepts differences within tolerance. Main returns 1. Every helper parameter is supplied explicitly.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
