# UO.GetTradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Returns the trading character’s numeric serial.

## Exact syntax

```text
UO.GetTradeOpponent(TradeNum:Any) -> Any
```

## Parameters

- `TradeNum` — Integer current window number, 1 through TradeCount(). Zero and negative numbers are invalid. Not a serial.

## Returns

Integer: partner character serial from the window’s LocalSerial; 0 if absent. Not a container or Boolean; test <> 0.

## Behavior

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.
- Reads run on the game thread using live windows in this World. Disposed windows are excluded. Reading sends no packets and waits for no response. UI ordering may change when windows open, close or move to the front; an index is not a persistent identifier.
- ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local state/handling, not completed transfer. Names and both checks do not prove that offered items stayed unchanged.

### Internal functions: from call to result

The C# call path is explained below, followed by executable Basic helpers. The scripts do not reimplement the network protocol.

#### 1. ExecuteStealthCompatibility

Registration selects by argument count and NumberConversions converts numbers. The two-argument TradeCheck validates sides 1/2 and maps them to bridge indices 0/1. Legacy serials pass through ToHex.

Integer: partner character serial from the window’s LocalSerial; 0 if absent. Not a container or Boolean; test <> 0.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponent

Invoke marshals reading/writing to the game thread with script cancellation; the method reads ID1/ID2, LocalSerial, OpponentName or acceptance flags from the selected TradingGump.

Returns the trading character’s numeric serial.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetTradeOpponent`.

#### 3. FindNumberedTrade

FindNumberedTrade validates number>0 before subtracting 1; FindTrade rejects negative indices and enumerates only live TradingGump windows belonging to this World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `FindNumberedTrade`.

The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.


## Examples

### Direct read or action

```vb
# Direct read or action
#
# Returns the trading character’s numeric serial.
#
# Integer: partner character serial from the window’s LocalSerial; 0 if absent. Not a container
# or Boolean; test <> 0.

SUB Main()
    # Call once and save value/result. Zero is the first index, one the first number (see this
    # command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

    VAR value = UO.GetTradeOpponent(1)
    UO.Print(HEX(value))
END SUB
```

**Parameter and execution notes:**

- Call once and save value/result. Zero is the first index, one the first number (see this command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

### Another scenario and parameters

```vb
# Another scenario and parameters
#
# Returns the trading character’s numeric serial.
#
# Integer: partner character serial from the window’s LocalSerial; 0 if absent. Not a container
# or Boolean; test <> 0.

SUB Main()
    # total captures the window count; index is the current index/number. Enumeration accepts
    # nothing. The GetTradeContainer example reads your side (1) and the other side (2) of window 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponent(index)
        UO.Print(CStr(index) + ": " + HEX(value))
    NEXT
END SUB
```

**Parameter and execution notes:**

- total captures the window count; index is the current index/number. Enumeration accepts nothing. The GetTradeContainer example reads your side (1) and the other side (2) of window 1.

### Complete callable helper

```vb
# Complete callable helper
#
# Returns the trading character’s numeric serial.
#
# Integer: partner character serial from the window’s LocalSerial; 0 if absent. Not a container
# or Boolean; test <> 0.

SUB Main()
    # The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are
    # not atomic: the selected window may change between them. For an action, expectedPartner is a
    # saved character serial, not a price or contents validation.

    VAR value = ReadTradeValue(1)
    UO.Print(HEX(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 1 OR index >= total + 1 THEN
        RETURN 0
    END IF
    RETURN UO.GetTradeOpponent(index)
END FUNCTION
```

**Parameter and execution notes:**

- The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.
