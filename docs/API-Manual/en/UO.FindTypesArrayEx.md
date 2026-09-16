# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Searches alternative graphics, hues and containers in one pass and returns one matching ID. Read GetFoundItems for the entire list.

## Exact syntax

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## Parameters

- `ObjTypes` — Graphic/body, not an object serial. Use 0..65534 for one graphic, -1 or 0xFFFF for any graphic; other negative integers also act as wildcards in this client.
- `Colors` — Hue, not item quantity. 0 is the uncolored hue; -1 or 0xFFFF accepts any hue. Other negative integers also disable this filter.
- `Containers` — Ground: UO.Ground(), 0, -1, 0xFFFFFFFF or string ground. Backpack: string backpack or its serial. Decimal/hex serials and AddObject names are accepted. my selects all player-owned inventory, including equipment and nested bags. An unknown name raises a script error. Check a resolved serial before passing it: explicit 0 selects ground. Prefer ground/backpack names over numeric sentinels shared with other APIs.
- `InSub` — Required TRUE/FALSE (1/0). FALSE searches direct contents of a concrete container; TRUE includes loaded nested bags. Ground ignores recursion. my already selects player-owned inventory recursively.

## Returns

Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic, quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks each count as one object; a mobile counts as one object and one unit. Order is not nearest-first or guaranteed stable.

## Behavior

- Supply an Array; a scalar is also accepted as a one-element extension. DIM values[1] creates slots 0 and 1: assign every slot. Types and colors are independent alternatives, not paired by index. A wildcard anywhere, or an empty type/color array, removes that filter. An empty container array selects player-owned inventory. Repeated/overlapping containers do not duplicate IDs.
- All four positional arguments are required; none has an omitted-argument default.
- Ground obeys this script’s FindDistance and FindVertical, excludes self, and includes matching items and mobiles. A concrete container search does not apply these distance/height limits. Both scopes exclude Ignore entries and destroyed objects.
- Before scanning, FindItem, FindCount, FindFullQuantity and GetFoundItems are cleared. They then describe this search; an empty search leaves zeros and an empty array. FindFullQuantity sums max(1, Amount) for items and 1 for mobiles. FindQuantity reads the current amount of FindItem. Save GetFoundItems before another search replaces the snapshot.
- The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.
- Only data already received by the client is searched. Containers are not opened, map cells are not downloaded and no transfer occurs. An empty result does not prove a chest is empty on the server. Call Connected when the script requires an active connection; the search itself reads local state.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). The reference describes a last ID and inventory fallback for invalid containers. This client keeps the first local match and does not fall back from an unknown name. Ground also accepts 0; the local FindDistance default is 18, maximum 255. These are deliberate local conventions.

### Internal functions: from call to result

These are actual implementation stages, not additional public commands. FindGoldNearSelf and SearchTypesIn below are complete script functions.

#### 1. ExecuteStealthCompatibility

Runtime converts numeric filters and resolves container names separately; the ground selector becomes the bridge’s internal world scope.

All four positional arguments are required; none has an omitted-argument default.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

Ground: UO.Ground(), 0, -1, 0xFFFFFFFF or string ground. Backpack: string backpack or its serial. Decimal/hex serials and AddObject names are accepted. my selects all player-owned inventory, including equipment and nested bags. An unknown name raises a script error. Check a resolved serial before passing it: explicit 0 selects ground. Prefer ground/backpack names over numeric sentinels shared with other APIs.

Runtime converts numeric filters and resolves container names separately; the ground selector becomes the bridge’s internal world scope.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

Before scanning, FindItem, FindCount, FindFullQuantity and GetFoundItems are cleared. They then describe this search; an empty search leaves zeros and an empty array. FindFullQuantity sums max(1, Amount) for items and 1 for mobiles. FindQuantity reads the current amount of FindItem. Save GetFoundItems before another search replaces the snapshot.

Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic, quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks each count as one object; a mobile counts as one object and one unit. Order is not nearest-first or guaranteed stable.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `ResetFindResults`.

#### 4. BuildFindIdentityMask

Supply an Array; a scalar is also accepted as a one-element extension. DIM values[1] creates slots 0 and 1: assign every slot. Types and colors are independent alternatives, not paired by index. A wildcard anywhere, or an empty type/color array, removes that filter. An empty container array selects player-owned inventory. Repeated/overlapping containers do not duplicate IDs.

The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `BuildFindIdentityMask`.

#### 5. FindTypes

The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.

Ground obeys this script’s FindDistance and FindVertical, excludes self, and includes matching items and mobiles. A concrete container search does not apply these distance/height limits. Both scopes exclude Ignore entries and destroyed objects.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body, not an object serial. Use 0..65534 for one graphic, -1 or 0xFFFF for any graphic; other negative integers also act as wildcards in this client. Hue, not item quantity. 0 is the uncolored hue; -1 or 0xFFFF accepts any hue. Other negative integers also disable this filter.

The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `MatchesFindIdentity`.

#### 7. MatchesFindContainer

Required TRUE/FALSE (1/0). FALSE searches direct contents of a concrete container; TRUE includes loaded nested bags. Ground ignores recursion. my already selects player-owned inventory recursively.

Ground obeys this script’s FindDistance and FindVertical, excludes self, and includes matching items and mobiles. A concrete container search does not apply these distance/height limits. Both scopes exclude Ignore entries and destroyed objects.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `MatchesFindContainer`.

#### 8. RegisterFound

Before scanning, FindItem, FindCount, FindFullQuantity and GetFoundItems are cleared. They then describe this search; an empty search leaves zeros and an empty array. FindFullQuantity sums max(1, Amount) for items and 1 for mobiles. FindQuantity reads the current amount of FindItem. Save GetFoundItems before another search replaces the snapshot.

Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic, quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks each count as one object; a mobile counts as one object and one unit. Order is not nearest-first or guaranteed stable.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `RegisterFound`.

Only data already received by the client is searched. Containers are not opened, map cells are not downloaded and no transfer occurs. An empty result does not prove a chest is empty on the server. Call Connected when the script requires an active connection; the search itself reads local state.


## Examples

### Two graphics on the ground

```vb
# Two graphics on the ground
#
# Searches alternative graphics, hues and containers in one pass and returns one matching ID.
# Read GetFoundItems for the entire list.
#
# Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic,
# quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks
# each count as one object; a mobile counts as one object and one unit. Order is not
# nearest-first or guaranteed stable.

SUB Main()
    # types contains gold 0x0EED and black pearl 0x0F7A; one color -1 means any hue, one Ground
    # selector chooses the world. FALSE has no extra effect on ground. Current search limits apply.
    # Prints one ID, object count, then units.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Parameter and execution notes:**

- types contains gold 0x0EED and black pearl 0x0F7A; one color -1 means any hue, one Ground selector chooses the world. FALSE has no extra effect on ground. Current search limits apply. Prints one ID, object count, then units.

### Gold in backpack and on ground

```vb
# Gold in backpack and on ground
#
# Searches alternative graphics, hues and containers in one pass and returns one matching ID.
# Read GetFoundItems for the entire list.
#
# Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic,
# quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks
# each count as one object; a mobile counts as one object and one unit. Order is not
# nearest-first or guaranteed stable.

SUB Main()
    # types has gold only; colors accepts all hues. Containers are backpack and ground; TRUE
    # includes nested bags. Outputs total stacks/objects and units across both scopes, with each
    # object counted once.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Parameter and execution notes:**

- types has gold only; colors accepts all hues. Containers are backpack and ground; TRUE includes nested bags. Outputs total stacks/objects and units across both scopes, with each object counted once.

### Complete helper returning a saved list

```vb
# Complete helper returning a saved list
#
# Searches alternative graphics, hues and containers in one pass and returns one matching ID.
# Read GetFoundItems for the entire list.
#
# Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic,
# quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks
# each count as one object; a mobile counts as one object and one unit. Order is not
# nearest-first or guaranteed stable.

SUB Main()
    # SearchTypesIn(container,firstType,secondType) returns Array<Integer>, unlike the built-in
    # command’s single Integer ID. The complete helper builds all arrays, searches recursively and
    # immediately copies GetFoundItems. Main checks each saved ID and prints it.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**Parameter and execution notes:**

- SearchTypesIn(container,firstType,secondType) returns Array<Integer>, unlike the built-in command’s single Integer ID. The complete helper builds all arrays, searches recursively and immediately copies GetFoundItems. Main checks each saved ID and prints it.
