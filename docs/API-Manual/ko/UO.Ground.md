# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

검색 컨테이너 또는 이동 목적지에 전달할 지면 선택 값을 반환합니다.

## 정확한 구문

```text
UO.Ground() -> Integer
```

## 매개변수

매개변수가 없습니다.

## 반환값

Integer이며 항상 0입니다. 이 0은 유효한 지면 선택 값으로, FALSE, 검색 실패, ID, 그래픽, 지도 번호, 좌표가 아닙니다. Ground() 자체를 성공 여부로 검사하지 말고 이를 사용하는 검색이나 이동의 결과를 검사하세요.

## 동작

- 인수가 없습니다. Ground()만 호출하면 검색, 이동, 타깃 열기, 패킷 전송이나 이전 검색 결과 변경이 없습니다. 로그인 전에도 0입니다.
- FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx, MoveItem의 container/destination 자리에 전달합니다. 검색은 로딩된 객체를 보며 먼 칸을 로딩하지 않습니다. 지면 X/Y/Z는 컨테이너 화면 픽셀이 아닌 월드 좌표입니다.
- FindType(type, color)는 여전히 인벤토리를 검색합니다. 두 번째 인수는 색입니다. 지면은 FindType(type, color, UO.Ground())로 지정하세요. 기존 간결형 FindType/MoveItem의 -1은 인벤토리이며, 호환형 FindTypeEx/FindTypesArrayEx/CountEx는 -1도 지면으로 받습니다. 서로 다른 명령 사이에 숫자를 복사하기보다 UO.Ground() 또는 ground 이름을 권장합니다.
- 일차 자료: [Stealth Ground](https://stealth.od.ua/api/Ground/). 위 규칙과 예제는 이 클라이언트를 설명합니다.

### 내부 함수: 호출부터 결과까지

실제 내부 처리입니다. FindGroundTypes는 완전한 사용자 함수이며 추가 내장 명령이 아닙니다.

#### 1. ExecuteStealthCompatibility

인수 없는 runtime 분기는 게임 bridge 호출 없이 Integer 0을 반환합니다.

Integer이며 항상 0입니다. 이 0은 유효한 지면 선택 값으로, FALSE, 검색 실패, ID, 그래픽, 지도 번호, 좌표가 아닙니다. Ground() 자체를 성공 여부로 검사하지 말고 이를 사용하는 검색이나 이동의 결과를 검사하세요.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

간결형 검색은 명시적 0을 내부 지면 범위로 바꾸며 -1은 기본 인벤토리로 유지합니다. 호환 검색은 0과 기존 -1을 지면으로 받으며 컨테이너 이름은 따로 해석합니다.

FindType(type, color)는 여전히 인벤토리를 검색합니다. 두 번째 인수는 색입니다. 지면은 FindType(type, color, UO.Ground())로 지정하세요. 기존 간결형 FindType/MoveItem의 -1은 인벤토리이며, 호환형 FindTypeEx/FindTypesArrayEx/CountEx는 -1도 지면으로 받습니다. 서로 다른 명령 사이에 숫자를 복사하기보다 UO.Ground() 또는 ground 이름을 권장합니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

간결형 검색은 명시적 0을 내부 지면 범위로 바꾸며 -1은 기본 인벤토리로 유지합니다. 호환 검색은 0과 기존 -1을 지면으로 받으며 컨테이너 이름은 따로 해석합니다.

FindType(type, color)는 여전히 인벤토리를 검색합니다. 두 번째 인수는 색입니다. 지면은 FindType(type, color, UO.Ground())로 지정하세요. 기존 간결형 FindType/MoveItem의 -1은 인벤토리이며, 호환형 FindTypeEx/FindTypesArrayEx/CountEx는 -1도 지면으로 받습니다. 서로 다른 명령 사이에 숫자를 복사하기보다 UO.Ground() 또는 ground 이름을 권장합니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

이동 목적지 해석기는 지면을 0으로 유지합니다. bridge는 월드 좌표를 사용하며 내려놓기 패킷의 컨테이너 필드는 0xFFFFFFFF입니다. API 값과 패킷 필드는 표현이 다릅니다.

0x40001001을 접근 가능한 아이템 serial로 바꾸세요. IsObjectExists가 로딩된 객체를 검사합니다. MoveItem(item, amount, destination, X, Y, Z): amount=0은 전체 스택, Ground()는 지면, GetX/GetY/GetZ는 플레이어 월드 위치입니다. result=1은 클라이언트의 요청 수락, 아니면 0입니다. Ground()의 결과나 서버의 배송 확인이 아닙니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ResolveTransferDestination`.

#### 5. MoveItem

이동 목적지 해석기는 지면을 0으로 유지합니다. bridge는 월드 좌표를 사용하며 내려놓기 패킷의 컨테이너 필드는 0xFFFFFFFF입니다. API 값과 패킷 필드는 표현이 다릅니다.

0x40001001을 접근 가능한 아이템 serial로 바꾸세요. IsObjectExists가 로딩된 객체를 검사합니다. MoveItem(item, amount, destination, X, Y, Z): amount=0은 전체 스택, Ground()는 지면, GetX/GetY/GetZ는 플레이어 월드 위치입니다. result=1은 클라이언트의 요청 수락, 아니면 0입니다. Ground()의 결과나 서버의 배송 확인이 아닙니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `MoveItem`.

인수가 없습니다. Ground()만 호출하면 검색, 이동, 타깃 열기, 패킷 전송이나 이전 검색 결과 변경이 없습니다. 로그인 전에도 0입니다.


## 예제

### 선택 값 읽기

```vb
# 선택 값 읽기
#
# 검색 컨테이너 또는 이동 목적지에 전달할 지면 선택 값을 반환합니다.
#
# Integer이며 항상 0입니다. 이 0은 유효한 지면 선택 값으로, FALSE, 검색 실패, ID, 그래픽, 지도 번호, 좌표가 아닙니다. Ground() 자체를 성공
# 여부로 검사하지 말고 이를 사용하는 검색이나 이동의 결과를 검사하세요.

SUB Main()
    # destination은 Integer 0을 받고 Print가 출력합니다. 물건을 내려놓는 동작은 없습니다.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**매개변수 및 실행 설명:**

- destination은 Integer 0을 받고 Print가 출력합니다. 물건을 내려놓는 동작은 없습니다.

### 지면의 금 스택 검색

```vb
# 지면의 금 스택 검색
#
# 검색 컨테이너 또는 이동 목적지에 전달할 지면 선택 값을 반환합니다.
#
# Integer이며 항상 0입니다. 이 0은 유효한 지면 선택 값으로, FALSE, 검색 실패, ID, 그래픽, 지도 번호, 좌표가 아닙니다. Ground() 자체를 성공
# 여부로 검사하지 말고 이를 사용하는 검색이나 이동의 결과를 검사하세요.

SUB Main()
    # 0x0EED는 금 그래픽, 두 번째 -1은 모든 색입니다. Ground()는 월드, FALSE는 컨테이너 재귀 비활성화입니다. FindTypeEx는 serial 또는
    # 0을 반환하고 <> 0은 그 serial을 검사합니다. FindDistance/FindVertical과 Ignore가 적용됩니다.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**매개변수 및 실행 설명:**

- 0x0EED는 금 그래픽, 두 번째 -1은 모든 색입니다. Ground()는 월드, FALSE는 컨테이너 재귀 비활성화입니다. FindTypeEx는 serial 또는 0을 반환하고 <> 0은 그 serial을 검사합니다. FindDistance/FindVertical과 Ignore가 적용됩니다.

### 두 그래픽을 검색하는 완전한 함수

```vb
# 두 그래픽을 검색하는 완전한 함수
#
# 검색 컨테이너 또는 이동 목적지에 전달할 지면 선택 값을 반환합니다.
#
# Integer이며 항상 0입니다. 이 0은 유효한 지면 선택 값으로, FALSE, 검색 실패, ID, 그래픽, 지도 번호, 좌표가 아닙니다. Ground() 자체를 성공
# 여부로 검사하지 말고 이를 사용하는 검색이나 이동의 결과를 검사하세요.

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height)는 금 0x0EED와 흑진주 0x0F7A를 radius=5,
    # height=10으로 검색합니다. DIM types[1]은 두 칸, colors[0]과 containers[0]은 각각 한 칸입니다. 스택 하나가 객체 하나이며
    # 종류/색은 대안이고 컨테이너가 겹쳐도 ID는 중복되지 않습니다. 저장된 serial 배열을 반환하며 Finally는 두 설정을 복원하고 Main은 각 ID를 출력합니다.
    # 함수 전체가 제공됩니다.

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

**매개변수 및 실행 설명:**

- FindGroundTypes(firstType, secondType, radius, height)는 금 0x0EED와 흑진주 0x0F7A를 radius=5, height=10으로 검색합니다. DIM types[1]은 두 칸, colors[0]과 containers[0]은 각각 한 칸입니다. 스택 하나가 객체 하나이며 종류/색은 대안이고 컨테이너가 겹쳐도 ID는 중복되지 않습니다. 저장된 serial 배열을 반환하며 Finally는 두 설정을 복원하고 Main은 각 ID를 출력합니다. 함수 전체가 제공됩니다.

### 알려진 물건을 플레이어 칸에 놓기

```vb
# 알려진 물건을 플레이어 칸에 놓기
#
# 검색 컨테이너 또는 이동 목적지에 전달할 지면 선택 값을 반환합니다.
#
# Integer이며 항상 0입니다. 이 0은 유효한 지면 선택 값으로, FALSE, 검색 실패, ID, 그래픽, 지도 번호, 좌표가 아닙니다. Ground() 자체를 성공
# 여부로 검사하지 말고 이를 사용하는 검색이나 이동의 결과를 검사하세요.

SUB Main()
    # 0x40001001을 접근 가능한 아이템 serial로 바꾸세요. IsObjectExists가 로딩된 객체를 검사합니다. MoveItem(item, amount,
    # destination, X, Y, Z): amount=0은 전체 스택, Ground()는 지면, GetX/GetY/GetZ는 플레이어 월드 위치입니다. result=1은
    # 클라이언트의 요청 수락, 아니면 0입니다. Ground()의 결과나 서버의 배송 확인이 아닙니다.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**매개변수 및 실행 설명:**

- 0x40001001을 접근 가능한 아이템 serial로 바꾸세요. IsObjectExists가 로딩된 객체를 검사합니다. MoveItem(item, amount, destination, X, Y, Z): amount=0은 전체 스택, Ground()는 지면, GetX/GetY/GetZ는 플레이어 월드 위치입니다. result=1은 클라이언트의 요청 수락, 아니면 0입니다. Ground()의 결과나 서버의 배송 확인이 아닙니다.
