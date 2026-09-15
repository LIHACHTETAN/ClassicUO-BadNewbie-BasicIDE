# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Finds loaded world objects at one exact X/Y cell of the current map.

## Exact syntax

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## Parameters

- `X` — horizontal world coordinate, Integer 0..65535. Required; not a container-window pixel coordinate.
- `Y` — vertical world coordinate, Integer 0..65535. Required. No optional Z, map, type or range argument exists.

## Returns

Integer serial of the first matching object in this client’s result list, or 0 when none exists, the player is absent/destroyed, or coordinates are outside 0..65535. It is an object ID, not a type, quantity or Boolean. Preserve all 32 bits; compare <> 0, not = TRUE or > 0. The same ID becomes FindItem().

## Behavior

- Searches non-destroyed ground Items and Mobiles, including the player when present at that cell. Items inside containers or equipped on a mobile are excluded: their stored X/Y must not be interpreted as world coordinates. Ignored serials are excluded.
- All Z levels at the exact X/Y are eligible. FindDistance and FindVertical do not restrict this exact-cell query. It sees only loaded objects of the current world; no terrain tile/static record or remote map is loaded. It sends no packet, opens no target, and does not move anything.
- Each call first clears the preceding search. FindCount() counts objects, FindFullQuantity() sums stack units (a mobile contributes one), and GetFoundItems() exposes matching serials. Items are scanned before mobiles; within each collection the current enumeration order applies. Save the returned list before another search overwrites it.
- Reference: [Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/). The ordering and filters above describe this client’s implementation.

### Internal functions: from call to result

These are actual internal stages. CountGraphicAt is a fully defined script helper, not an additional built-in command.

#### 1. ExecuteStealthCompatibility

The two positional or named X/Y values are converted by the registered runtime route; the bridge integer becomes the result.

Integer serial of the first matching object in this client’s result list, or 0 when none exists, the player is absent/destroyed, or coordinates are outside 0..65535. It is an object ID, not a type, quantity or Boolean. Preserve all 32 bits; compare <> 0, not = TRUE or > 0. The same ID becomes FindItem().

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

The game-thread operation clears previous results, checks the current player and coordinate domain, and scans only eligible ground items and mobiles at that X/Y. Container contents cannot match.

Searches non-destroyed ground Items and Mobiles, including the player when present at that cell. Items inside containers or equipped on a mobile are excluded: their stored X/Y must not be interpreted as world coordinates. Ignored serials are excluded.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindAtCoord`.

#### 3. RegisterFound

Every eligible object increments the count and adds its serial. The first accepted serial remains FindItem; Item.Amount contributes at least one unit, and a mobile contributes one.

Each call first clears the preceding search. FindCount() counts objects, FindFullQuantity() sums stack units (a mobile contributes one), and GetFoundItems() exposes matching serials. Items are scanned before mobiles; within each collection the current enumeration order applies. Save the returned list before another search overwrites it.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `RegisterFound`.

All Z levels at the exact X/Y are eligible. FindDistance and FindVertical do not restrict this exact-cell query. It sees only loaded objects of the current world; no terrain tile/static record or remote map is loaded. It sends no packet, opens no target, and does not move anything.


## Examples

### Read one object ID

```vb
# Read one object ID
#
# Finds loaded world objects at one exact X/Y cell of the current map.
#
# Integer serial of the first matching object in this client’s result list, or 0 when none
# exists, the player is absent/destroyed, or coordinates are outside 0..65535. It is an object
# ID, not a type, quantity or Boolean. Preserve all 32 bits; compare <> 0, not = TRUE or > 0.
# The same ID becomes FindItem().

SUB Main()
    # 1445 and 1690 are example world X/Y values: replace them with your cell. id stores one serial;
    # HEX formats it. <> 0 is an existence check on this result, not a count.

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**Parameter and execution notes:**

- 1445 and 1690 are example world X/Y values: replace them with your cell. id stores one serial; HEX formats it. <> 0 is an existence check on this result, not a count.

### Inspect every object at the player’s cell

```vb
# Inspect every object at the player’s cell
#
# Finds loaded world objects at one exact X/Y cell of the current map.
#
# Integer serial of the first matching object in this client’s result list, or 0 when none
# exists, the player is absent/destroyed, or coordinates are outside 0..65535. It is an object
# ID, not a type, quantity or Boolean. Preserve all 32 bits; compare <> 0, not = TRUE or > 0.
# The same ID becomes FindItem().

SUB Main()
    # x/y are read from the player; ids saves the current search list. Each id identifies one
    # object, including a whole stack. GetType(id) reads its graphic/body. No item is selected or
    # used.

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**Parameter and execution notes:**

- x/y are read from the player; ids saves the current search list. Each id identifies one object, including a whole stack. GetType(id) reads its graphic/body. No item is selected or used.

### Complete CountGraphicAt helper

```vb
# Complete CountGraphicAt helper
#
# Finds loaded world objects at one exact X/Y cell of the current map.
#
# Integer serial of the first matching object in this client’s result list, or 0 when none
# exists, the player is absent/destroyed, or coordinates are outside 0..65535. It is an object
# ID, not a type, quantity or Boolean. Preserve all 32 bits; compare <> 0, not = TRUE or > 0.
# The same ID becomes FindItem().

SUB Main()
    # CountGraphicAt(x, y, graphic) performs one search, iterates the saved IDs and counts objects
    # whose graphic matches. graphic=0x0EED selects gold. Return is an object/stack count, not the
    # sum of units and not true/false; a stack contributes one. The full helper is defined below
    # Main.

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**Parameter and execution notes:**

- CountGraphicAt(x, y, graphic) performs one search, iterates the saved IDs and counts objects whose graphic matches. graphic=0x0EED selects gold. Return is an object/stack count, not the sum of units and not true/false; a stack contributes one. The full helper is defined below Main.
