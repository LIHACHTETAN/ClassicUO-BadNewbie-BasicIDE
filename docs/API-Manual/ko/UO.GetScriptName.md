# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

활성 실행의 표시 이름을 읽습니다.

## 정확한 구문

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## 매개변수

- `ScriptIndex` — 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

## 반환값

String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.

## 동작

- 실행 중 및 일시 정지된 실행을 포함하며, 끝났거나 취소가 요청된 실행은 제외합니다. 호출 스크립트는 보통 자신도 셉니다. 로드만 한 IDE 탭은 실행이 아닙니다.
- 인덱스는 시작 순서에 따른 현재 위치입니다. 시작/중지로 위치가 바뀔 수 있습니다. 별도 호출은 하나의 원자적 스냅샷이 아니므로 나중에 제어하기 전에 목록을 다시 읽으세요.
- Basic IDE를 닫아도 활성 실행은 사라지지 않습니다. 이 명령들은 다른 클라이언트나 Windows 프로세스가 아닌 이 클라이언트를 조회합니다.
- GetScriptsList는 인덱스, GetScriptsCount는 개수, GetScriptState는 세 상태 코드를 반환합니다. 서로 바꾸어 쓰거나 모든 0이 아닌 값을 true로 해석하지 마세요.
- ScriptIndex=0은 현재 첫 실행이며 반드시 호출자라는 뜻은 아닙니다. SetScriptName은 표시 이름만 바꾸고 파일 이름은 바꾸지 않습니다.

### 내부 함수: 호출부터 결과까지

아래는 클라이언트의 실제 메서드입니다. Basic 예제에는 완전한 보조 함수가 있으며 내부 C# 메서드 이름은 추가 스크립트 명령이 아닙니다.

#### 1. ExecuteStealthCompatibility

Runtime은 등록된 UO 호출을 실행하고 브리지 결과를 Integer, String 또는 Array로 감쌉니다.

String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. GetScriptName

브리지는 이 클라이언트의 실행 관리자에 위임합니다.

ScriptIndex=0은 현재 첫 실행이며 반드시 호출자라는 뜻은 아닙니다. SetScriptName은 표시 이름만 바꾸고 파일 이름은 바꾸지 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

인덱스는 시작 순서에 따른 현재 위치입니다. 시작/중지로 위치가 바뀔 수 있습니다. 별도 호출은 하나의 원자적 스냅샷이 아니므로 나중에 제어하기 전에 목록을 다시 읽으세요.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 함수 `GetScriptName`.

Basic IDE를 닫아도 활성 실행은 사라지지 않습니다. 이 명령들은 다른 클라이언트나 Windows 프로세스가 아닌 이 클라이언트를 조회합니다.


## 예제

### 첫 호출과 결과

```vb
# 첫 호출과 결과
#
# 활성 실행의 표시 이름을 읽습니다.
#
# String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.

SUB Main()
    # Sub Main을 실행합니다. 전달한 0은 인덱스이며 빈 괄호는 인수가 없다는 뜻입니다. Print 문자열은 예제 메시지일 뿐입니다.
    # ScriptIndex=0은 현재 첫 실행이며 반드시 호출자라는 뜻은 아닙니다. SetScriptName은 표시 이름만 바꾸고 파일 이름은 바꾸지 않습니다.
    # String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.
    # 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를
    # 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**매개변수 및 실행 설명:**

- Sub Main을 실행합니다. 전달한 0은 인덱스이며 빈 괄호는 인수가 없다는 뜻입니다. Print 문자열은 예제 메시지일 뿐입니다.
- ScriptIndex=0은 현재 첫 실행이며 반드시 호출자라는 뜻은 아닙니다. SetScriptName은 표시 이름만 바꾸고 파일 이름은 바꾸지 않습니다.
- String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.
- 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

### 반복문 또는 조건에서 사용

```vb
# 반복문 또는 조건에서 사용
#
# 활성 실행의 표시 이름을 읽습니다.
#
# String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.

SUB Main()
    # 여러 명령을 조합한 독립적인 예제입니다. 배열 인덱스는 0부터 시작하므로 접근 전에 길이를 확인하세요. Wait(250)이 있으면 250밀리초 기다립니다.
    # ScriptIndex=0은 현재 첫 실행이며 반드시 호출자라는 뜻은 아닙니다. SetScriptName은 표시 이름만 바꾸고 파일 이름은 바꾸지 않습니다.
    # String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.
    # 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를
    # 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**매개변수 및 실행 설명:**

- 여러 명령을 조합한 독립적인 예제입니다. 배열 인덱스는 0부터 시작하므로 접근 전에 길이를 확인하세요. Wait(250)이 있으면 250밀리초 기다립니다.
- ScriptIndex=0은 현재 첫 실행이며 반드시 호출자라는 뜻은 아닙니다. SetScriptName은 표시 이름만 바꾸고 파일 이름은 바꾸지 않습니다.
- String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.
- 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

### 완전한 보조 함수

```vb
# 완전한 보조 함수
#
# 활성 실행의 표시 이름을 읽습니다.
#
# String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.

SUB Main()
    # Main 아래에 함수 전체가 있습니다. 이 함수의 인수와 반환값은 내부에서 쓰는 API 명령과 구분해 설명합니다.
    # DescribeScript는 상태를 확인하고 이름과 경로를 합칩니다. 호출 사이에 중지될 수 있으며 "missing"은 보조 함수의 값이지 GetScriptName의
    # 반환값이 아닙니다.
    # String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.
    # 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를
    # 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**매개변수 및 실행 설명:**

- Main 아래에 함수 전체가 있습니다. 이 함수의 인수와 반환값은 내부에서 쓰는 API 명령과 구분해 설명합니다.
- DescribeScript는 상태를 확인하고 이름과 경로를 합칩니다. 호출 사이에 중지될 수 있으며 "missing"은 보조 함수의 값이지 GetScriptName의 반환값이 아닙니다.
- String: 표시 이름이며, 인덱스가 없으면 ""입니다. 존재하는 실행도 이름을 명시적으로 빈 문자열로 설정할 수 있습니다.
- 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.
