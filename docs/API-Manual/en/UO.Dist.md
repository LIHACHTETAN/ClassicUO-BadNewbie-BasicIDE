# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Calculates the tile distance between two world points: the larger absolute difference of X and Y.

## Exact syntax

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parameters

- `Xfrom` — X coordinate of the starting point.
- `Yfrom` — Y coordinate of the starting point.
- `Xto` — X coordinate of the destination.
- `Yto` — Y coordinate of the destination.

## Returns

Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one means one tile. This count is not a Boolean success result. A comparison such as distance<=2 produces a separate 1/True or 0/False.

## Behavior

- Pure coordinate calculation: no packets, waiting, map loading, obstacles, Z or facet checks. It neither finds a traversable route nor guarantees arrival. The points must belong to the same coordinate system; obstacle detours may be longer.
- All four parameters are required. Use Integer world coordinates in the documented 0..65535 range. Any in the registered parameter signature identifies the generic adapter, not a request for an object serial. No defaults, container coordinates, fifth Z argument or single-object overload is registered for these commands.
- Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps around an obstacle.

### Internal functions: from call to result

The third example reconstructs the algorithm as an ordinary script helper. It is illustrative source, not a claim that the engine calls that helper.

#### 1. ExecuteStealthCompatibility

The adapter reads arguments 0..3 as integers in Xfrom,Yfrom,Xto,Yto order, then calls the pure helper.

Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one means one tile. This count is not a Boolean success result. A comparison such as distance<=2 produces a separate 1/True or 0/False.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps around an obstacle.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `GetDistance`.

Pure coordinate calculation: no packets, waiting, map loading, obstacles, Z or facet checks. It neither finds a traversable route nor guarantees arrival. The points must belong to the same coordinate system; obstacle detours may be longer.


## Examples

### Direct calculation

```vb
# Direct calculation
#
# Calculates the tile distance between two world points: the larger absolute difference of X and
# Y.
#
# Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one
# means one tile. This count is not a Boolean success result. A comparison such as distance<=2
# produces a separate 1/True or 0/False.

SUB Main()
    # From (100,100) to (103,104), absolute differences are 3 and 4. The maximum is 4, so Main
    # returns Integer 4.
    # Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one
    # means one tile. This count is not a Boolean success result. A comparison such as distance<=2
    # produces a separate 1/True or 0/False.
    # Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points
    # changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps
    # around an obstacle.

    Return UO.Dist(100,100,103,104)
END SUB
```

**Parameter and execution notes:**

- From (100,100) to (103,104), absolute differences are 3 and 4. The maximum is 4, so Main returns Integer 4.
- Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one means one tile. This count is not a Boolean success result. A comparison such as distance<=2 produces a separate 1/True or 0/False.
- Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps around an obstacle.

### Use the result correctly

```vb
# Use the result correctly
#
# Calculates the tile distance between two world points: the larger absolute difference of X and
# Y.
#
# Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one
# means one tile. This count is not a Boolean success result. A comparison such as distance<=2
# produces a separate 1/True or 0/False.

SUB Main()
    # From (100,100) to (101,99), distance is 1. The separate test distance<=2 is True=1. Main
    # returns "1:1": the first 1 is a distance, the second is a Boolean comparison.
    # Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one
    # means one tile. This count is not a Boolean success result. A comparison such as distance<=2
    # produces a separate 1/True or 0/False.
    # Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points
    # changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps
    # around an obstacle.

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**Parameter and execution notes:**

- From (100,100) to (101,99), distance is 1. The separate test distance<=2 is True=1. Main returns "1:1": the first 1 is a distance, the second is a Boolean comparison.
- Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one means one tile. This count is not a Boolean success result. A comparison such as distance<=2 produces a separate 1/True or 0/False.
- Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps around an obstacle.

### Complete script reconstruction

```vb
# Complete script reconstruction
#
# Calculates the tile distance between two world points: the larger absolute difference of X and
# Y.
#
# Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one
# means one tile. This count is not a Boolean success result. A comparison such as distance<=2
# produces a separate 1/True or 0/False.

SUB Main()
    # UO.Dist returns 4. RebuildTileDistance computes Abs differences, compares them and returns the
    # larger one, also 4. Main returns "4:4". This fully shown helper is example code, not another
    # engine command.
    # Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one
    # means one tile. This count is not a Boolean success result. A comparison such as distance<=2
    # produces a separate 1/True or 0/False.
    # Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points
    # changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps
    # around an obstacle.

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**Parameter and execution notes:**

- UO.Dist returns 4. RebuildTileDistance computes Abs differences, compares them and returns the larger one, also 4. Main returns "4:4". This fully shown helper is example code, not another engine command.
- Integer distance in tiles, at least zero for valid coordinates. Zero means identical XY; one means one tile. This count is not a Boolean success result. A comparison such as distance<=2 produces a separate 1/True or 0/False.
- Distance = Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). This is symmetric: swapping the two points changes nothing. It is not Euclidean distance, Manhattan distance or the number of steps around an obstacle.
