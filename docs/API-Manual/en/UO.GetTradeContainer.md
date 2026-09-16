# UO.GetTradeContainer

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Returns the numeric serial of either trade container.

## Exact syntax

```text
UO.GetTradeContainer(TradeNum:Any, Num:Any) -> Any
```

## Parameters

- `TradeNum` — Integer current window number, 1 through TradeCount(). Zero and negative numbers are invalid. Not a serial.
- `Num` — 1 selects your container; 2 selects the partner container; other values return 0.

## Returns

Integer: 32 container-serial bits, or 0 for a missing window/invalid Num. Not a graphic/type. The high bit is preserved: test <> 0, not > 0 or = TRUE.

## Behavior

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade number windows from 1; TradeContainer/TradeOpponent/TradeName and every TradeCheck form index them from 0. This client deliberately preserves those conventions; reference manuals from different engines disagree on origins.
- Reads run on the game thread using live windows in this World. Disposed windows are excluded. Reading sends no packets and waits for no response. UI ordering may change when windows open, close or move to the front; an index is not a persistent identifier.
- ConfirmTrade and writing your TradeCheck box send a packet only when acceptance changes. The server controls the other box. CancelTrade sends cancellation once. 1/TRUE means local state/handling, not completed transfer. Names and both checks do not prove that offered items stayed unchanged.

### Internal functions: from call to result

The C# call path is explained below, followed by executable Basic helpers. The scripts do not reimplement the network protocol.

#### 1. ExecuteStealthCompatibility

Registration selects by argument count and NumberConversions converts numbers. The two-argument TradeCheck validates sides 1/2 and maps them to bridge indices 0/1. Legacy serials pass through ToHex.

Integer: 32 container-serial bits, or 0 for a missing window/invalid Num. Not a graphic/type. The high bit is preserved: test <> 0, not > 0 or = TRUE.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetTradeContainer

Invoke marshals reading/writing to the game thread with script cancellation; the method reads ID1/ID2, LocalSerial, OpponentName or acceptance flags from the selected TradingGump.

Returns the numeric serial of either trade container.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetTradeContainer`.

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
# Returns the numeric serial of either trade container.
#
# Integer: 32 container-serial bits, or 0 for a missing window/invalid Num. Not a graphic/type.
# The high bit is preserved: test <> 0, not > 0 or = TRUE.

SUB Main()
    # Call once and save value/result. Zero is the first index, one the first number (see this
    # command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

    VAR value = UO.GetTradeContainer(1, 1)
    UO.Print(HEX(value))
END SUB
```

**Parameter and execution notes:**

- Call once and save value/result. Zero is the first index, one the first number (see this command’s syntax). HEX displays numeric serials; CStr displays numbers or text.

### Another scenario and parameters

```vb
# Another scenario and parameters
#
# Returns the numeric serial of either trade container.
#
# Integer: 32 container-serial bits, or 0 for a missing window/invalid Num. Not a graphic/type.
# The high bit is preserved: test <> 0, not > 0 or = TRUE.

SUB Main()
    # total captures the window count; index is the current index/number. Enumeration accepts
    # nothing. The GetTradeContainer example reads your side (1) and the other side (2) of window 1.

    VAR ours = UO.GetTradeContainer(1, 1)
    VAR theirs = UO.GetTradeContainer(1, 2)
    UO.Print(HEX(ours) + " / " + HEX(theirs))
END SUB
```

**Parameter and execution notes:**

- total captures the window count; index is the current index/number. Enumeration accepts nothing. The GetTradeContainer example reads your side (1) and the other side (2) of window 1.

### Complete callable helper

```vb
# Complete callable helper
#
# Returns the numeric serial of either trade container.
#
# Integer: 32 container-serial bits, or 0 for a missing window/invalid Num. Not a graphic/type.
# The high bit is preserved: test <> 0, not > 0 or = TRUE.

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
    RETURN UO.GetTradeContainer(index, 1)
END FUNCTION
```

**Parameter and execution notes:**

- The helper is fully defined and called by Main. Range/ID checks reduce mistakes but calls are not atomic: the selected window may change between them. For an action, expectedPartner is a saved character serial, not a price or contents validation.
