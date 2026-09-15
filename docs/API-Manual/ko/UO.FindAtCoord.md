# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

현재 지도에서 정확한 X/Y 칸에 로드된 월드 객체를 찾습니다.

## 정확한 구문

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## 매개변수

- `X` — 월드 가로 좌표, Integer 0..65535. 필수이며 컨테이너 창의 픽셀 좌표가 아닙니다.
- `Y` — 월드 세로 좌표, Integer 0..65535. 필수입니다. Z, 지도, 타입, 반경에 대한 추가 인수는 없습니다.

## 반환값

Integer: 이 클라이언트 결과 목록에서 처음 일치한 객체의 serial. 결과가 없거나, 플레이어가 없거나 제거되었거나, 좌표가 0..65535 범위 밖이면 0입니다. 타입, 수량, Boolean이 아닌 객체 ID입니다. 32비트를 모두 보존하므로 = TRUE 또는 > 0 대신 <> 0으로 확인합니다. 같은 ID가 FindItem()이 됩니다.

## 동작

- 제거되지 않은 지면 Item과 Mobile을 검사하며 해당 칸의 플레이어도 포함합니다. 컨테이너 내용물과 장착 아이템은 제외합니다. 이들의 X/Y는 월드 좌표가 아닙니다. Ignore 목록의 serial도 제외합니다.
- 정확한 X/Y에 있는 모든 Z 높이가 대상입니다. FindDistance와 FindVertical은 이 검색을 제한하지 않습니다. 현재 월드에 로드된 객체만 보며 지형, 정적 타일, 다른 지도는 로드하지 않습니다. 패킷 전송, 타깃 커서 열기, 아이템 이동은 하지 않습니다.
- 호출할 때마다 이전 검색을 먼저 지웁니다. FindCount()는 객체 수, FindFullQuantity()는 스택 단위 합계(Mobile은 하나), GetFoundItems()는 serial 목록입니다. Item 다음 Mobile을 각 컬렉션의 현재 열거 순서로 검사합니다. 다음 검색이 결과를 바꾸기 전에 목록을 저장하세요.
- 참고: [Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/). 위 순서와 필터는 이 클라이언트의 구현을 설명합니다.

### 내부 함수: 호출부터 결과까지

실제 내부 처리 단계입니다. CountGraphicAt는 완전히 정의된 스크립트 보조 함수이며 추가 내장 명령이 아닙니다.

#### 1. ExecuteStealthCompatibility

등록된 실행 경로가 두 위치 인수 또는 이름 있는 X/Y 인수를 변환하며 브리지의 Integer가 반환값이 됩니다.

Integer: 이 클라이언트 결과 목록에서 처음 일치한 객체의 serial. 결과가 없거나, 플레이어가 없거나 제거되었거나, 좌표가 0..65535 범위 밖이면 0입니다. 타입, 수량, Boolean이 아닌 객체 ID입니다. 32비트를 모두 보존하므로 = TRUE 또는 > 0 대신 <> 0으로 확인합니다. 같은 ID가 FindItem()이 됩니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

게임 스레드에서 이전 결과를 지우고 플레이어와 좌표 범위를 검사한 후 일치하는 지면 Item과 Mobile만 순회합니다. 컨테이너 내용물은 제외합니다.

제거되지 않은 지면 Item과 Mobile을 검사하며 해당 칸의 플레이어도 포함합니다. 컨테이너 내용물과 장착 아이템은 제외합니다. 이들의 X/Y는 월드 좌표가 아닙니다. Ignore 목록의 serial도 제외합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `FindAtCoord`.

#### 3. RegisterFound

일치한 객체마다 개수를 증가시키고 serial을 추가합니다. 첫 serial은 FindItem으로 남으며 Item.Amount는 최소 한 단위, Mobile은 한 단위를 더합니다.

호출할 때마다 이전 검색을 먼저 지웁니다. FindCount()는 객체 수, FindFullQuantity()는 스택 단위 합계(Mobile은 하나), GetFoundItems()는 serial 목록입니다. Item 다음 Mobile을 각 컬렉션의 현재 열거 순서로 검사합니다. 다음 검색이 결과를 바꾸기 전에 목록을 저장하세요.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `RegisterFound`.

정확한 X/Y에 있는 모든 Z 높이가 대상입니다. FindDistance와 FindVertical은 이 검색을 제한하지 않습니다. 현재 월드에 로드된 객체만 보며 지형, 정적 타일, 다른 지도는 로드하지 않습니다. 패킷 전송, 타깃 커서 열기, 아이템 이동은 하지 않습니다.


## 예제

### 객체 ID 하나 읽기

```vb
# 객체 ID 하나 읽기
#
# 현재 지도에서 정확한 X/Y 칸에 로드된 월드 객체를 찾습니다.
#
# Integer: 이 클라이언트 결과 목록에서 처음 일치한 객체의 serial. 결과가 없거나, 플레이어가 없거나 제거되었거나, 좌표가 0..65535 범위 밖이면
# 0입니다. 타입, 수량, Boolean이 아닌 객체 ID입니다. 32비트를 모두 보존하므로 = TRUE 또는 > 0 대신 <> 0으로 확인합니다. 같은 ID가
# FindItem()이 됩니다.

SUB Main()
    # 1445와 1690은 월드 X/Y 예시이므로 원하는 칸으로 바꾸세요. id는 serial을 저장하고 HEX는 형식을 바꿉니다. <> 0은 결과 존재 여부이며 수량이
    # 아닙니다.

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**매개변수 및 실행 설명:**

- 1445와 1690은 월드 X/Y 예시이므로 원하는 칸으로 바꾸세요. id는 serial을 저장하고 HEX는 형식을 바꿉니다. <> 0은 결과 존재 여부이며 수량이 아닙니다.

### 플레이어 칸의 모든 객체 확인

```vb
# 플레이어 칸의 모든 객체 확인
#
# 현재 지도에서 정확한 X/Y 칸에 로드된 월드 객체를 찾습니다.
#
# Integer: 이 클라이언트 결과 목록에서 처음 일치한 객체의 serial. 결과가 없거나, 플레이어가 없거나 제거되었거나, 좌표가 0..65535 범위 밖이면
# 0입니다. 타입, 수량, Boolean이 아닌 객체 ID입니다. 32비트를 모두 보존하므로 = TRUE 또는 > 0 대신 <> 0으로 확인합니다. 같은 ID가
# FindItem()이 됩니다.

SUB Main()
    # x/y는 플레이어에서 읽고 ids는 목록을 저장합니다. 각 ID는 스택 전체를 포함하여 객체 하나를 나타냅니다. GetType(id)는 graphic/body를
    # 읽습니다. 아이템을 선택하거나 사용하지 않습니다.

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**매개변수 및 실행 설명:**

- x/y는 플레이어에서 읽고 ids는 목록을 저장합니다. 각 ID는 스택 전체를 포함하여 객체 하나를 나타냅니다. GetType(id)는 graphic/body를 읽습니다. 아이템을 선택하거나 사용하지 않습니다.

### 완전한 CountGraphicAt 보조 함수

```vb
# 완전한 CountGraphicAt 보조 함수
#
# 현재 지도에서 정확한 X/Y 칸에 로드된 월드 객체를 찾습니다.
#
# Integer: 이 클라이언트 결과 목록에서 처음 일치한 객체의 serial. 결과가 없거나, 플레이어가 없거나 제거되었거나, 좌표가 0..65535 범위 밖이면
# 0입니다. 타입, 수량, Boolean이 아닌 객체 ID입니다. 32비트를 모두 보존하므로 = TRUE 또는 > 0 대신 <> 0으로 확인합니다. 같은 ID가
# FindItem()이 됩니다.

SUB Main()
    # CountGraphicAt(x, y, graphic)는 한 번 검색한 뒤 저장한 ID를 순회하여 해당 그래픽의 객체를 셉니다. graphic=0x0EED는 금화입니다.
    # 반환값은 객체/스택 수이며 단위 총합이나 true/false가 아닙니다. 스택 하나는 하나로 셉니다. Main 아래에 전체 정의가 있습니다.

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**매개변수 및 실행 설명:**

- CountGraphicAt(x, y, graphic)는 한 번 검색한 뒤 저장한 ID를 순회하여 해당 그래픽의 객체를 셉니다. graphic=0x0EED는 금화입니다. 반환값은 객체/스택 수이며 단위 총합이나 true/false가 아닙니다. 스택 하나는 하나로 셉니다. Main 아래에 전체 정의가 있습니다.
