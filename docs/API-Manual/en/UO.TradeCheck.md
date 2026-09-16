# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Reads acceptance boxes; the three-argument form can also change your own box.

## Exact syntax

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## Parameters

- `windowIndex` — Integer current window index, 0 through TradeCount()-1. Negative/missing indices give an empty result. Not a serial.
- `TradeNum` — Integer current window index, 0 through TradeCount()-1. Negative/missing indices give an empty result. Not a serial.
- `Num` — Two-argument form only: 1 means your box, 2 the partner’s; other values return 0. TradeNum here starts at 0.
- `checkbox` — Three-argument form only: 0 means your box, 1 the partner’s. The other box is read-only; other values return 0.
- `stateValue` — Only for checkbox=0: 0/FALSE clears acceptance, any nonzero number/TRUE sets it. Ignored for checkbox=1.

## Returns

Integer: 1 = TRUE if the selected box is checked; 0 = FALSE if unchecked, absent or invalid. A write returns the resulting box state, not trade success: clearing returns 0.

This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the action or read changed state.

## Behavior

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.
- Reads run on the game thread using live windows in this World. Disposed windows are excluded. Reading sends no packets and waits for no response. UI ordering may change when windows open, close or move to the front; an index is not a persistent identifier.
- ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local state/handling, not completed transfer. Names and both checks do not prove that offered items stayed unchanged.

### Internal functions: from call to result

The C# call path is explained below, followed by executable Basic helpers. The scripts do not reimplement the network protocol.

#### 1. TradeCheck

Registration selects by argument count and NumberConversions converts numbers. The two-argument TradeCheck validates sides 1/2 and maps them to bridge indices 0/1. Legacy serials pass through ToHex.

Integer: 1 = TRUE if the selected box is checked; 0 = FALSE if unchecked, absent or invalid. A write returns the resulting box state, not trade success: clearing returns 0.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `TradeCheck`.

#### 2. TradeCheck

Invoke marshals reading/writing to the game thread with script cancellation; the method reads ID1/ID2, LocalSerial, OpponentName or acceptance flags from the selected TradingGump.

Reads acceptance boxes; the three-argument form can also change your own box.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade validates number>0 before subtracting 1; FindTrade rejects negative indices and enumerates only live TradingGump windows belonging to this World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindTrade`.

#### 4. AcceptTrade

When your box changes, GameActions.AcceptTrade calls Send_TradeResponse with code 2, ID1 and state. Reads and setting an unchanged state generate no packet.

Integer: 1 = TRUE if the selected box is checked; 0 = FALSE if unchecked, absent or invalid. A write returns the resulting box state, not trade success: clearing returns 0.

Project source: `src/ClassicUO.Client/Game/GameActions.cs`; function `AcceptTrade`.

The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.


## Examples

### Direct read or action

```vb
# Direct read or action
#
# Reads acceptance boxes; the three-argument form can also change your own box.
#
# Integer: 1 = TRUE if the selected box is checked; 0 = FALSE if unchecked, absent or invalid. A
# write returns the resulting box state, not trade success: clearing returns 0.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # UO.TradeCheck(0) and UO.TradeCheck(0,1) read your first-window box; UO.TradeCheck(0,2) reads
    # the other box. No state is written or automatically accepted.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**Parameter and execution notes:**

- UO.TradeCheck(0) and UO.TradeCheck(0,1) read your first-window box; UO.TradeCheck(0,2) reads the other box. No state is written or automatically accepted.

### Another scenario and parameters

```vb
# Another scenario and parameters
#
# Reads acceptance boxes; the three-argument form can also change your own box.
#
# Integer: 1 = TRUE if the selected box is checked; 0 = FALSE if unchecked, absent or invalid. A
# write returns the resulting box state, not trade success: clearing returns 0.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # UO.TradeCheck(0,0,FALSE) clears your box. UO.TradeCheck(0,1,FALSE) only reads the partner box:
    # FALSE cannot change their acceptance. Returning 0 after clearing is expected.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**Parameter and execution notes:**

- UO.TradeCheck(0,0,FALSE) clears your box. UO.TradeCheck(0,1,FALSE) only reads the partner box: FALSE cannot change their acceptance. Returning 0 after clearing is expected.

### Complete callable helper

```vb
# Complete callable helper
#
# Reads acceptance boxes; the three-argument form can also change your own box.
#
# Integer: 1 = TRUE if the selected box is checked; 0 = FALSE if unchecked, absent or invalid. A
# write returns the resulting box state, not trade success: clearing returns 0.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are
    # not atomic: the selected window may change between them. For an action, expectedPartner is a
    # saved character serial, not a price or contents validation.

    VAR accepted = BothAccepted(0)
    IF accepted = TRUE THEN
        UO.Print("Both boxes are checked; server completion is not known")
    END IF
END SUB

FUNCTION BothAccepted(index)
    IF index < 0 OR index >= UO.TradeCount() THEN
        RETURN FALSE
    END IF
    VAR own = UO.TradeCheck(index, 1)
    VAR other = UO.TradeCheck(index, 2)
    RETURN own = TRUE AND other = TRUE
END FUNCTION
```

**Parameter and execution notes:**

- The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.
