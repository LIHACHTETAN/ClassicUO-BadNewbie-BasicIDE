# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

여러 그래픽, 색상, 컨테이너를 한 번 순회하여 ID 하나를 반환합니다. 전체 목록은 GetFoundItems로 읽습니다.

## 정확한 구문

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## 매개변수

- `ObjTypes` — Graphic/body이며 객체 serial이 아닙니다. 0..65534는 특정 그래픽, -1 또는 0xFFFF는 모든 그래픽입니다. 다른 음수 Integer도 필터를 해제합니다.
- `Colors` — Hue이며 수량이 아닙니다. 0은 염색 없음, -1 또는 0xFFFF는 모든 색상입니다. 다른 음수 Integer도 색상 필터를 해제합니다.
- `Containers` — 지면: UO.Ground(), 0, -1, 0xFFFFFFFF 또는 문자열 ground. 배낭: 문자열 backpack 또는 그 serial. 십진수/hex serial과 AddObject 이름도 가능합니다. my는 장비와 중첩 가방을 포함한 자신의 전체 소유품입니다. 알 수 없는 이름은 스크립트 오류입니다. 확인한 serial을 검사하세요. 명시적인 0은 지면을 선택합니다. API마다 숫자 의미가 달라 ground/backpack 이름이 더 명확합니다.
- `InSub` — 필수 TRUE/FALSE(1/0). FALSE는 특정 컨테이너의 직접 내용만, TRUE는 로드된 중첩 가방도 검색합니다. 지면에는 영향이 없습니다. my는 이미 전체 소유품을 선택합니다.

## 반환값

Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result = TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

## 동작

- Array를 전달합니다. 단일 값도 한 요소로 허용합니다. DIM values[1]은 인덱스 0과 1을 만드므로 모두 대입하세요. 종류와 색상은 독립적인 선택지이며 같은 인덱스끼리 짝짓지 않습니다. 어느 위치든 와일드카드가 있거나 종류/색상 배열이 비면 해당 필터가 사라집니다. 빈 컨테이너 배열은 자신의 소유품입니다. 반복되거나 겹치는 컨테이너도 ID를 중복 생성하지 않습니다.
- 네 위치 인수가 모두 필수이며 생략할 수 없습니다.
- 지면은 이 스크립트의 FindDistance/FindVertical을 적용하고 self를 제외하며 일치하는 Item과 Mobile을 포함합니다. 특정 컨테이너에는 거리/높이 제한을 적용하지 않습니다. 두 범위 모두 Ignore와 파괴된 객체를 제외합니다.
- 순회 전에 FindItem, FindCount, FindFullQuantity, GetFoundItems를 비웁니다. 검색 결과가 없으면 0과 빈 배열이 남습니다. FindFullQuantity는 Item의 max(1, Amount)와 Mobile마다 1을 더합니다. FindQuantity는 FindItem의 현재 수량을 읽습니다. 다음 검색이 결과를 바꾸기 전에 필요한 GetFoundItems를 저장하세요.
- Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.
- 이미 받은 데이터만 읽습니다. 컨테이너를 열거나 셀을 로드하거나 물건을 옮기지 않습니다. 결과가 없다고 서버의 상자가 비었다고 단정할 수 없습니다. 연결이 필요하면 Connected를 검사하세요. 검색 자체는 로컬 상태를 읽습니다.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). 참고 문서는 마지막 ID와 잘못된 컨테이너의 배낭 대체를 설명합니다. 여기서는 첫 로컬 결과를 유지하고 알 수 없는 이름을 배낭으로 바꾸지 않습니다. Ground는 0도 허용합니다. 로컬 FindDistance 기본값은 18, 최대값은 255입니다.

### 내부 함수: 호출부터 결과까지

실제 구현 단계이며 추가 공개 명령이 아닙니다. 아래 FindGoldNearSelf와 SearchTypesIn은 전체 정의가 제공되는 스크립트 함수입니다.

#### 1. ExecuteStealthCompatibility

Runtime은 숫자 필터를 변환하고 컨테이너 이름을 별도로 확인합니다. 지면 선택자는 bridge 내부의 세계 범위로 변환됩니다.

네 위치 인수가 모두 필수이며 생략할 수 없습니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

지면: UO.Ground(), 0, -1, 0xFFFFFFFF 또는 문자열 ground. 배낭: 문자열 backpack 또는 그 serial. 십진수/hex serial과 AddObject 이름도 가능합니다. my는 장비와 중첩 가방을 포함한 자신의 전체 소유품입니다. 알 수 없는 이름은 스크립트 오류입니다. 확인한 serial을 검사하세요. 명시적인 0은 지면을 선택합니다. API마다 숫자 의미가 달라 ground/backpack 이름이 더 명확합니다.

Runtime은 숫자 필터를 변환하고 컨테이너 이름을 별도로 확인합니다. 지면 선택자는 bridge 내부의 세계 범위로 변환됩니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

순회 전에 FindItem, FindCount, FindFullQuantity, GetFoundItems를 비웁니다. 검색 결과가 없으면 0과 빈 배열이 남습니다. FindFullQuantity는 Item의 max(1, Amount)와 Mobile마다 1을 더합니다. FindQuantity는 FindItem의 현재 수량을 읽습니다. 다음 검색이 결과를 바꾸기 전에 필요한 GetFoundItems를 저장하세요.

Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result = TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `ResetFindResults`.

#### 4. BuildFindIdentityMask

Array를 전달합니다. 단일 값도 한 요소로 허용합니다. DIM values[1]은 인덱스 0과 1을 만드므로 모두 대입하세요. 종류와 색상은 독립적인 선택지이며 같은 인덱스끼리 짝짓지 않습니다. 어느 위치든 와일드카드가 있거나 종류/색상 배열이 비면 해당 필터가 사라집니다. 빈 컨테이너 배열은 자신의 소유품입니다. 반복되거나 겹치는 컨테이너도 ID를 중복 생성하지 않습니다.

Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `BuildFindIdentityMask`.

#### 5. FindTypes

Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.

지면은 이 스크립트의 FindDistance/FindVertical을 적용하고 self를 제외하며 일치하는 Item과 Mobile을 포함합니다. 특정 컨테이너에는 거리/높이 제한을 적용하지 않습니다. 두 범위 모두 Ignore와 파괴된 객체를 제외합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body이며 객체 serial이 아닙니다. 0..65534는 특정 그래픽, -1 또는 0xFFFF는 모든 그래픽입니다. 다른 음수 Integer도 필터를 해제합니다. Hue이며 수량이 아닙니다. 0은 염색 없음, -1 또는 0xFFFF는 모든 색상입니다. 다른 음수 Integer도 색상 필터를 해제합니다.

Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `MatchesFindIdentity`.

#### 7. MatchesFindContainer

필수 TRUE/FALSE(1/0). FALSE는 특정 컨테이너의 직접 내용만, TRUE는 로드된 중첩 가방도 검색합니다. 지면에는 영향이 없습니다. my는 이미 전체 소유품을 선택합니다.

지면은 이 스크립트의 FindDistance/FindVertical을 적용하고 self를 제외하며 일치하는 Item과 Mobile을 포함합니다. 특정 컨테이너에는 거리/높이 제한을 적용하지 않습니다. 두 범위 모두 Ignore와 파괴된 객체를 제외합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `MatchesFindContainer`.

#### 8. RegisterFound

순회 전에 FindItem, FindCount, FindFullQuantity, GetFoundItems를 비웁니다. 검색 결과가 없으면 0과 빈 배열이 남습니다. FindFullQuantity는 Item의 max(1, Amount)와 Mobile마다 1을 더합니다. FindQuantity는 FindItem의 현재 수량을 읽습니다. 다음 검색이 결과를 바꾸기 전에 필요한 GetFoundItems를 저장하세요.

Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result = TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `RegisterFound`.

이미 받은 데이터만 읽습니다. 컨테이너를 열거나 셀을 로드하거나 물건을 옮기지 않습니다. 결과가 없다고 서버의 상자가 비었다고 단정할 수 없습니다. 연결이 필요하면 Connected를 검사하세요. 검색 자체는 로컬 상태를 읽습니다.


## 예제

### 지면의 두 그래픽

```vb
# 지면의 두 그래픽
#
# 여러 그래픽, 색상, 컨테이너를 한 번 순회하여 ID 하나를 반환합니다. 전체 목록은 GetFoundItems로 읽습니다.
#
# Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result =
# TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

SUB Main()
    # types는 금화 0x0EED와 흑진주 0x0F7A, color=-1은 모든 색상, Ground는 세계입니다. FALSE는 지면에 영향이 없습니다. 현재 검색 제한을
    # 적용하며 ID, 객체 수, 단위를 출력합니다.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**매개변수 및 실행 설명:**

- types는 금화 0x0EED와 흑진주 0x0F7A, color=-1은 모든 색상, Ground는 세계입니다. FALSE는 지면에 영향이 없습니다. 현재 검색 제한을 적용하며 ID, 객체 수, 단위를 출력합니다.

### 배낭과 지면의 금화

```vb
# 배낭과 지면의 금화
#
# 여러 그래픽, 색상, 컨테이너를 한 번 순회하여 ID 하나를 반환합니다. 전체 목록은 GetFoundItems로 읽습니다.
#
# Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result =
# TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

SUB Main()
    # types는 금화만, colors는 모든 hue입니다. Containers는 backpack과 지면이고 TRUE는 중첩 가방을 포함합니다. 양쪽 범위의 객체/스택과
    # 단위를 중복 없이 출력합니다.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**매개변수 및 실행 설명:**

- types는 금화만, colors는 모든 hue입니다. Containers는 backpack과 지면이고 TRUE는 중첩 가방을 포함합니다. 양쪽 범위의 객체/스택과 단위를 중복 없이 출력합니다.

### 저장한 목록을 반환하는 완전한 함수

```vb
# 저장한 목록을 반환하는 완전한 함수
#
# 여러 그래픽, 색상, 컨테이너를 한 번 순회하여 ID 하나를 반환합니다. 전체 목록은 GetFoundItems로 읽습니다.
#
# Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result =
# TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

SUB Main()
    # SearchTypesIn(container,firstType,secondType)은 Array<Integer>를 반환하지만 내장 명령은 단일 Integer ID를
    # 반환합니다. 전체 함수가 배열을 채우고 재귀 검색 후 즉시 GetFoundItems를 복사합니다. Main은 저장한 ID를 검사하고 출력합니다.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**매개변수 및 실행 설명:**

- SearchTypesIn(container,firstType,secondType)은 Array<Integer>를 반환하지만 내장 명령은 단일 Integer ID를 반환합니다. 전체 함수가 배열을 채우고 재귀 검색 후 즉시 GetFoundItems를 복사합니다. Main은 저장한 ID를 검사하고 출력합니다.
