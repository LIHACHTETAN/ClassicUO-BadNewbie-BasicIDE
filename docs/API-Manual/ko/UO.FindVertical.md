# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

검색에 허용되는 기본 높이 차이를 읽거나 변경합니다.

## 정확한 구문

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## 매개변수

- `value` — 선택적 Integer입니다. 인수가 없으면 읽고, value가 있으면 설정합니다. 0..120 범위로 제한하며 음수는 무제한이 아닌 0입니다. 새 runtime 기본값은 2이고 복원한 상태는 다를 수 있습니다. 소수는 0 방향으로 잘라 내며 decimal/0x 숫자 문자열도 허용합니다. 암시적 변환을 피하려면 Integer를 사용하세요.

## 반환값

인수 없음: Integer, 현재 제한(월드 Z 단위의 높이 차이)이며 ID, 개수, Boolean이 아닙니다. 0은 실패가 아니라 범위 0입니다. value 있음: Unit, 반환값이 없으며 TRUE/FALSE나 이전 값도 아닙니다. 설정 후 FindVertical()으로 저장값을 읽으세요.

## 동작

- 높이는 abs(object.Z - player.Z)로 양방향 경계를 포함합니다. 0은 같은 Z만 허용합니다. 층 번호나 수평 타일 수가 아닙니다.
- 현재 스크립트 runtime에 저장하며 그 프로시저들이 공유합니다. 독립 runtime의 설정은 별개입니다. 읽기/쓰기는 검색, FindItem/FindCount/GetFoundItems 초기화, 패킷 전송, 캐릭터 이동, 먼 객체 로딩을 하지 않습니다.
- FindTypeEx와 FindTypesArrayEx는 지면 검색에만 이 제한을 사용하고 컨테이너 내용에는 적용하지 않습니다. type, hue, Ignore, 로딩된 객체 조건은 유지됩니다. FindAtCoord는 두 제한을 무시합니다. 확장 명령의 명시적 distance/maxZ는 기본값을 대체할 수 있습니다. 해당 인수의 -1은 기본값 사용이며 이 설정을 -1로 쓰는 것과 다릅니다. FindList는 컨테이너에서도 Z를 검사하므로 위 예외가 적용되지 않습니다.
- 임시 검색 전에 저장하고 Finally에서 복원하세요. 자동 복구는 없습니다. Finally는 정상 종료와 포착 가능한 스크립트 오류에 적용되며 비상 중지는 정리 수단으로 사용하면 안 됩니다.
- 참고: [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). 이 클라이언트의 고유 기본값/범위는 FindDistance 18 / 0..255, FindVertical 2 / 0..120입니다. 위 Basic 문법과 확장 필터는 이 프로젝트를 설명합니다.

### 내부 함수: 호출부터 결과까지

실제 내부 단계입니다. CountGroundInRange는 완전한 사용자 함수이며 숨겨진 내장 명령이 아닙니다.

#### 1. ExecuteStealthCompatibility

인수 0개는 읽기를, 1개는 value 변환 후 쓰기를 선택합니다. 메타데이터는 Integer와 Unit을 구분합니다.

인수 없음: Integer, 현재 제한(월드 Z 단위의 높이 차이)이며 ID, 개수, Boolean이 아닙니다. 0은 실패가 아니라 범위 0입니다. value 있음: Unit, 반환값이 없으며 TRUE/FALSE나 이전 값도 아닙니다. 설정 후 FindVertical()으로 저장값을 읽으세요.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

Bridge는 runtime 설정을 읽거나 정수를 제한하여 저장합니다. 월드를 순회하지 않습니다.

인수 없음: Integer, 현재 제한(월드 Z 단위의 높이 차이)이며 ID, 개수, Boolean이 아닙니다. 0은 실패가 아니라 범위 0입니다. value 있음: Unit, 반환값이 없으며 TRUE/FALSE나 이전 값도 아닙니다. 설정 후 FindVertical()으로 저장값을 읽으세요.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `GetFindVertical`.

#### 3. SetFindVertical

Bridge는 runtime 설정을 읽거나 정수를 제한하여 저장합니다. 월드를 순회하지 않습니다.

선택적 Integer입니다. 인수가 없으면 읽고, value가 있으면 설정합니다. 0..120 범위로 제한하며 음수는 무제한이 아닌 0입니다. 새 runtime 기본값은 2이고 복원한 상태는 다를 수 있습니다. 소수는 0 방향으로 잘라 내며 decimal/0x 숫자 문자열도 허용합니다. 암시적 변환을 피하려면 Integer를 사용하세요.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `SetFindVertical`.

#### 4. FindType

후속 검색은 명시적 대체 값이 없을 때 설정을 읽습니다. 지면 Item과 Mobile에 해당 거리 및 높이 필터가 적용됩니다.

FindTypeEx와 FindTypesArrayEx는 지면 검색에만 이 제한을 사용하고 컨테이너 내용에는 적용하지 않습니다. type, hue, Ignore, 로딩된 객체 조건은 유지됩니다. FindAtCoord는 두 제한을 무시합니다. 확장 명령의 명시적 distance/maxZ는 기본값을 대체할 수 있습니다. 해당 인수의 -1은 기본값 사용이며 이 설정을 -1로 쓰는 것과 다릅니다. FindList는 컨테이너에서도 Z를 검사하므로 위 예외가 적용되지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `FindType`.

#### 5. FindList

후속 검색은 명시적 대체 값이 없을 때 설정을 읽습니다. 지면 Item과 Mobile에 해당 거리 및 높이 필터가 적용됩니다.

FindTypeEx와 FindTypesArrayEx는 지면 검색에만 이 제한을 사용하고 컨테이너 내용에는 적용하지 않습니다. type, hue, Ignore, 로딩된 객체 조건은 유지됩니다. FindAtCoord는 두 제한을 무시합니다. 확장 명령의 명시적 distance/maxZ는 기본값을 대체할 수 있습니다. 해당 인수의 -1은 기본값 사용이며 이 설정을 -1로 쓰는 것과 다릅니다. FindList는 컨테이너에서도 Z를 검사하므로 위 예외가 적용되지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `FindList`.

현재 스크립트 runtime에 저장하며 그 프로시저들이 공유합니다. 독립 runtime의 설정은 별개입니다. 읽기/쓰기는 검색, FindItem/FindCount/GetFoundItems 초기화, 패킷 전송, 캐릭터 이동, 먼 객체 로딩을 하지 않습니다.


## 예제

### 읽기, 설정 및 범위 제한 확인

```vb
# 읽기, 설정 및 범위 제한 확인
#
# 검색에 허용되는 기본 높이 차이를 읽거나 변경합니다.
#
# 인수 없음: Integer, 현재 제한(월드 Z 단위의 높이 차이)이며 ID, 개수, Boolean이 아닙니다. 0은 실패가 아니라 범위 0입니다. value 있음:
# Unit, 반환값이 없으며 TRUE/FALSE나 이전 값도 아닙니다. 설정 후 FindVertical()으로 저장값을 읽으세요.

SUB Main()
    # previous는 실제 설정을 저장합니다. value:=10은 일반 제한이며 1000은 120으로 제한됩니다. Print는 별도 읽기로 결과를 출력합니다.
    # Finally는 previous를 복원합니다.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**매개변수 및 실행 설명:**

- previous는 실제 설정을 저장합니다. value:=10은 일반 제한이며 1000은 120으로 제한됩니다. Print는 별도 읽기로 결과를 출력합니다. Finally는 previous를 복원합니다.

### 임시 지면 검색

```vb
# 임시 지면 검색
#
# 검색에 허용되는 기본 높이 차이를 읽거나 변경합니다.
#
# 인수 없음: Integer, 현재 제한(월드 Z 단위의 높이 차이)이며 ID, 개수, Boolean이 아닙니다. 0은 실패가 아니라 범위 0입니다. value 있음:
# Unit, 반환값이 없으며 TRUE/FALSE나 이전 값도 아닙니다. 설정 후 FindVertical()으로 저장값을 읽으세요.

SUB Main()
    # previous는 호출자의 설정입니다. 10은 FindVertical만 변경하고 다른 제한은 유지합니다. 0x0EED는 금 그래픽, -1은 모든 색,
    # Container=-1은 월드, FALSE는 컨테이너 재귀 없음입니다. id는 serial이며 <> 0은 존재 여부 검사입니다. FindCount는 객체/스택
    # 개수입니다. Finally는 설정만 복원하고 검색 목록은 복원하지 않습니다.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**매개변수 및 실행 설명:**

- previous는 호출자의 설정입니다. 10은 FindVertical만 변경하고 다른 제한은 유지합니다. 0x0EED는 금 그래픽, -1은 모든 색, Container=-1은 월드, FALSE는 컨테이너 재귀 없음입니다. id는 serial이며 <> 0은 존재 여부 검사입니다. FindCount는 객체/스택 개수입니다. Finally는 설정만 복원하고 검색 목록은 복원하지 않습니다.

### 완전한 CountGroundInRange 함수

```vb
# 완전한 CountGroundInRange 함수
#
# 검색에 허용되는 기본 높이 차이를 읽거나 변경합니다.
#
# 인수 없음: Integer, 현재 제한(월드 Z 단위의 높이 차이)이며 ID, 개수, Boolean이 아닙니다. 0은 실패가 아니라 범위 0입니다. value 있음:
# Unit, 반환값이 없으며 TRUE/FALSE나 이전 값도 아닙니다. 설정 후 FindVertical()으로 저장값을 읽으세요.

SUB Main()
    # CountGroundInRange(graphic, radius, height)는 두 제한을 저장하고 radius=5, height=10으로 graphic=0x0EED를
    # 검색하여 FindCount()를 반환합니다. 한 스택은 객체 하나입니다. 완전한 함수는 Main 아래에 있습니다. Return으로 나가도 Finally가 두 제한을
    # 복원하며 검색 결과는 유지됩니다.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**매개변수 및 실행 설명:**

- CountGroundInRange(graphic, radius, height)는 두 제한을 저장하고 radius=5, height=10으로 graphic=0x0EED를 검색하여 FindCount()를 반환합니다. 한 스택은 객체 하나입니다. 완전한 함수는 Main 아래에 있습니다. Return으로 나가도 Finally가 두 제한을 복원하며 검색 결과는 유지됩니다.
