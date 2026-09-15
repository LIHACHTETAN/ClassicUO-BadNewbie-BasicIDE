# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

인덱스에 해당하는 실행 상태를 읽습니다.

## 정확한 구문

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## 매개변수

- `ScriptIndex` — 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

## 반환값

Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.

## 동작

- 실행 중 및 일시 정지된 실행을 포함하며, 끝났거나 취소가 요청된 실행은 제외합니다. 호출 스크립트는 보통 자신도 셉니다. 로드만 한 IDE 탭은 실행이 아닙니다.
- 인덱스는 시작 순서에 따른 현재 위치입니다. 시작/중지로 위치가 바뀔 수 있습니다. 별도 호출은 하나의 원자적 스냅샷이 아니므로 나중에 제어하기 전에 목록을 다시 읽으세요.
- Basic IDE를 닫아도 활성 실행은 사라지지 않습니다. 이 명령들은 다른 클라이언트나 Windows 프로세스가 아닌 이 클라이언트를 조회합니다.
- GetScriptsList는 인덱스, GetScriptsCount는 개수, GetScriptState는 세 상태 코드를 반환합니다. 서로 바꾸어 쓰거나 모든 0이 아닌 값을 true로 해석하지 마세요.
- 수동/디버거 일시 정지와 설정된 연결 끊김 일시 정지를 포함합니다. 상태 1이 순간적인 CPU 사용이나 서버 데이터 수신을 보장하지는 않습니다.

### 내부 함수: 호출부터 결과까지

아래는 클라이언트의 실제 메서드입니다. Basic 예제에는 완전한 보조 함수가 있으며 내부 C# 메서드 이름은 추가 스크립트 명령이 아닙니다.

#### 1. ExecuteStealthCompatibility

Runtime은 등록된 UO 호출을 실행하고 브리지 결과를 Integer, String 또는 Array로 감쌉니다.

Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. GetScriptState

브리지는 이 클라이언트의 실행 관리자에 위임합니다.

수동/디버거 일시 정지와 설정된 연결 끊김 일시 정지를 포함합니다. 상태 1이 순간적인 CPU 사용이나 서버 데이터 수신을 보장하지는 않습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

인덱스는 시작 순서에 따른 현재 위치입니다. 시작/중지로 위치가 바뀔 수 있습니다. 별도 호출은 하나의 원자적 스냅샷이 아니므로 나중에 제어하기 전에 목록을 다시 읽으세요.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 함수 `GetScriptState`.

Basic IDE를 닫아도 활성 실행은 사라지지 않습니다. 이 명령들은 다른 클라이언트나 Windows 프로세스가 아닌 이 클라이언트를 조회합니다.


## 예제

### 첫 호출과 결과

```vb
# 첫 호출과 결과
#
# 인덱스에 해당하는 실행 상태를 읽습니다.
#
# Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.

SUB Main()
    # Sub Main을 실행합니다. 전달한 0은 인덱스이며 빈 괄호는 인수가 없다는 뜻입니다. Print 문자열은 예제 메시지일 뿐입니다.
    # 수동/디버거 일시 정지와 설정된 연결 끊김 일시 정지를 포함합니다. 상태 1이 순간적인 CPU 사용이나 서버 데이터 수신을 보장하지는 않습니다.
    # Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.
    # 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를
    # 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**매개변수 및 실행 설명:**

- Sub Main을 실행합니다. 전달한 0은 인덱스이며 빈 괄호는 인수가 없다는 뜻입니다. Print 문자열은 예제 메시지일 뿐입니다.
- 수동/디버거 일시 정지와 설정된 연결 끊김 일시 정지를 포함합니다. 상태 1이 순간적인 CPU 사용이나 서버 데이터 수신을 보장하지는 않습니다.
- Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.
- 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

### 반복문 또는 조건에서 사용

```vb
# 반복문 또는 조건에서 사용
#
# 인덱스에 해당하는 실행 상태를 읽습니다.
#
# Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.

SUB Main()
    # 여러 명령을 조합한 독립적인 예제입니다. 배열 인덱스는 0부터 시작하므로 접근 전에 길이를 확인하세요. Wait(250)이 있으면 250밀리초 기다립니다.
    # 수동/디버거 일시 정지와 설정된 연결 끊김 일시 정지를 포함합니다. 상태 1이 순간적인 CPU 사용이나 서버 데이터 수신을 보장하지는 않습니다.
    # Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.
    # 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를
    # 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**매개변수 및 실행 설명:**

- 여러 명령을 조합한 독립적인 예제입니다. 배열 인덱스는 0부터 시작하므로 접근 전에 길이를 확인하세요. Wait(250)이 있으면 250밀리초 기다립니다.
- 수동/디버거 일시 정지와 설정된 연결 끊김 일시 정지를 포함합니다. 상태 1이 순간적인 CPU 사용이나 서버 데이터 수신을 보장하지는 않습니다.
- Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.
- 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

### 완전한 보조 함수

```vb
# 완전한 보조 함수
#
# 인덱스에 해당하는 실행 상태를 읽습니다.
#
# Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.

SUB Main()
    # Main 아래에 함수 전체가 있습니다. 이 함수의 인수와 반환값은 내부에서 쓰는 API 명령과 구분해 설명합니다.
    # IsScriptActive는 1과 2를 true로, 0을 false로 바꿉니다. GetScriptState 자체는 계속 숫자 상태 코드를 반환합니다.
    # Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.
    # 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를
    # 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**매개변수 및 실행 설명:**

- Main 아래에 함수 전체가 있습니다. 이 함수의 인수와 반환값은 내부에서 쓰는 API 명령과 구분해 설명합니다.
- IsScriptActive는 1과 2를 true로, 0을 false로 바꿉니다. GetScriptState 자체는 계속 숫자 상태 코드를 반환합니다.
- Integer 상태 코드: 0 = 없음/알 수 없음, 1 = 실행 중, 2 = 일시 정지. Boolean이 아니므로 1 또는 2와 명시적으로 비교합니다.
- 필수 ScriptIndex는 최신 GetScriptsList에서 얻는 0부터 시작하는 정수 인덱스입니다. 음수이거나 없는 인덱스는 명시된 빈 값/알 수 없음 결과를 반환합니다. 아이템 serial, 프로시저 이름 또는 IDE 실행 ID를 전달하지 마세요.
