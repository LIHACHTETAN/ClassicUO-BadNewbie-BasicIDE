# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

컨테이너 또는 지면에서 지정한 그래픽과 색상을 검색하고 일치하는 ID 하나를 반환합니다.

## 정확한 구문

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## 매개변수

- `ObjType` — Graphic/body이며 객체 serial이 아닙니다. 0..65534는 특정 그래픽, -1 또는 0xFFFF는 모든 그래픽입니다. 다른 음수 Integer도 필터를 해제합니다.
- `Color` — Hue이며 수량이 아닙니다. 0은 염색 없음, -1 또는 0xFFFF는 모든 색상입니다. 다른 음수 Integer도 색상 필터를 해제합니다.
- `Container` — 지면: UO.Ground(), 0, -1, 0xFFFFFFFF 또는 문자열 ground. 배낭: 문자열 backpack 또는 그 serial. 십진수/hex serial과 AddObject 이름도 가능합니다. my는 장비와 중첩 가방을 포함한 자신의 전체 소유품입니다. 알 수 없는 이름은 스크립트 오류입니다. 확인한 serial을 검사하세요. 명시적인 0은 지면을 선택합니다. API마다 숫자 의미가 달라 ground/backpack 이름이 더 명확합니다.
- `InSub` — 필수 TRUE/FALSE(1/0). FALSE는 특정 컨테이너의 직접 내용만, TRUE는 로드된 중첩 가방도 검색합니다. 지면에는 영향이 없습니다. my는 이미 전체 소유품을 선택합니다.

## 반환값

Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result = TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

## 동작

- 네 위치 인수가 모두 필수이며 생략할 수 없습니다.
- 지면은 이 스크립트의 FindDistance/FindVertical을 적용하고 self를 제외하며 일치하는 Item과 Mobile을 포함합니다. 특정 컨테이너에는 거리/높이 제한을 적용하지 않습니다. 두 범위 모두 Ignore와 파괴된 객체를 제외합니다.
- 순회 전에 FindItem, FindCount, FindFullQuantity, GetFoundItems를 비웁니다. 검색 결과가 없으면 0과 빈 배열이 남습니다. FindFullQuantity는 Item의 max(1, Amount)와 Mobile마다 1을 더합니다. FindQuantity는 FindItem의 현재 수량을 읽습니다. 다음 검색이 결과를 바꾸기 전에 필요한 GetFoundItems를 저장하세요.
- Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.
- 이미 받은 데이터만 읽습니다. 컨테이너를 열거나 셀을 로드하거나 물건을 옮기지 않습니다. 결과가 없다고 서버의 상자가 비었다고 단정할 수 없습니다. 연결이 필요하면 Connected를 검사하세요. 검색 자체는 로컬 상태를 읽습니다.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). 참고 문서는 마지막 ID와 잘못된 컨테이너의 배낭 대체를 설명합니다. 여기서는 첫 로컬 결과를 유지하고 알 수 없는 이름을 배낭으로 바꾸지 않습니다. Ground는 0도 허용합니다. 로컬 FindDistance 기본값은 18, 최대값은 255입니다.

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

#### 4. FindType

Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.

지면은 이 스크립트의 FindDistance/FindVertical을 적용하고 self를 제외하며 일치하는 Item과 Mobile을 포함합니다. 특정 컨테이너에는 거리/높이 제한을 적용하지 않습니다. 두 범위 모두 Ignore와 파괴된 객체를 제외합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `FindType`.

#### 5. MatchesFindIdentity

Graphic/body이며 객체 serial이 아닙니다. 0..65534는 특정 그래픽, -1 또는 0xFFFF는 모든 그래픽입니다. 다른 음수 Integer도 필터를 해제합니다. Hue이며 수량이 아닙니다. 0은 염색 없음, -1 또는 0xFFFF는 모든 색상입니다. 다른 음수 Integer도 색상 필터를 해제합니다.

Bridge는 로드된 Item을 한 번 순회하고, 지면이면 Mobile도 순회합니다. 종류, 색상, 하나 이상의 컨테이너가 일치해야 합니다. 객체마다 한 번 등록하며 조합마다 전체 세계를 다시 검색하지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `MatchesFindIdentity`.

#### 6. MatchesFindContainer

필수 TRUE/FALSE(1/0). FALSE는 특정 컨테이너의 직접 내용만, TRUE는 로드된 중첩 가방도 검색합니다. 지면에는 영향이 없습니다. my는 이미 전체 소유품을 선택합니다.

지면은 이 스크립트의 FindDistance/FindVertical을 적용하고 self를 제외하며 일치하는 Item과 Mobile을 포함합니다. 특정 컨테이너에는 거리/높이 제한을 적용하지 않습니다. 두 범위 모두 Ignore와 파괴된 객체를 제외합니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `MatchesFindContainer`.

#### 7. RegisterFound

순회 전에 FindItem, FindCount, FindFullQuantity, GetFoundItems를 비웁니다. 검색 결과가 없으면 0과 빈 배열이 남습니다. FindFullQuantity는 Item의 max(1, Amount)와 Mobile마다 1을 더합니다. FindQuantity는 FindItem의 현재 수량을 읽습니다. 다음 검색이 결과를 바꾸기 전에 필요한 GetFoundItems를 저장하세요.

Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result = TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `RegisterFound`.

이미 받은 데이터만 읽습니다. 컨테이너를 열거나 셀을 로드하거나 물건을 옮기지 않습니다. 결과가 없다고 서버의 상자가 비었다고 단정할 수 없습니다. 연결이 필요하면 Connected를 검사하세요. 검색 자체는 로컬 상태를 읽습니다.


## 예제

### 배낭의 직접 내용

```vb
# 배낭의 직접 내용
#
# 컨테이너 또는 지면에서 지정한 그래픽과 색상을 검색하고 일치하는 ID 하나를 반환합니다.
#
# Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result =
# TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

SUB Main()
    # 0x0EED는 금화, -1은 모든 hue입니다. backpack/FALSE는 중첩 가방을 제외합니다. 첫 hex ID(0x 없음), 객체 수, 총 단위를 출력합니다.
    # 20과 50의 두 스택은 객체 2개, 단위 70개입니다.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**매개변수 및 실행 설명:**

- 0x0EED는 금화, -1은 모든 hue입니다. backpack/FALSE는 중첩 가방을 제외합니다. 첫 hex ID(0x 없음), 객체 수, 총 단위를 출력합니다. 20과 50의 두 스택은 객체 2개, 단위 70개입니다.

### 완전한 임시 지면 검색 함수

```vb
# 완전한 임시 지면 검색 함수
#
# 컨테이너 또는 지면에서 지정한 그래픽과 색상을 검색하고 일치하는 ID 하나를 반환합니다.
#
# Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result =
# TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

SUB Main()
    # radius=5, height=10은 FindGoldNearSelf 안에서만 적용합니다. Finally는 Return이나 오류에도 두 제한을 복원합니다. 금화
    # serial 또는 0을 반환하고 Main은 <> 0으로 검사합니다.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**매개변수 및 실행 설명:**

- radius=5, height=10은 FindGoldNearSelf 안에서만 적용합니다. Finally는 Return이나 오류에도 두 제한을 복원합니다. 금화 serial 또는 0을 반환하고 Main은 <> 0으로 검사합니다.

### 이름 있는 컨테이너와 중첩 가방

```vb
# 이름 있는 컨테이너와 중첩 가방
#
# 컨테이너 또는 지면에서 지정한 그래픽과 색상을 검색하고 일치하는 ID 하나를 반환합니다.
#
# Integer: 로컬 순회에서 처음 일치한 serial, 없으면 0. 그래픽, 수량, 배열, Boolean이 아닙니다. result <> 0을 검사하고 result =
# TRUE 또는 result = 1은 사용하지 마세요. 한 스택은 한 객체, Mobile은 한 객체이자 한 단위입니다. 순서는 거리순이 아니며 항상 일정하지 않습니다.

SUB Main()
    # GetSerial로 backpack을 확인하고 0 검사로 지면 오선택을 방지합니다. AddObject는 search_bag를 저장합니다. TRUE는 중첩 가방을 포함하고
    # GetFoundItems는 목록을 복사하며 IsObjectExists는 ID를 다시 확인합니다.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**매개변수 및 실행 설명:**

- GetSerial로 backpack을 확인하고 0 검사로 지면 오선택을 방지합니다. AddObject는 search_bag를 저장합니다. TRUE는 중첩 가방을 포함하고 GetFoundItems는 목록을 복사하며 IsObjectExists는 ID를 다시 확인합니다.
