# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

값을 JSON 파일에 저장합니다.

## 정확한 구문

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## 매개변수

- `fileName` — 필수 파일 경로. 상대 경로는 Include에서 호출해도 메인 스크립트 폴더 기준입니다. 절대 경로도 허용합니다.
- `value` — 숫자, String, 배열, List, Dictionary, JsonBoolean 또는 JsonNull. Dictionary 키는 String이어야 합니다. 참조 공유는 허용하지만 순환 참조는 오류입니다.
- `indented` — Integer 플래그:0은 압축 형식, 0이 아니면 들여쓰기. 기본값:Stringify=0, Save=1.

## 반환값

Unit:반환값 없음. 정상 종료가 성공이며 오류는 Try/Catch로 처리합니다.

## 동작

- UO. 없는 로컬 Basic 함수이며 게임 패킷을 보내지 않습니다. JsonParse/JsonStringify는 메모리에서 작동합니다. Basic True는 숫자1로 저장되므로 JSON true에는 JsonBoolean(True)를 사용합니다. JsonNull()은 null과0을 구분합니다.
- 유한한 숫자만 허용합니다. 정수 값이 ±9007199254740991 범위를 넘으면 오류이며 큰 ID는 String으로 저장합니다. 다른 숫자는 Double 정밀도입니다. 엄격한 UTF-8을 사용하며 입력 BOM은 허용하고 출력에는 없습니다. 잘못된 Unicode는 오류입니다.
- 제한:1048576 UTF-16 코드 단위,4MiB,64단계 컨테이너,100000 값 노드. 초과하면 오류입니다. 분석/읽기는 새 컬렉션을 만들며 저장은 메모리 객체를 복제하지 않습니다.
- Save는 전체 데이터를 검증하고 부모 폴더를 만든 뒤 대상 옆의 고유 임시 파일에 쓰고 버퍼를 비운 후 이동/교체합니다. 교체 전 실패/취소는 기존 파일을 보존합니다. OS가 허용하면 임시 파일을 정리합니다. 완료된 교체는 취소하지 않습니다.
- 256개 값마다,4096바이트/문자 블록 사이 및 교체 전에 일시정지/중지를 확인합니다. 추가 스레드를 만들지 않으며 개별 OS 호출은 강제 중단할 수 없습니다. 동시 저장은 마지막 성공 교체가 남으며 DB 트랜잭션이 아닙니다.

### 내부 함수: 호출부터 결과까지

값을 JSON 파일에 저장합니다.

#### 1. Save

필수 파일 경로. 상대 경로는 Include에서 호출해도 메인 스크립트 폴더 기준입니다. 절대 경로도 허용합니다. 숫자, String, 배열, List, Dictionary, JsonBoolean 또는 JsonNull. Dictionary 키는 String이어야 합니다. 참조 공유는 허용하지만 순환 참조는 오류입니다. Integer 플래그:0은 압축 형식, 0이 아니면 들여쓰기. 기본값:Stringify=0, Save=1.

Unit:반환값 없음. 정상 종료가 성공이며 오류는 Try/Catch로 처리합니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 함수 `Save`.

Config.Load(fileName, defaults)는 새 Dictionary를 반환합니다. 저장된 최상위 키가 defaults의 깊은 복사본을 덮어쓰고 중첩 객체는 통째로 교체합니다. Config.Save(fileName, settings)는 명시적으로 저장하며 반환값이 없습니다. Config.GetFlag(settings, key, fallback=False)는1/True 또는0/False를 반환하며 기존 값이 불리언이 아니면 오류입니다. Config.SetFlag(settings, key, value)는 메모리만 변경하고 반환값이 없습니다. Load/Save는 String 키 Dictionary가 필요합니다. 내부 Private RequireObject는 바깥 종류를 확인하고 JSON 변환은 전체 내용을 검증합니다.


## 예제

### JsonSave · 1

```vb
# JsonSave · 1
#
# 값을 JSON 파일에 저장합니다.
#
# Unit:반환값 없음. 정상 종료가 성공이며 오류는 Try/Catch로 처리합니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# 값을 JSON 파일에 저장합니다.
#
# Unit:반환값 없음. 정상 종료가 성공이며 오류는 Try/Catch로 처리합니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# 값을 JSON 파일에 저장합니다.
#
# Unit:반환값 없음. 정상 종료가 성공이며 오류는 Try/Catch로 처리합니다.

Option Explicit On
Sub Main()
    # Main을 실행합니다. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**매개변수 및 실행 설명:**

- Main을 실행합니다. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
