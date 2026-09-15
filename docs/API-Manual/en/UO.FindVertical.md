# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Reads or changes the default allowed height difference for a search.

## Exact syntax

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## Parameters

- `value` — Optional Integer. No argument reads the setting; value sets it. The stored value is clamped to 0..120; a negative value becomes 0, not unlimited. Fresh runtime default: 2; restored state can contain another value. Decimal input truncates toward zero; decimal/0x numeric strings are also accepted. Use an Integer to avoid implicit conversion.

## Returns

No arguments: Integer, the current difference in world Z units limit, not a found ID, object count or Boolean. A value of 0 means a zero limit, not failure. With value: Unit (no return value), not TRUE/FALSE or the previous setting. Read FindVertical() afterward to see the stored value.

## Behavior

- Height uses abs(object.Z - player.Z), in both directions, with an inclusive boundary. A limit of 0 accepts only the same Z. This is not a floor number or a count of horizontal tiles.
- Stored in the current script runtime; procedures using that runtime share it. Independent runtimes have separate settings. Reading or writing does not perform a search, clear FindItem/FindCount/GetFoundItems, send a packet, move the player, or load distant objects.
- FindTypeEx and FindTypesArrayEx use these defaults for ground searches, not for container contents. Search still respects type, hue, Ignore and loaded objects. FindAtCoord ignores both limits. In extended commands, explicit distance/maxZ can override defaults; -1 in those command parameters means use the default, unlike setting this value to -1. FindList also applies its Z filter to container searches; it is not covered by the container exemption above.
- Save the current value and restore it in Finally after a temporary search. A setter has no automatic rollback. Finally covers ordinary completion and catchable script errors; emergency termination must not be used as a cleanup mechanism.
- Reference: [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). This client keeps its own defaults and clamps: FindDistance 18 / 0..255; FindVertical 2 / 0..120. The Basic call syntax and extended filters above describe this project.

### Internal functions: from call to result

The stages below describe real runtime operations. CountGroundInRange is a complete user function, not a hidden built-in command.

#### 1. ExecuteStealthCompatibility

The registered overload selects read with zero arguments or converts value and selects write with one argument. Return metadata distinguishes Integer from Unit.

No arguments: Integer, the current difference in world Z units limit, not a found ID, object count or Boolean. A value of 0 means a zero limit, not failure. With value: Unit (no return value), not TRUE/FALSE or the previous setting. Read FindVertical() afterward to see the stored value.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

The bridge reads the runtime setting, or clamps and stores the supplied integer. It does not scan the world.

No arguments: Integer, the current difference in world Z units limit, not a found ID, object count or Boolean. A value of 0 means a zero limit, not failure. With value: Unit (no return value), not TRUE/FALSE or the previous setting. Read FindVertical() afterward to see the stored value.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetFindVertical`.

#### 3. SetFindVertical

The bridge reads the runtime setting, or clamps and stores the supplied integer. It does not scan the world.

Optional Integer. No argument reads the setting; value sets it. The stored value is clamped to 0..120; a negative value becomes 0, not unlimited. Fresh runtime default: 2; restored state can contain another value. Decimal input truncates toward zero; decimal/0x numeric strings are also accepted. Use an Integer to avoid implicit conversion.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `SetFindVertical`.

#### 4. FindType

A later search reads the setting when no explicit override is supplied. Ground items and mobiles use the appropriate distance and height filters.

FindTypeEx and FindTypesArrayEx use these defaults for ground searches, not for container contents. Search still respects type, hue, Ignore and loaded objects. FindAtCoord ignores both limits. In extended commands, explicit distance/maxZ can override defaults; -1 in those command parameters means use the default, unlike setting this value to -1. FindList also applies its Z filter to container searches; it is not covered by the container exemption above.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindType`.

#### 5. FindList

A later search reads the setting when no explicit override is supplied. Ground items and mobiles use the appropriate distance and height filters.

FindTypeEx and FindTypesArrayEx use these defaults for ground searches, not for container contents. Search still respects type, hue, Ignore and loaded objects. FindAtCoord ignores both limits. In extended commands, explicit distance/maxZ can override defaults; -1 in those command parameters means use the default, unlike setting this value to -1. FindList also applies its Z filter to container searches; it is not covered by the container exemption above.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindList`.

Stored in the current script runtime; procedures using that runtime share it. Independent runtimes have separate settings. Reading or writing does not perform a search, clear FindItem/FindCount/GetFoundItems, send a packet, move the player, or load distant objects.


## Examples

### Read, set, and observe clamping

```vb
# Read, set, and observe clamping
#
# Reads or changes the default allowed height difference for a search.
#
# No arguments: Integer, the current difference in world Z units limit, not a found ID, object
# count or Boolean. A value of 0 means a zero limit, not failure. With value: Unit (no return
# value), not TRUE/FALSE or the previous setting. Read FindVertical() afterward to see the
# stored value.

SUB Main()
    # previous saves the actual setting. value:=10 sets a normal limit; 1000 demonstrates clamping
    # to 120. Print reads the result through the getter. Finally restores previous.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Parameter and execution notes:**

- previous saves the actual setting. value:=10 sets a normal limit; 1000 demonstrates clamping to 120. Print reads the result through the getter. Finally restores previous.

### Temporary ground search

```vb
# Temporary ground search
#
# Reads or changes the default allowed height difference for a search.
#
# No arguments: Integer, the current difference in world Z units limit, not a found ID, object
# count or Boolean. A value of 0 means a zero limit, not failure. With value: Unit (no return
# value), not TRUE/FALSE or the previous setting. Read FindVertical() afterward to see the
# stored value.

SUB Main()
    # previous preserves the caller’s limit. 10 changes only FindVertical; the other search limit
    # remains unchanged. 0x0EED is gold graphic, -1 is any hue, Container=-1 selects the world,
    # FALSE disables container recursion. id is one serial; <> 0 tests presence. FindCount counts
    # whole objects/stacks. Finally restores the limit, not the search result list.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Parameter and execution notes:**

- previous preserves the caller’s limit. 10 changes only FindVertical; the other search limit remains unchanged. 0x0EED is gold graphic, -1 is any hue, Container=-1 selects the world, FALSE disables container recursion. id is one serial; <> 0 tests presence. FindCount counts whole objects/stacks. Finally restores the limit, not the search result list.

### Complete CountGroundInRange helper

```vb
# Complete CountGroundInRange helper
#
# Reads or changes the default allowed height difference for a search.
#
# No arguments: Integer, the current difference in world Z units limit, not a found ID, object
# count or Boolean. A value of 0 means a zero limit, not failure. With value: Unit (no return
# value), not TRUE/FALSE or the previous setting. Read FindVertical() afterward to see the
# stored value.

SUB Main()
    # CountGroundInRange(graphic, radius, height) saves both limits, applies radius=5 and height=10,
    # searches for graphic=0x0EED and returns FindCount(). A stack counts as one object. The full
    # helper is below Main. Finally restores both limits even when Return exits the function; the
    # search snapshot remains available.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Parameter and execution notes:**

- CountGroundInRange(graphic, radius, height) saves both limits, applies radius=5 and height=10, searches for graphic=0x0EED and returns FindCount(). A stack counts as one object. The full helper is below Main. Finally restores both limits even when Return exits the function; the search snapshot remains available.
