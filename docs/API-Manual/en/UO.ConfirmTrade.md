# UO.ConfirmTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Sets your acceptance box in the selected trade.

## Exact syntax

```text
UO.ConfirmTrade(TradeNum:Any) -> Any
```

## Parameters

- `TradeNum` — Integer current window number, 1 through TradeCount(). Zero and negative numbers are invalid. Not a serial.

## Returns

Integer: 1 = TRUE if the window exists and your acceptance is set/already set; 0 = FALSE if absent. Does not establish server completion. Repeating does not toggle acceptance off.

This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the action or read changed state.

## Behavior

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.
- Reads run on the game thread using live windows in this World. Disposed windows are excluded. Reading sends no packets and waits for no response. UI ordering may change when windows open, close or move to the front; an index is not a persistent identifier.
- ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local state/handling, not completed transfer. Names and both checks do not prove that offered items stayed unchanged.

### Internal functions: from call to result

The C# call path is explained below, followed by executable Basic helpers. The scripts do not reimplement the network protocol.

#### 1. ExecuteStealthCompatibility

Registration selects by argument count and NumberConversions converts numbers. The two-argument TradeCheck validates sides 1/2 and maps them to bridge indices 0/1. Legacy serials pass through ToHex.

Integer: 1 = TRUE if the window exists and your acceptance is set/already set; 0 = FALSE if absent. Does not establish server completion. Repeating does not toggle acceptance off.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. ConfirmTrade

Invoke marshals reading/writing to the game thread with script cancellation; the method reads ID1/ID2, LocalSerial, OpponentName or acceptance flags from the selected TradingGump.

Sets your acceptance box in the selected trade.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `ConfirmTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade validates number>0 before subtracting 1; FindTrade rejects negative indices and enumerates only live TradingGump windows belonging to this World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindNumberedTrade`.

#### 4. AcceptTrade

When your box changes, GameActions.AcceptTrade calls Send_TradeResponse with code 2, ID1 and state. Reads and setting an unchanged state generate no packet.

Integer: 1 = TRUE if the window exists and your acceptance is set/already set; 0 = FALSE if absent. Does not establish server completion. Repeating does not toggle acceptance off.

Project source: `src/ClassicUO.Client/Game/GameActions.cs`; function `AcceptTrade`.

The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.


## Examples

### Direct read or action

```vb
# Direct read or action
#
# Sets your acceptance box in the selected trade.
#
# Integer: 1 = TRUE if the window exists and your acceptance is set/already set; 0 = FALSE if
# absent. Does not establish server completion. Repeating does not toggle acceptance off.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # Call once and save value/result. Zero is the first index, one the first number (see this
    # command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

    VAR result = UO.ConfirmTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**Parameter and execution notes:**

- Call once and save value/result. Zero is the first index, one the first number (see this command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

### Another scenario and parameters

```vb
# Another scenario and parameters
#
# Sets your acceptance box in the selected trade.
#
# Integer: 1 = TRUE if the window exists and your acceptance is set/already set; 0 = FALSE if
# absent. Does not establish server completion. Repeating does not toggle acceptance off.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The
    # server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local
    # state/handling, not completed transfer. Names and both checks do not prove that offered items
    # stayed unchanged.

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.ConfirmTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**Parameter and execution notes:**

- ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local state/handling, not completed transfer. Names and both checks do not prove that offered items stayed unchanged.

### Complete callable helper

```vb
# Complete callable helper
#
# Sets your acceptance box in the selected trade.
#
# Integer: 1 = TRUE if the window exists and your acceptance is set/already set; 0 = FALSE if
# absent. Does not establish server completion. Repeating does not toggle acceptance off.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are
    # not atomic: the selected window may change between them. For an action, expectedPartner is a
    # saved character serial, not a price or contents validation.

    VAR expectedPartner = UO.GetTradeOpponent(1)
    VAR result = ApplyToPartner(1, expectedPartner)
    UO.Print(CStr(result))
END SUB

FUNCTION ApplyToPartner(tradeNumber, expectedPartner)
    IF expectedPartner = 0 THEN
        RETURN FALSE
    END IF
    IF UO.GetTradeOpponent(tradeNumber) <> expectedPartner THEN
        RETURN FALSE
    END IF
    RETURN UO.ConfirmTrade(tradeNumber)
END FUNCTION
```

**Parameter and execution notes:**

- The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.
