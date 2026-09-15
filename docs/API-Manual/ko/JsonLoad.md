# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

JSON 파일을 읽습니다.

## 정확한 구문

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## 매개변수

- `fileName` — 필수 파일 경로. 상대 경로는 Include에서 호출해도 메인 스크립트 폴더 기준입니다. 절대 경로도 허용합니다.
- `defaultValue` — 파일이나 폴더가 없을 때만 사용하는 선택적 대체 값. JSON 변환을 통한 독립 복사본을 반환합니다. 내용, 인코딩 및 접근 오류를 숨기지 않습니다.

## 반환값

Any로 JsonParse와 같은 타입 대응입니다. 파일이 없고 defaultValue도 없으면 오류입니다.

## 동작

- UO. 없는 로컬 Basic 함수이며 게임 패킷을 보내지 않습니다. JsonParse/JsonStringify는 메모리에서 작동합니다. Basic True는 숫자1로 저장되므로 JSON true에는 JsonBoolean(True)를 사용합니다. JsonNull()은 null과0을 구분합니다.
- 유한한 숫자만 허용합니다. 정수 값이 ±9007199254740991 범위를 넘으면 오류이며 큰 ID는 String으로 저장합니다. 다른 숫자는 Double 정밀도입니다. 엄격한 UTF-8을 사용하며 입력 BOM은 허용하고 출력에는 없습니다. 잘못된 Unicode는 오류입니다.
- 제한:1048576 UTF-16 코드 단위,4MiB,64단계 컨테이너,100000 값 노드. 초과하면 오류입니다. 분석/읽기는 새 컬렉션을 만들며 저장은 메모리 객체를 복제하지 않습니다.
- Save는 전체 데이터를 검증하고 부모 폴더를 만든 뒤 대상 옆의 고유 임시 파일에 쓰고 버퍼를 비운 후 이동/교체합니다. 교체 전 실패/취소는 기존 파일을 보존합니다. OS가 허용하면 임시 파일을 정리합니다. 완료된 교체는 취소하지 않습니다.
- 256개 값마다,4096바이트/문자 블록 사이 및 교체 전에 일시정지/중지를 확인합니다. 추가 스레드를 만들지 않으며 개별 OS 호출은 강제 중단할 수 없습니다. 동시 저장은 마지막 성공 교체가 남으며 DB 트랜잭션이 아닙니다.

### 내부 함수: 호출부터 결과까지

JSON 파일을 읽습니다.

#### 1. LoadCore

필수 파일 경로. 상대 경로는 Include에서 호출해도 메인 스크립트 폴더 기준입니다. 절대 경로도 허용합니다. 파일이나 폴더가 없을 때만 사용하는 선택적 대체 값. JSON 변환을 통한 독립 복사본을 반환합니다. 내용, 인코딩 및 접근 오류를 숨기지 않습니다.

Any로 JsonParse와 같은 타입 대응입니다. 파일이 없고 defaultValue도 없으면 오류입니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 함수 `LoadCore`.

Config.Load(fileName, defaults)는 새 Dictionary를 반환합니다. 저장된 최상위 키가 defaults의 깊은 복사본을 덮어쓰고 중첩 객체는 통째로 교체합니다. Config.Save(fileName, settings)는 명시적으로 저장하며 반환값이 없습니다. Config.GetFlag(settings, key, fallback=False)는1/True 또는0/False를 반환하며 기존 값이 불리언이 아니면 오류입니다. Config.SetFlag(settings, key, value)는 메모리만 변경하고 반환값이 없습니다. Load/Save는 String 키 Dictionary가 필요합니다. 내부 Private RequireObject는 바깥 종류를 확인하고 JSON 변환은 전체 내용을 검증합니다.


## 예제

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# JSON 파일을 읽습니다.
#
# Any로 JsonParse와 같은 타입 대응입니다. 파일이 없고 defaultValue도 없으면 오류입니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# JSON 파일을 읽습니다.
#
# Any로 JsonParse와 같은 타입 대응입니다. 파일이 없고 defaultValue도 없으면 오류입니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# JSON 파일을 읽습니다.
#
# Any로 JsonParse와 같은 타입 대응입니다. 파일이 없고 defaultValue도 없으면 오류입니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
