# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

동의 체크를 읽으며 인수 3개 형식은 내 체크도 변경합니다.

## 정확한 구문

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## 매개변수

- `windowIndex` — 현재 정수 창 인덱스: 0..TradeCount()-1. 음수/존재하지 않는 인덱스는 빈 결과입니다. serial이 아닙니다.
- `TradeNum` — 현재 정수 창 인덱스: 0..TradeCount()-1. 음수/존재하지 않는 인덱스는 빈 결과입니다. serial이 아닙니다.
- `Num` — 인수 2개 형식만: 1은 내 체크, 2는 상대 체크이며 그 외에는 0입니다. 여기서 TradeNum은 0부터입니다.
- `checkbox` — 인수 3개 형식만: 0은 내 체크, 1은 읽기 전용 상대 체크이며 다른 값은 0을 반환합니다.
- `stateValue` — checkbox=0일 때만 0/FALSE는 해제, 0이 아닌 수/TRUE는 동의 설정입니다. checkbox=1이면 무시합니다.

## 반환값

Integer: 선택한 체크가 켜져 있으면 1 = TRUE, 꺼짐/창 없음/잘못된 측이면 0 = FALSE입니다. 쓰기는 거래 성공이 아닌 상태를 반환하므로 해제하면 0입니다.

논리 결과입니다: 1 = TRUE, 0 = FALSE. VAR result = command(...)로 저장한 뒤 IF result = TRUE THEN 또는 IF result = 1 THEN을 사용합니다. 부정 결과는 IF result = FALSE THEN 또는 IF result = 0 THEN입니다. TRUE/FALSE에 따옴표를 쓰지 않습니다. 한 번 호출하고 결과를 저장하세요. 다시 호출하면 동작을 반복하거나 바뀐 상태를 읽을 수 있습니다.

## 동작

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade는 1부터, TradeContainer/TradeOpponent/TradeName과 모든 TradeCheck 형식은 0부터입니다. 이 클라이언트는 해당 규칙을 유지하며 다른 엔진의 외부 설명서는 시작점이 다를 수 있습니다.
- 게임 스레드에서 현재 World의 열린 창을 읽으며 닫힌 창은 제외합니다. 읽기는 패킷을 보내거나 응답을 기다리지 않습니다. 열기, 닫기, 앞으로 가져오기로 UI 순서가 바뀌므로 인덱스는 영구 ID가 아닙니다.
- ConfirmTrade와 내 TradeCheck 쓰기는 동의가 바뀔 때만 전송합니다. 상대 체크는 서버가 제어하며 CancelTrade는 한 번 전송합니다. 1/TRUE는 로컬 상태/처리이며 이전 완료가 아닙니다. 이름과 양쪽 체크만으로 아이템이 그대로임을 증명할 수 없습니다.

### 내부 함수: 호출부터 결과까지

아래에서 C# 호출 경로를 설명한 뒤 실행 가능한 Basic 예제를 제공합니다. 스크립트가 네트워크 프로토콜을 다시 구현하지는 않습니다.

#### 1. TradeCheck

등록은 인수 수로 형식을 선택하고 NumberConversions는 숫자를 변환합니다. 인수 2개 TradeCheck는 측 1/2를 검사하여 bridge의 0/1로 매핑합니다. 기존 serial은 ToHex로 형식화합니다.

Integer: 선택한 체크가 켜져 있으면 1 = TRUE, 꺼짐/창 없음/잘못된 측이면 0 = FALSE입니다. 쓰기는 거래 성공이 아닌 상태를 반환하므로 해제하면 0입니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `TradeCheck`.

#### 2. TradeCheck

Invoke는 스크립트 취소를 고려하여 읽기/쓰기를 게임 스레드로 옮기며 선택한 TradingGump의 ID1/ID2, LocalSerial, OpponentName 또는 체크를 읽습니다.

동의 체크를 읽으며 인수 3개 형식은 내 체크도 변경합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade는 1을 빼기 전에 number>0을 검사하며 FindTrade는 음수 인덱스를 거부하고 현재 World의 열린 TradingGump만 열거합니다.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade는 1부터, TradeContainer/TradeOpponent/TradeName과 모든 TradeCheck 형식은 0부터입니다. 이 클라이언트는 해당 규칙을 유지하며 다른 엔진의 외부 설명서는 시작점이 다를 수 있습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `FindTrade`.

#### 4. AcceptTrade

내 체크 변경 시 GameActions.AcceptTrade는 코드 2, ID1, 상태로 Send_TradeResponse를 호출합니다. 읽기와 같은 값 설정은 패킷을 보내지 않습니다.

Integer: 선택한 체크가 켜져 있으면 1 = TRUE, 꺼짐/창 없음/잘못된 측이면 0 = FALSE입니다. 쓰기는 거래 성공이 아닌 상태를 반환하므로 해제하면 0입니다.

프로젝트 소스: `src/ClassicUO.Client/Game/GameActions.cs`; 함수 `AcceptTrade`.

보조 함수는 모두 정의되어 있으며 Main에서 호출합니다. 범위/ID 검사는 실수를 줄이지만 여러 호출은 원자적이지 않아 중간에 창이 바뀔 수 있습니다. expectedPartner는 저장한 캐릭터 serial이며 가격/내용 검증은 아닙니다.


## 예제

### 직접 읽기 또는 동작

```vb
# 직접 읽기 또는 동작
#
# 동의 체크를 읽으며 인수 3개 형식은 내 체크도 변경합니다.
#
# Integer: 선택한 체크가 켜져 있으면 1 = TRUE, 꺼짐/창 없음/잘못된 측이면 0 = FALSE입니다. 쓰기는 거래 성공이 아닌 상태를 반환하므로 해제하면
# 0입니다.
#
# 논리 결과입니다: 1 = TRUE, 0 = FALSE. VAR result = command(...)로 저장한 뒤 IF result = TRUE THEN 또는 IF
# result = 1 THEN을 사용합니다. 부정 결과는 IF result = FALSE THEN 또는 IF result = 0 THEN입니다. TRUE/FALSE에
# 따옴표를 쓰지 않습니다. 한 번 호출하고 결과를 저장하세요. 다시 호출하면 동작을 반복하거나 바뀐 상태를 읽을 수 있습니다.

SUB Main()
    # TradeCheck(0)과 TradeCheck(0,1)은 첫 창의 내 체크, TradeCheck(0,2)는 상대 체크를 읽습니다. 쓰기나 자동 동의는 없습니다.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**매개변수 및 실행 설명:**

- TradeCheck(0)과 TradeCheck(0,1)은 첫 창의 내 체크, TradeCheck(0,2)는 상대 체크를 읽습니다. 쓰기나 자동 동의는 없습니다.

### 다른 상황과 매개변수

```vb
# 다른 상황과 매개변수
#
# 동의 체크를 읽으며 인수 3개 형식은 내 체크도 변경합니다.
#
# Integer: 선택한 체크가 켜져 있으면 1 = TRUE, 꺼짐/창 없음/잘못된 측이면 0 = FALSE입니다. 쓰기는 거래 성공이 아닌 상태를 반환하므로 해제하면
# 0입니다.
#
# 논리 결과입니다: 1 = TRUE, 0 = FALSE. VAR result = command(...)로 저장한 뒤 IF result = TRUE THEN 또는 IF
# result = 1 THEN을 사용합니다. 부정 결과는 IF result = FALSE THEN 또는 IF result = 0 THEN입니다. TRUE/FALSE에
# 따옴표를 쓰지 않습니다. 한 번 호출하고 결과를 저장하세요. 다시 호출하면 동작을 반복하거나 바뀐 상태를 읽을 수 있습니다.

SUB Main()
    # TradeCheck(0,0,FALSE)는 내 동의를 해제합니다. TradeCheck(0,1,FALSE)는 상대를 읽기만 하며 FALSE로 상대 동의를 변경할 수
    # 없습니다. 해제 후 0은 정상입니다.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**매개변수 및 실행 설명:**

- TradeCheck(0,0,FALSE)는 내 동의를 해제합니다. TradeCheck(0,1,FALSE)는 상대를 읽기만 하며 FALSE로 상대 동의를 변경할 수 없습니다. 해제 후 0은 정상입니다.

### 완전한 보조 함수

```vb
# 완전한 보조 함수
#
# 동의 체크를 읽으며 인수 3개 형식은 내 체크도 변경합니다.
#
# Integer: 선택한 체크가 켜져 있으면 1 = TRUE, 꺼짐/창 없음/잘못된 측이면 0 = FALSE입니다. 쓰기는 거래 성공이 아닌 상태를 반환하므로 해제하면
# 0입니다.
#
# 논리 결과입니다: 1 = TRUE, 0 = FALSE. VAR result = command(...)로 저장한 뒤 IF result = TRUE THEN 또는 IF
# result = 1 THEN을 사용합니다. 부정 결과는 IF result = FALSE THEN 또는 IF result = 0 THEN입니다. TRUE/FALSE에
# 따옴표를 쓰지 않습니다. 한 번 호출하고 결과를 저장하세요. 다시 호출하면 동작을 반복하거나 바뀐 상태를 읽을 수 있습니다.

SUB Main()
    # 보조 함수는 모두 정의되어 있으며 Main에서 호출합니다. 범위/ID 검사는 실수를 줄이지만 여러 호출은 원자적이지 않아 중간에 창이 바뀔 수 있습니다.
    # expectedPartner는 저장한 캐릭터 serial이며 가격/내용 검증은 아닙니다.

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

**매개변수 및 실행 설명:**

- 보조 함수는 모두 정의되어 있으며 Main에서 호출합니다. 범위/ID 검사는 실수를 줄이지만 여러 호출은 원자적이지 않아 중간에 창이 바뀔 수 있습니다. expectedPartner는 저장한 캐릭터 serial이며 가격/내용 검증은 아닙니다.
