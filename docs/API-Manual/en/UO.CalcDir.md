# UO.CalcDir

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Calculates the direction from one world point to another. It does not move the character.

## Exact syntax

```text
UO.CalcDir(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parameters

- `Xfrom` — X coordinate of the starting point.
- `Yfrom` — Y coordinate of the starting point.
- `Xto` — X coordinate of the destination.
- `Yto` — Y coordinate of the destination.

## Returns

Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100. These are codes, not Boolean: zero means north, not failure; one means northeast, not success. Never pass 100 as a walking direction.

## Behavior

- Pure coordinate calculation: no packets, waiting, map loading, obstacles, Z or facet checks. It neither finds a traversable route nor guarantees arrival. The points must belong to the same coordinate system; obstacle detours may be longer.
- All four parameters are required. Use Integer world coordinates in the documented 0..65535 range. Any in the registered parameter signature identifies the generic adapter, not a request for an object serial. No defaults, container coordinates, fifth Z argument or single-object overload is registered for these commands.
- Subtract destination minus origin and examine the signs. Negative Y is north, positive X is east. Any nonzero change on both axes selects a diagonal, regardless of which difference is larger. Both differences zero return 100.

### Internal functions: from call to result

The third example reconstructs the algorithm as an ordinary script helper. It is illustrative source, not a claim that the engine calls that helper.

#### 1. ExecuteStealthCompatibility

The adapter reads arguments 0..3 as integers in Xfrom,Yfrom,Xto,Yto order, then calls the pure helper.

Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100. These are codes, not Boolean: zero means north, not failure; one means northeast, not success. Never pass 100 as a walking direction.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. CalculateDirection

`CalculateDirection: dx=Math.Sign(toX-fromX); dy=Math.Sign(toY-fromY); identical ->100; axis/sign branches ->0..7.`

Subtract destination minus origin and examine the signs. Negative Y is north, positive X is east. Any nonzero change on both axes selects a diagonal, regardless of which difference is larger. Both differences zero return 100.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `CalculateDirection`.

Pure coordinate calculation: no packets, waiting, map loading, obstacles, Z or facet checks. It neither finds a traversable route nor guarantees arrival. The points must belong to the same coordinate system; obstacle detours may be longer.


## Examples

### Direct calculation

```vb
# Direct calculation
#
# Calculates the direction from one world point to another. It does not move the character.
#
# Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100.
# These are codes, not Boolean: zero means north, not failure; one means northeast, not success.
# Never pass 100 as a walking direction.

SUB Main()
    # The origin is (100,100), destination (101,100): X increases, Y stays equal. Main returns
    # Integer 2, east. No movement command runs.
    # Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100.
    # These are codes, not Boolean: zero means north, not failure; one means northeast, not success.
    # Never pass 100 as a walking direction.
    # Subtract destination minus origin and examine the signs. Negative Y is north, positive X is
    # east. Any nonzero change on both axes selects a diagonal, regardless of which difference is
    # larger. Both differences zero return 100.

    Return UO.CalcDir(100,100,101,100)
END SUB
```

**Parameter and execution notes:**

- The origin is (100,100), destination (101,100): X increases, Y stays equal. Main returns Integer 2, east. No movement command runs.
- Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100. These are codes, not Boolean: zero means north, not failure; one means northeast, not success. Never pass 100 as a walking direction.
- Subtract destination minus origin and examine the signs. Negative Y is north, positive X is east. Any nonzero change on both axes selects a diagonal, regardless of which difference is larger. Both differences zero return 100.

### Use the result correctly

```vb
# Use the result correctly
#
# Calculates the direction from one world point to another. It does not move the character.
#
# Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100.
# These are codes, not Boolean: zero means north, not failure; one means northeast, not success.
# Never pass 100 as a walking direction.

SUB Main()
    # Both points are (100,100). direction=100 identifies coincidence and Main returns String
    # "already there". A noncoincident point takes the other branch. Compare with 100, not True.
    # Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100.
    # These are codes, not Boolean: zero means north, not failure; one means northeast, not success.
    # Never pass 100 as a walking direction.
    # Subtract destination minus origin and examine the signs. Negative Y is north, positive X is
    # east. Any nonzero change on both axes selects a diagonal, regardless of which difference is
    # larger. Both differences zero return 100.

    Dim direction=UO.CalcDir(100,100,100,100)
    If direction=100 Then
        Return "already there"
    End If
    Return "different point"
END SUB
```

**Parameter and execution notes:**

- Both points are (100,100). direction=100 identifies coincidence and Main returns String "already there". A noncoincident point takes the other branch. Compare with 100, not True.
- Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100. These are codes, not Boolean: zero means north, not failure; one means northeast, not success. Never pass 100 as a walking direction.
- Subtract destination minus origin and examine the signs. Negative Y is north, positive X is east. Any nonzero change on both axes selects a diagonal, regardless of which difference is larger. Both differences zero return 100.

### Complete script reconstruction

```vb
# Complete script reconstruction
#
# Calculates the direction from one world point to another. It does not move the character.
#
# Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100.
# These are codes, not Boolean: zero means north, not failure; one means northeast, not success.
# Never pass 100 as a walking direction.

SUB Main()
    # From (20,20) to (19,21), X decreases and Y increases. UO.CalcDir returns 5. RebuildDirection
    # shows every branch of the same algorithm and also returns 5; Main returns "5:5". Its four
    # parameters have the same coordinate meanings.
    # Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100.
    # These are codes, not Boolean: zero means north, not failure; one means northeast, not success.
    # Never pass 100 as a walking direction.
    # Subtract destination minus origin and examine the signs. Negative Y is north, positive X is
    # east. Any nonzero change on both axes selects a diagonal, regardless of which difference is
    # larger. Both differences zero return 100.

    Dim actual=UO.CalcDir(20,20,19,21)
    Dim rebuilt=RebuildDirection(20,20,19,21)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildDirection(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Xto-Xfrom
    Dim dy = Yto-Yfrom
    If dx=0 AndAlso dy=0 Then
        Return 100
    End If
    If dx=0 Then
        If dy<0 Then
            Return 0
        End If
        Return 4
    End If
    If dy=0 Then
        If dx>0 Then
            Return 2
        End If
        Return 6
    End If
    If dx>0 Then
        If dy<0 Then
            Return 1
        End If
        Return 3
    End If
    If dy>0 Then
        Return 5
    End If
    Return 7
End Function
```

**Parameter and execution notes:**

- From (20,20) to (19,21), X decreases and Y increases. UO.CalcDir returns 5. RebuildDirection shows every branch of the same algorithm and also returns 5; Main returns "5:5". Its four parameters have the same coordinate meanings.
- Integer direction: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Identical points return 100. These are codes, not Boolean: zero means north, not failure; one means northeast, not success. Never pass 100 as a walking direction.
- Subtract destination minus origin and examine the signs. Negative Y is north, positive X is east. Any nonzero change on both axes selects a diagonal, regardless of which difference is larger. Both differences zero return 100.
