# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Returns the special selector for the ground, for use in a search or transfer destination parameter.

## Exact syntax

```text
UO.Ground() -> Integer
```

## Parameters

No parameters.

## Returns

Integer, always 0. This zero is a valid ground selector, not FALSE, a failed search, an item ID, graphic, map number or coordinate. Do not test Ground() as a success flag; test the result of the search or transfer that uses it.

## Behavior

- No parameters. Calling Ground() alone performs no search, movement, targeting or network operation and does not change previous search results. It also returns 0 before login.
- Pass it in the container/destination position of FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx or MoveItem. Search reads loaded world objects; it does not load distant cells. Ground destinations use world X/Y/Z, not pixels in a container window.
- FindType(type, color) still uses the inventory: its second argument is color. Use FindType(type, color, UO.Ground()) for the ground. The older compact FindType/MoveItem convention uses -1 for inventory; compatibility FindTypeEx/FindTypesArrayEx/CountEx also accept -1 as ground. Prefer UO.Ground() or the explicit name ground instead of copying numeric selectors between different commands.
- Primary reference: [Stealth Ground](https://stealth.od.ua/api/Ground/). The command-specific selector conventions and examples above describe this client.

### Internal functions: from call to result

These are the real internal operations. FindGroundTypes below is a complete script helper, not another built-in command.

#### 1. ExecuteStealthCompatibility

The zero-argument runtime branch returns Integer 0 without calling the game bridge.

Integer, always 0. This zero is a valid ground selector, not FALSE, a failed search, an item ID, graphic, map number or coordinate. Do not test Ground() as a success flag; test the result of the search or transfer that uses it.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

The compact search adapter maps explicit 0 to its internal ground scope while retaining -1 as the inventory default. The compatibility adapter accepts 0 and the historical -1 ground selector; named containers are resolved separately.

FindType(type, color) still uses the inventory: its second argument is color. Use FindType(type, color, UO.Ground()) for the ground. The older compact FindType/MoveItem convention uses -1 for inventory; compatibility FindTypeEx/FindTypesArrayEx/CountEx also accept -1 as ground. Prefer UO.Ground() or the explicit name ground instead of copying numeric selectors between different commands.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

The compact search adapter maps explicit 0 to its internal ground scope while retaining -1 as the inventory default. The compatibility adapter accepts 0 and the historical -1 ground selector; named containers are resolved separately.

FindType(type, color) still uses the inventory: its second argument is color. Use FindType(type, color, UO.Ground()) for the ground. The older compact FindType/MoveItem convention uses -1 for inventory; compatibility FindTypeEx/FindTypesArrayEx/CountEx also accept -1 as ground. Prefer UO.Ground() or the explicit name ground instead of copying numeric selectors between different commands.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

The transfer resolver preserves explicit ground as destination 0. The client bridge uses the supplied world coordinates; the drop packet encodes the ground container as 0xFFFFFFFF. The public selector and packet field are different representations.

Replace 0x40001001 with the serial of your accessible item. IsObjectExists checks the loaded object first. MoveItem(item, amount, destination, X, Y, Z): amount=0 means the entire stack; Ground() chooses the ground; GetX/GetY/GetZ read the player’s world cell. result is 1 when the client accepts the move request, otherwise 0; it is not the result of Ground() and is not a server delivery acknowledgement.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ResolveTransferDestination`.

#### 5. MoveItem

The transfer resolver preserves explicit ground as destination 0. The client bridge uses the supplied world coordinates; the drop packet encodes the ground container as 0xFFFFFFFF. The public selector and packet field are different representations.

Replace 0x40001001 with the serial of your accessible item. IsObjectExists checks the loaded object first. MoveItem(item, amount, destination, X, Y, Z): amount=0 means the entire stack; Ground() chooses the ground; GetX/GetY/GetZ read the player’s world cell. result is 1 when the client accepts the move request, otherwise 0; it is not the result of Ground() and is not a server delivery acknowledgement.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `MoveItem`.

No parameters. Calling Ground() alone performs no search, movement, targeting or network operation and does not change previous search results. It also returns 0 before login.


## Examples

### Read the selector

```vb
# Read the selector
#
# Returns the special selector for the ground, for use in a search or transfer destination
# parameter.
#
# Integer, always 0. This zero is a valid ground selector, not FALSE, a failed search, an item
# ID, graphic, map number or coordinate. Do not test Ground() as a success flag; test the result
# of the search or transfer that uses it.

SUB Main()
    # destination receives Integer 0 and Print displays it. The call itself does not drop anything.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**Parameter and execution notes:**

- destination receives Integer 0 and Print displays it. The call itself does not drop anything.

### Find a gold stack on the ground

```vb
# Find a gold stack on the ground
#
# Returns the special selector for the ground, for use in a search or transfer destination
# parameter.
#
# Integer, always 0. This zero is a valid ground selector, not FALSE, a failed search, an item
# ID, graphic, map number or coordinate. Do not test Ground() as a success flag; test the result
# of the search or transfer that uses it.

SUB Main()
    # 0x0EED is gold graphic; the second -1 accepts any hue. Ground() selects the world; FALSE
    # disables container recursion. FindTypeEx returns one serial, or 0 when no match exists. <> 0
    # tests that serial. Search uses the current FindDistance/FindVertical and Ignore list.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**Parameter and execution notes:**

- 0x0EED is gold graphic; the second -1 accepts any hue. Ground() selects the world; FALSE disables container recursion. FindTypeEx returns one serial, or 0 when no match exists. <> 0 tests that serial. Search uses the current FindDistance/FindVertical and Ignore list.

### Complete helper for two ground graphics

```vb
# Complete helper for two ground graphics
#
# Returns the special selector for the ground, for use in a search or transfer destination
# parameter.
#
# Integer, always 0. This zero is a valid ground selector, not FALSE, a failed search, an item
# ID, graphic, map number or coordinate. Do not test Ground() as a success flag; test the result
# of the search or transfer that uses it.

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) searches gold 0x0EED and black pearl
    # 0x0F7A within radius=5 and height=10. DIM types[1] creates two slots; colors[0] and
    # containers[0] each create one. Each whole stack is one result; matching types/colors are
    # alternatives, overlapping containers do not duplicate IDs. The helper returns a saved array of
    # serials, and Finally restores both limits. Main prints each ID. All helper code is provided.

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Parameter and execution notes:**

- FindGroundTypes(firstType, secondType, radius, height) searches gold 0x0EED and black pearl 0x0F7A within radius=5 and height=10. DIM types[1] creates two slots; colors[0] and containers[0] each create one. Each whole stack is one result; matching types/colors are alternatives, overlapping containers do not duplicate IDs. The helper returns a saved array of serials, and Finally restores both limits. Main prints each ID. All helper code is provided.

### Move a known item to the player’s world cell

```vb
# Move a known item to the player’s world cell
#
# Returns the special selector for the ground, for use in a search or transfer destination
# parameter.
#
# Integer, always 0. This zero is a valid ground selector, not FALSE, a failed search, an item
# ID, graphic, map number or coordinate. Do not test Ground() as a success flag; test the result
# of the search or transfer that uses it.

SUB Main()
    # Replace 0x40001001 with the serial of your accessible item. IsObjectExists checks the loaded
    # object first. MoveItem(item, amount, destination, X, Y, Z): amount=0 means the entire stack;
    # Ground() chooses the ground; GetX/GetY/GetZ read the player’s world cell. result is 1 when the
    # client accepts the move request, otherwise 0; it is not the result of Ground() and is not a
    # server delivery acknowledgement.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**Parameter and execution notes:**

- Replace 0x40001001 with the serial of your accessible item. IsObjectExists checks the loaded object first. MoveItem(item, amount, destination, X, Y, Z): amount=0 means the entire stack; Ground() chooses the ground; GetX/GetY/GetZ read the player’s world cell. result is 1 when the client accepts the move request, otherwise 0; it is not the result of Ground() and is not a server delivery acknowledgement.
