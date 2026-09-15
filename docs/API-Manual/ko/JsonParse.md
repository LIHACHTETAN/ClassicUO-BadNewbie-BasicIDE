# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

JSON 문자열을 Basic 값으로 분석합니다.

## 정확한 구문

```text
JsonParse(text:String) -> Any
```

## 매개변수

- `text` — 필수 JSON String으로 완전한 값 하나만 포함합니다. 키는 대소문자를 구분하며 중복할 수 없습니다. 주석과 마지막 쉼표는 오류입니다.

## 반환값

Any:객체→Dictionary, 배열→List, 문자열→String, 숫자→Integer 또는 Decimal(Double), true/false→JsonBoolean, null→JsonNull. 성공 여부가 아닙니다.

## 동작

- UO. 없는 로컬 Basic 함수이며 게임 패킷을 보내지 않습니다. JsonParse/JsonStringify는 메모리에서 작동합니다. Basic True는 숫자1로 저장되므로 JSON true에는 JsonBoolean(True)를 사용합니다. JsonNull()은 null과0을 구분합니다.
- 유한한 숫자만 허용합니다. 정수 값이 ±9007199254740991 범위를 넘으면 오류이며 큰 ID는 String으로 저장합니다. 다른 숫자는 Double 정밀도입니다. 엄격한 UTF-8을 사용하며 입력 BOM은 허용하고 출력에는 없습니다. 잘못된 Unicode는 오류입니다.
- 제한:1048576 UTF-16 코드 단위,4MiB,64단계 컨테이너,100000 값 노드. 초과하면 오류입니다. 분석/읽기는 새 컬렉션을 만들며 저장은 메모리 객체를 복제하지 않습니다.
- Save는 전체 데이터를 검증하고 부모 폴더를 만든 뒤 대상 옆의 고유 임시 파일에 쓰고 버퍼를 비운 후 이동/교체합니다. 교체 전 실패/취소는 기존 파일을 보존합니다. OS가 허용하면 임시 파일을 정리합니다. 완료된 교체는 취소하지 않습니다.
- 256개 값마다,4096바이트/문자 블록 사이 및 교체 전에 일시정지/중지를 확인합니다. 추가 스레드를 만들지 않으며 개별 OS 호출은 강제 중단할 수 없습니다. 동시 저장은 마지막 성공 교체가 남으며 DB 트랜잭션이 아닙니다.

### 내부 함수: 호출부터 결과까지

JSON 문자열을 Basic 값으로 분석합니다.

#### 1. Parse

필수 JSON String으로 완전한 값 하나만 포함합니다. 키는 대소문자를 구분하며 중복할 수 없습니다. 주석과 마지막 쉼표는 오류입니다.

Any:객체→Dictionary, 배열→List, 문자열→String, 숫자→Integer 또는 Decimal(Double), true/false→JsonBoolean, null→JsonNull. 성공 여부가 아닙니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 함수 `Parse`.

Config.Load(fileName, defaults)는 새 Dictionary를 반환합니다. 저장된 최상위 키가 defaults의 깊은 복사본을 덮어쓰고 중첩 객체는 통째로 교체합니다. Config.Save(fileName, settings)는 명시적으로 저장하며 반환값이 없습니다. Config.GetFlag(settings, key, fallback=False)는1/True 또는0/False를 반환하며 기존 값이 불리언이 아니면 오류입니다. Config.SetFlag(settings, key, value)는 메모리만 변경하고 반환값이 없습니다. Load/Save는 String 키 Dictionary가 필요합니다. 내부 Private RequireObject는 바깥 종류를 확인하고 JSON 변환은 전체 내용을 검증합니다.


## 예제

### JsonParse · 1

```vb
# JsonParse · 1
#
# JSON 문자열을 Basic 값으로 분석합니다.
#
# Any:객체→Dictionary, 배열→List, 문자열→String, 숫자→Integer 또는 Decimal(Double), true/false→JsonBoolean,
# null→JsonNull. 성공 여부가 아닙니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# JSON 문자열을 Basic 값으로 분석합니다.
#
# Any:객체→Dictionary, 배열→List, 문자열→String, 숫자→Integer 또는 Decimal(Double), true/false→JsonBoolean,
# null→JsonNull. 성공 여부가 아닙니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2
    # → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# JSON 문자열을 Basic 값으로 분석합니다.
#
# Any:객체→Dictionary, 배열→List, 문자열→String, 숫자→Integer 또는 Decimal(Double), true/false→JsonBoolean,
# null→JsonNull. 성공 여부가 아닙니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. text={"x":1,"x":2} → Catch → "duplicate key".
