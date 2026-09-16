# UO.IsTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Checks for an open secure-trade window.

## Exact syntax

```text
UO.IsTrade() -> Integer
```

## Parameters

No parameters.

## Returns

Integer: 1 = TRUE if a trade is open, otherwise 0 = FALSE.

This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the action or read changed state.

## Behavior

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.
- Reads run on the game thread using live windows in this World. Disposed windows are excluded. Reading sends no packets and waits for no response. UI ordering may change when windows open, close or move to the front; an index is not a persistent identifier.
- ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local state/handling, not completed transfer. Names and both checks do not prove that offered items stayed unchanged.

### Internal functions: from call to result

The C# call path is explained below, followed by executable Basic helpers. The scripts do not reimplement the network protocol.

#### 1. ExecuteStealthCompatibility

Registration selects by argument count and NumberConversions converts numbers. The two-argument TradeCheck validates sides 1/2 and maps them to bridge indices 0/1. Legacy serials pass through ToHex.

Integer: 1 = TRUE if a trade is open, otherwise 0 = FALSE.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. IsTrade

Invoke marshals reading/writing to the game thread with script cancellation; the method reads ID1/ID2, LocalSerial, OpponentName or acceptance flags from the selected TradingGump.

Checks for an open secure-trade window.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `IsTrade`.

#### 3. FindTrade

FindNumberedTrade validates number>0 before subtracting 1; FindTrade rejects negative indices and enumerates only live TradingGump windows belonging to this World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindTrade`.

The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.


## Examples

### Direct read or action

```vb
# Direct read or action
#
# Checks for an open secure-trade window.
#
# Integer: 1 = TRUE if a trade is open, otherwise 0 = FALSE.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # Call once and save value/result. Zero is the first index, one the first number (see this
    # command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

    VAR value = UO.IsTrade()
    UO.Print(CStr(value))
END SUB
```

**Parameter and execution notes:**

- Call once and save value/result. Zero is the first index, one the first number (see this command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

### Another scenario and parameters

```vb
# Another scenario and parameters
#
# Checks for an open secure-trade window.
#
# Integer: 1 = TRUE if a trade is open, otherwise 0 = FALSE.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # before/after are separate snapshots 500 milliseconds apart. This delay does not wait for a
    # particular trade; intermediate changes can be missed.

    VAR before = UO.IsTrade()
    WAIT(500)
    VAR after = UO.IsTrade()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Parameter and execution notes:**

- before/after are separate snapshots 500 milliseconds apart. This delay does not wait for a particular trade; intermediate changes can be missed.

### Complete callable helper

```vb
# Complete callable helper
#
# Checks for an open secure-trade window.
#
# Integer: 1 = TRUE if a trade is open, otherwise 0 = FALSE.
#
# This is a logical result: 1 = TRUE, 0 = FALSE. After VAR result = command(...), use IF result
# = TRUE THEN or IF result = 1 THEN; for a negative result, IF result = FALSE THEN or IF result
# = 0 THEN. Do not quote TRUE/FALSE. Call once and save the result: another call can repeat the
# action or read changed state.

SUB Main()
    # The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are
    # not atomic: the selected window may change between them. For an action, expectedPartner is a
    # saved character serial, not a price or contents validation.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.IsTrade()
END FUNCTION
```

**Parameter and execution notes:**

- The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.
