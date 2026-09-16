# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Searches one graphic/hue in a container or on the ground and returns one matching ID.

## Exact syntax

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## Parameters

- `ObjType` — Graphic/body, not an object serial. Use 0..65534 for one graphic, -1 or 0xFFFF for any graphic; other negative integers also act as wildcards in this client.
- `Color` — Hue, not item quantity. 0 is the uncolored hue; -1 or 0xFFFF accepts any hue. Other negative integers also disable this filter.
- `Container` — Ground: UO.Ground(), 0, -1, 0xFFFFFFFF or string ground. Backpack: string backpack or its serial. Decimal/hex serials and AddObject names are accepted. my selects all player-owned inventory, including equipment and nested bags. An unknown name raises a script error. Check a resolved serial before passing it: explicit 0 selects ground. Prefer ground/backpack names over numeric sentinels shared with other APIs.
- `InSub` — Required TRUE/FALSE (1/0). FALSE searches direct contents of a concrete container; TRUE includes loaded nested bags. Ground ignores recursion. my already selects player-owned inventory recursively.

## Returns

Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic, quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks each count as one object; a mobile counts as one object and one unit. Order is not nearest-first or guaranteed stable.

## Behavior

- All four positional arguments are required; none has an omitted-argument default.
- Ground obeys this script’s FindDistance and FindVertical, excludes self, and includes matching items and mobiles. A concrete container search does not apply these distance/height limits. Both scopes exclude Ignore entries and destroyed objects.
- Before scanning, FindItem, FindCount, FindFullQuantity and GetFoundItems are cleared. They then describe this search; an empty search leaves zeros and an empty array. FindFullQuantity sums max(1, Amount) for items and 1 for mobiles. FindQuantity reads the current amount of FindItem. Save GetFoundItems before another search replaces the snapshot.
- The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.
- Only data already received by the client is searched. Containers are not opened, map cells are not downloaded and no transfer occurs. An empty result does not prove a chest is empty on the server. Call Connected when the script requires an active connection; the search itself reads local state.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). The reference describes a last ID and inventory fallback for invalid containers. This client keeps the first local match and does not fall back from an unknown name. Ground also accepts 0; the local FindDistance default is 18, maximum 255. These are deliberate local conventions.

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

#### 4. FindType

The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.

Ground obeys this script’s FindDistance and FindVertical, excludes self, and includes matching items and mobiles. A concrete container search does not apply these distance/height limits. Both scopes exclude Ignore entries and destroyed objects.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindType`.

#### 5. MatchesFindIdentity

Graphic/body, not an object serial. Use 0..65534 for one graphic, -1 or 0xFFFF for any graphic; other negative integers also act as wildcards in this client. Hue, not item quantity. 0 is the uncolored hue; -1 or 0xFFFF accepts any hue. Other negative integers also disable this filter.

The bridge visits loaded items once, then mobiles if ground is selected. Matching type, hue and at least one container are all required. Every object is registered once even when several selectors match. It does not repeat a whole-world scan for every combination.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `MatchesFindIdentity`.

#### 6. MatchesFindContainer

Required TRUE/FALSE (1/0). FALSE searches direct contents of a concrete container; TRUE includes loaded nested bags. Ground ignores recursion. my already selects player-owned inventory recursively.

Ground obeys this script’s FindDistance and FindVertical, excludes self, and includes matching items and mobiles. A concrete container search does not apply these distance/height limits. Both scopes exclude Ignore entries and destroyed objects.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `MatchesFindContainer`.

#### 7. RegisterFound

Before scanning, FindItem, FindCount, FindFullQuantity and GetFoundItems are cleared. They then describe this search; an empty search leaves zeros and an empty array. FindFullQuantity sums max(1, Amount) for items and 1 for mobiles. FindQuantity reads the current amount of FindItem. Save GetFoundItems before another search replaces the snapshot.

Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic, quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks each count as one object; a mobile counts as one object and one unit. Order is not nearest-first or guaranteed stable.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `RegisterFound`.

Only data already received by the client is searched. Containers are not opened, map cells are not downloaded and no transfer occurs. An empty result does not prove a chest is empty on the server. Call Connected when the script requires an active connection; the search itself reads local state.


## Examples

### Direct backpack contents

```vb
# Direct backpack contents
#
# Searches one graphic/hue in a container or on the ground and returns one matching ID.
#
# Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic,
# quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks
# each count as one object; a mobile counts as one object and one unit. Order is not
# nearest-first or guaranteed stable.

SUB Main()
    # 0x0EED is gold; -1 accepts any hue; backpack/FALSE excludes nested bags. The three lines print
    # the first ID in hex (without 0x), object count and unit total. Two stacks of 20 and 50 give
    # count 2 and units 70.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Parameter and execution notes:**

- 0x0EED is gold; -1 accepts any hue; backpack/FALSE excludes nested bags. The three lines print the first ID in hex (without 0x), object count and unit total. Two stacks of 20 and 50 give count 2 and units 70.

### Complete temporary ground search helper

```vb
# Complete temporary ground search helper
#
# Searches one graphic/hue in a container or on the ground and returns one matching ID.
#
# Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic,
# quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks
# each count as one object; a mobile counts as one object and one unit. Order is not
# nearest-first or guaranteed stable.

SUB Main()
    # radius=5 and height=10 apply only inside FindGoldNearSelf. Finally restores both settings even
    # on Return or error. The helper returns one gold serial or 0; Main tests <> 0 before displaying
    # it.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Parameter and execution notes:**

- radius=5 and height=10 apply only inside FindGoldNearSelf. Finally restores both settings even on Return or error. The helper returns one gold serial or 0; Main tests <> 0 before displaying it.

### Named container and nested bags

```vb
# Named container and nested bags
#
# Searches one graphic/hue in a container or on the ground and returns one matching ID.
#
# Integer: serial of the first match in local iteration order, or 0 with no match. Not graphic,
# quantity, array or Boolean. Test result <> 0, not result = TRUE or result = 1. Item stacks
# each count as one object; a mobile counts as one object and one unit. Order is not
# nearest-first or guaranteed stable.

SUB Main()
    # GetSerial resolves backpack; the zero guard prevents accidentally selecting ground. AddObject
    # saves its ID as search_bag. TRUE includes nested bags. GetFoundItems returns a saved array;
    # IsObjectExists rechecks each ID before use.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**Parameter and execution notes:**

- GetSerial resolves backpack; the zero guard prevents accidentally selecting ground. AddObject saves its ID as search_bag. TRUE includes nested bags. GetFoundItems returns a saved array; IsObjectExists rechecks each ID before use.
