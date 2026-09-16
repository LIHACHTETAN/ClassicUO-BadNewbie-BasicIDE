# UO.TradeCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

열린 거래 창 수를 반환합니다.

## 정확한 구문

```text
UO.TradeCount() -> Integer
```

## 매개변수

매개변수가 없습니다.

## 반환값

Integer: 0 이상의 창 수입니다. Boolean이 아니며 존재 여부는 > 0으로 확인합니다.

## 동작

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade는 1부터, TradeContainer/TradeOpponent/TradeName과 모든 TradeCheck 형식은 0부터입니다. 이 클라이언트는 해당 규칙을 유지하며 다른 엔진의 외부 설명서는 시작점이 다를 수 있습니다.
- 게임 스레드에서 현재 World의 열린 창을 읽으며 닫힌 창은 제외합니다. 읽기는 패킷을 보내거나 응답을 기다리지 않습니다. 열기, 닫기, 앞으로 가져오기로 UI 순서가 바뀌므로 인덱스는 영구 ID가 아닙니다.
- ConfirmTrade와 내 TradeCheck 쓰기는 동의가 바뀔 때만 전송합니다. 상대 체크는 서버가 제어하며 CancelTrade는 한 번 전송합니다. 1/TRUE는 로컬 상태/처리이며 이전 완료가 아닙니다. 이름과 양쪽 체크만으로 아이템이 그대로임을 증명할 수 없습니다.

### 내부 함수: 호출부터 결과까지

아래에서 C# 호출 경로를 설명한 뒤 실행 가능한 Basic 예제를 제공합니다. 스크립트가 네트워크 프로토콜을 다시 구현하지는 않습니다.

#### 1. TradeCount

등록은 인수 수로 형식을 선택하고 NumberConversions는 숫자를 변환합니다. 인수 2개 TradeCheck는 측 1/2를 검사하여 bridge의 0/1로 매핑합니다. 기존 serial은 ToHex로 형식화합니다.

Integer: 0 이상의 창 수입니다. Boolean이 아니며 존재 여부는 > 0으로 확인합니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `TradeCount`.

#### 2. TradeCount

Invoke는 스크립트 취소를 고려하여 읽기/쓰기를 게임 스레드로 옮기며 선택한 TradingGump의 ID1/ID2, LocalSerial, OpponentName 또는 체크를 읽습니다.

열린 거래 창 수를 반환합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `TradeCount`.

보조 함수는 모두 정의되어 있으며 Main에서 호출합니다. 범위/ID 검사는 실수를 줄이지만 여러 호출은 원자적이지 않아 중간에 창이 바뀔 수 있습니다. expectedPartner는 저장한 캐릭터 serial이며 가격/내용 검증은 아닙니다.


## 예제

### 직접 읽기 또는 동작

```vb
# 직접 읽기 또는 동작
#
# 열린 거래 창 수를 반환합니다.
#
# Integer: 0 이상의 창 수입니다. Boolean이 아니며 존재 여부는 > 0으로 확인합니다.

SUB Main()
    # 한 번 호출하여 value/result에 저장합니다. 첫 인덱스는 0, 첫 번호는 1입니다(구문 참고). HEX는 숫자 serial, CStr은 수나 텍스트를
    # 표시합니다.

    VAR value = UO.TradeCount()
    UO.Print(CStr(value))
END SUB
```

**매개변수 및 실행 설명:**

- 한 번 호출하여 value/result에 저장합니다. 첫 인덱스는 0, 첫 번호는 1입니다(구문 참고). HEX는 숫자 serial, CStr은 수나 텍스트를 표시합니다.

### 다른 상황과 매개변수

```vb
# 다른 상황과 매개변수
#
# 열린 거래 창 수를 반환합니다.
#
# Integer: 0 이상의 창 수입니다. Boolean이 아니며 존재 여부는 > 0으로 확인합니다.

SUB Main()
    # before/after는 500밀리초 간격의 별도 스냅샷입니다. 특정 거래를 기다리지 않으며 중간 변경을 놓칠 수 있습니다.

    VAR before = UO.TradeCount()
    WAIT(500)
    VAR after = UO.TradeCount()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**매개변수 및 실행 설명:**

- before/after는 500밀리초 간격의 별도 스냅샷입니다. 특정 거래를 기다리지 않으며 중간 변경을 놓칠 수 있습니다.

### 완전한 보조 함수

```vb
# 완전한 보조 함수
#
# 열린 거래 창 수를 반환합니다.
#
# Integer: 0 이상의 창 수입니다. Boolean이 아니며 존재 여부는 > 0으로 확인합니다.

SUB Main()
    # 보조 함수는 모두 정의되어 있으며 Main에서 호출합니다. 범위/ID 검사는 실수를 줄이지만 여러 호출은 원자적이지 않아 중간에 창이 바뀔 수 있습니다.
    # expectedPartner는 저장한 캐릭터 serial이며 가격/내용 검증은 아닙니다.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.TradeCount()
END FUNCTION
```

**매개변수 및 실행 설명:**

- 보조 함수는 모두 정의되어 있으며 Main에서 호출합니다. 범위/ID 검사는 실수를 줄이지만 여러 호출은 원자적이지 않아 중간에 창이 바뀔 수 있습니다. expectedPartner는 저장한 캐릭터 serial이며 가격/내용 검증은 아닙니다.
