# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

Basic 파일을 읽고 공개 Sub Main의 시작을 요청합니다.

## 정확한 구문

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## 매개변수

- `ScriptPath` — 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.

## 반환값

Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.

## 동작

- 실행 중 및 일시 정지된 실행을 포함하며, 끝났거나 취소가 요청된 실행은 제외합니다. 호출 스크립트는 보통 자신도 셉니다. 로드만 한 IDE 탭은 실행이 아닙니다.
- 인덱스는 시작 순서에 따른 현재 위치입니다. 시작/중지로 위치가 바뀔 수 있습니다. 별도 호출은 하나의 원자적 스냅샷이 아니므로 나중에 제어하기 전에 목록을 다시 읽으세요.
- Basic IDE를 닫아도 활성 실행은 사라지지 않습니다. 이 명령들은 다른 클라이언트나 Windows 프로세스가 아닌 이 클라이언트를 조회합니다.
- GetScriptsList는 인덱스, GetScriptsCount는 개수, GetScriptState는 세 상태 코드를 반환합니다. 서로 바꾸어 쓰거나 모든 0이 아닌 값을 true로 해석하지 마세요.
- 예제 전에 지정된 Worker.bas 파일들을 따로 만드세요. 잘못된/읽을 수 없는 경로, 부적합한 Main, 비활성 Basic 또는 병렬 시작 거부는 실패합니다. 이전 실행이 아직 중지 중이면 재시도가 지연될 수 있습니다. 수락은 완료가 아니며 짧은 스크립트는 개수를 읽기 전에 끝날 수 있습니다.

### 내부 함수: 호출부터 결과까지

아래는 클라이언트의 실제 메서드입니다. Basic 예제에는 완전한 보조 함수가 있으며 내부 C# 메서드 이름은 추가 스크립트 명령이 아닙니다.

#### 1. ExecuteStealthCompatibility

Runtime은 등록된 UO 호출을 실행하고 브리지 결과를 Integer, String 또는 Array로 감쌉니다.

Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. StartScript

브리지는 이 클라이언트의 실행 관리자에 위임합니다.

예제 전에 지정된 Worker.bas 파일들을 따로 만드세요. 잘못된/읽을 수 없는 경로, 부적합한 Main, 비활성 Basic 또는 병렬 시작 거부는 실패합니다. 이전 실행이 아직 중지 중이면 재시도가 지연될 수 있습니다. 수락은 완료가 아니며 짧은 스크립트는 개수를 읽기 전에 끝날 수 있습니다.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 함수 `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

인덱스는 시작 순서에 따른 현재 위치입니다. 시작/중지로 위치가 바뀔 수 있습니다. 별도 호출은 하나의 원자적 스냅샷이 아니므로 나중에 제어하기 전에 목록을 다시 읽으세요.

프로젝트 소스: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 함수 `StartScript`.

Basic IDE를 닫아도 활성 실행은 사라지지 않습니다. 이 명령들은 다른 클라이언트나 Windows 프로세스가 아닌 이 클라이언트를 조회합니다.


## 예제

### 첫 호출과 결과

```vb
# 첫 호출과 결과
#
# Basic 파일을 읽고 공개 Sub Main의 시작을 요청합니다.
#
# Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.

SUB Main()
    # Sub Main을 실행합니다. 전달한 0은 인덱스이며 빈 괄호는 인수가 없다는 뜻입니다. Print 문자열은 예제 메시지일 뿐입니다.
    # 예제 전에 지정된 Worker.bas 파일들을 따로 만드세요. 잘못된/읽을 수 없는 경로, 부적합한 Main, 비활성 Basic 또는 병렬 시작 거부는 실패합니다. 이전
    # 실행이 아직 중지 중이면 재시도가 지연될 수 있습니다. 수락은 완료가 아니며 짧은 스크립트는 개수를 읽기 전에 끝날 수 있습니다.
    # Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.
    # 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로
    # 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**매개변수 및 실행 설명:**

- Sub Main을 실행합니다. 전달한 0은 인덱스이며 빈 괄호는 인수가 없다는 뜻입니다. Print 문자열은 예제 메시지일 뿐입니다.
- 예제 전에 지정된 Worker.bas 파일들을 따로 만드세요. 잘못된/읽을 수 없는 경로, 부적합한 Main, 비활성 Basic 또는 병렬 시작 거부는 실패합니다. 이전 실행이 아직 중지 중이면 재시도가 지연될 수 있습니다. 수락은 완료가 아니며 짧은 스크립트는 개수를 읽기 전에 끝날 수 있습니다.
- Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.
- 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.

### 반복문 또는 조건에서 사용

```vb
# 반복문 또는 조건에서 사용
#
# Basic 파일을 읽고 공개 Sub Main의 시작을 요청합니다.
#
# Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.

SUB Main()
    # 여러 명령을 조합한 독립적인 예제입니다. 배열 인덱스는 0부터 시작하므로 접근 전에 길이를 확인하세요. Wait(250)이 있으면 250밀리초 기다립니다.
    # 예제 전에 지정된 Worker.bas 파일들을 따로 만드세요. 잘못된/읽을 수 없는 경로, 부적합한 Main, 비활성 Basic 또는 병렬 시작 거부는 실패합니다. 이전
    # 실행이 아직 중지 중이면 재시도가 지연될 수 있습니다. 수락은 완료가 아니며 짧은 스크립트는 개수를 읽기 전에 끝날 수 있습니다.
    # Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.
    # 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로
    # 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**매개변수 및 실행 설명:**

- 여러 명령을 조합한 독립적인 예제입니다. 배열 인덱스는 0부터 시작하므로 접근 전에 길이를 확인하세요. Wait(250)이 있으면 250밀리초 기다립니다.
- 예제 전에 지정된 Worker.bas 파일들을 따로 만드세요. 잘못된/읽을 수 없는 경로, 부적합한 Main, 비활성 Basic 또는 병렬 시작 거부는 실패합니다. 이전 실행이 아직 중지 중이면 재시도가 지연될 수 있습니다. 수락은 완료가 아니며 짧은 스크립트는 개수를 읽기 전에 끝날 수 있습니다.
- Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.
- 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.

### 완전한 보조 함수

```vb
# 완전한 보조 함수
#
# Basic 파일을 읽고 공개 Sub Main의 시작을 요청합니다.
#
# Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.

SUB Main()
    # Main 아래에 함수 전체가 있습니다. 이 함수의 인수와 반환값은 내부에서 쓰는 API 명령과 구분해 설명합니다.
    # TryStartBasic은 65535와 비교해 true/false를 반환합니다. 완료를 기다리거나 개수를 인덱스로 바꾸지 않습니다.
    # Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.
    # 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로
    # 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**매개변수 및 실행 설명:**

- Main 아래에 함수 전체가 있습니다. 이 함수의 인수와 반환값은 내부에서 쓰는 API 명령과 구분해 설명합니다.
- TryStartBasic은 65535와 비교해 true/false를 반환합니다. 완료를 기다리거나 개수를 인덱스로 바꾸지 않습니다.
- Integer: 시작 요청을 수락한 뒤의 활성 실행 수입니다. 65535 (0xFFFF)는 시작 실패입니다. 새 인덱스, Boolean 또는 완료 결과가 아닙니다.
- 필수 String ScriptPath입니다. 상대 경로는 이 클라이언트의 AutoLoad 폴더에서 시작하며 절대 경로도 허용합니다. 공백이 있는 경로는 따옴표로 감쌉니다. 파일에는 지원하는 Basic과 필수 인수가 없는 공개 Sub Main이 있어야 합니다.
