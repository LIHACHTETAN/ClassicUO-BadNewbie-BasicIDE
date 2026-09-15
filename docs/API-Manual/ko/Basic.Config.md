# JSON / Config.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Config.bas는 Scripts/Include에 있습니다. 메인 스크립트 옆에 Include/Config.bas를 두고 Include "Config.bas"를 적습니다. 영구 JSON과 독립적인 기본값을 결합합니다.

## 정확한 구문

```text
Include "Config.bas"
settings = Config.Load(fileName, defaults)
Config.Save(fileName, settings)
enabled = Config.GetFlag(settings, key, fallback=False)
Config.SetFlag(settings, key, value)
JsonParse(text) / JsonStringify(value[, indented=0])
JsonLoad(fileName[, defaultValue]) / JsonSave(fileName, value[, indented=1])
JsonKind(value) / JsonBoolean(value) / JsonNull() / flag.Value()
```

## 매개변수

- `fileName` — 필수 파일 경로. 상대 경로는 Include에서 호출해도 메인 스크립트 폴더 기준입니다. 절대 경로도 허용합니다.
- `defaults (Config.Load)` — Config.Load에 필수인 기본값 Dictionary입니다. 깊은 JSON 복사본에 저장된 최상위 키를 병합하며 원본을 변경하지 않습니다. defaults를 생략할 수 없습니다.
- `defaultValue (JsonLoad)` — 파일이나 폴더가 없을 때만 사용하는 선택적 대체 값. JSON 변환을 통한 독립 복사본을 반환합니다. 내용, 인코딩 및 접근 오류를 숨기지 않습니다.
- `settings / value` — 숫자, String, 배열, List, Dictionary, JsonBoolean 또는 JsonNull. Dictionary 키는 String이어야 합니다. 참조 공유는 허용하지만 순환 참조는 오류입니다.
- `indented` — Integer 플래그:0은 압축 형식, 0이 아니면 들여쓰기. 기본값:Stringify=0, Save=1.
- `key / fallback` — Config.Load(fileName, defaults)는 새 Dictionary를 반환합니다. 저장된 최상위 키가 defaults의 깊은 복사본을 덮어쓰고 중첩 객체는 통째로 교체합니다. Config.Save(fileName, settings)는 명시적으로 저장하며 반환값이 없습니다. Config.GetFlag(settings, key, fallback=False)는1/True 또는0/False를 반환하며 기존 값이 불리언이 아니면 오류입니다. Config.SetFlag(settings, key, value)는 메모리만 변경하고 반환값이 없습니다. Load/Save는 String 키 Dictionary가 필요합니다. 내부 Private RequireObject는 바깥 종류를 확인하고 JSON 변환은 전체 내용을 검증합니다.

## 반환값

Config.Load(fileName, defaults)는 새 Dictionary를 반환합니다. 저장된 최상위 키가 defaults의 깊은 복사본을 덮어쓰고 중첩 객체는 통째로 교체합니다. Config.Save(fileName, settings)는 명시적으로 저장하며 반환값이 없습니다. Config.GetFlag(settings, key, fallback=False)는1/True 또는0/False를 반환하며 기존 값이 불리언이 아니면 오류입니다. Config.SetFlag(settings, key, value)는 메모리만 변경하고 반환값이 없습니다. Load/Save는 String 키 Dictionary가 필요합니다. 내부 Private RequireObject는 바깥 종류를 확인하고 JSON 변환은 전체 내용을 검증합니다.

## 동작

- UO. 없는 로컬 Basic 함수이며 게임 패킷을 보내지 않습니다. JsonParse/JsonStringify는 메모리에서 작동합니다. Basic True는 숫자1로 저장되므로 JSON true에는 JsonBoolean(True)를 사용합니다. JsonNull()은 null과0을 구분합니다.
- 유한한 숫자만 허용합니다. 정수 값이 ±9007199254740991 범위를 넘으면 오류이며 큰 ID는 String으로 저장합니다. 다른 숫자는 Double 정밀도입니다. 엄격한 UTF-8을 사용하며 입력 BOM은 허용하고 출력에는 없습니다. 잘못된 Unicode는 오류입니다.
- 제한:1048576 UTF-16 코드 단위,4MiB,64단계 컨테이너,100000 값 노드. 초과하면 오류입니다. 분석/읽기는 새 컬렉션을 만들며 저장은 메모리 객체를 복제하지 않습니다.
- Save는 전체 데이터를 검증하고 부모 폴더를 만든 뒤 대상 옆의 고유 임시 파일에 쓰고 버퍼를 비운 후 이동/교체합니다. 교체 전 실패/취소는 기존 파일을 보존합니다. OS가 허용하면 임시 파일을 정리합니다. 완료된 교체는 취소하지 않습니다.
- 256개 값마다,4096바이트/문자 블록 사이 및 교체 전에 일시정지/중지를 확인합니다. 추가 스레드를 만들지 않으며 개별 OS 호출은 강제 중단할 수 없습니다. 동시 저장은 마지막 성공 교체가 남으며 DB 트랜잭션이 아닙니다.

## 예제

### 1. 독립적인 기본값

```vb
# fileName=missing-settings.json이며 defaults에 delay=350이 있습니다. 파일이 없으면 Load가 defaults를 복사합니다. 결과를125로 바꿔도 기존350은 유지되어 결과는"125:350"입니다. 파일 부재를 시험하기 전에 이전 예제 파일을 옮기거나 삭제하세요.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim defaults=Dictionary()
    defaults["delay"]=350
    Dim settings=Config.Load("missing-settings.json", defaults)
    settings["delay"]=125
    Return CStr(settings["delay"]) & ":" & CStr(defaults["delay"])
End Sub
```

**매개변수 및 실행 설명:**

fileName=missing-settings.json이며 defaults에 delay=350이 있습니다. 파일이 없으면 Load가 defaults를 복사합니다. 결과를125로 바꿔도 기존350은 유지되어 결과는"125:350"입니다. 파일 부재를 시험하기 전에 이전 예제 파일을 옮기거나 삭제하세요.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 2. 저장 후 다시 읽기

```vb
# SetFlag가 JSON 불리언을 만듭니다. Save가 demo-settings.json을 생성/교체하고 Load가 읽습니다. GetFlag는 Integer1, delay=350이므로 결과는"1:350"입니다.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["delay"]=350
    Config.SetFlag(settings, "enabled", True)
    Config.Save("demo-settings.json", settings)
    Dim loaded=Config.Load("demo-settings.json", Dictionary())
    Return CStr(Config.GetFlag(loaded, "enabled")) & ":" & CStr(loaded["delay"])
End Sub
```

**매개변수 및 실행 설명:**

SetFlag가 JSON 불리언을 만듭니다. Save가 demo-settings.json을 생성/교체하고 Load가 읽습니다. GetFlag는 Integer1, delay=350이므로 결과는"1:350"입니다.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 3. 플래그 타입 확인

```vb
# enabled=1은 숫자이며 JSON true가 아닙니다. GetFlag가 거부하고 Catch는"invalid flag"를 반환합니다. SetFlag(settings,"enabled",True)는 올바른 타입을 저장합니다. 파일은 변경하지 않습니다.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["enabled"]=1
    Try
        Dim enabled=Config.GetFlag(settings, "enabled")
    Catch problem
        Return "invalid flag"
    End Try
    Return "unexpected"
End Sub
```

**매개변수 및 실행 설명:**

enabled=1은 숫자이며 JSON true가 아닙니다. GetFlag가 거부하고 Catch는"invalid flag"를 반환합니다. SetFlag(settings,"enabled",True)는 올바른 타입을 저장합니다. 파일은 변경하지 않습니다.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

<!-- implementation references (not callable script procedures):
Runtime/BasicJson.cs: Parse / Read / Stringify / Write / LoadCore / Save / Resolve / Budget
Runtime/ObjectTypes/JsonPrimitiveObjects.cs: Value
src/ClassicUO.Client/Scripts/Include/Config.bas: RequireObject / Load / Save / GetFlag / SetFlag
https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-dom
-->
