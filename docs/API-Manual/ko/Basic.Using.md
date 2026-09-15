# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Using은 블록을 벗어날 때 네이티브 리소스를 닫습니다. 기존 변수 또는 리소스를 반환하는 식을 받는 형식을 지원합니다.

## 정확한 구문

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## 매개변수

- `resourceExpression` — 진입 시 한 번 평가합니다. File(path), MemoryStream(), CreateTimer(...)을 사용할 수 있습니다. 타이머를 해제하면 영구 정지합니다. Basic.Timers를 참조하세요. String, 숫자, List, Dictionary는 본문 실행 전에 소스 행이 포함된 오류를 냅니다. 변수를 먼저 선언하세요. 헤더 내 선언, As New, 쉼표로 나눈 리소스 목록, 사용자 Dispose는 지원하지 않습니다.
- `statements / End Using` — End Using은 캡처한 객체를 닫습니다. 변수는 남지만 리소스는 닫힌 상태입니다. 여러 리소스는 블록을 중첩하세요. 변수를 다시 할당해도 닫힐 원래 객체는 바뀌지 않습니다.

## 반환값

문 자체는 값을 반환하지 않습니다. 본문의 Return은 먼저 리소스를 해제한 뒤 프로시저에서 나갑니다. 예제의 IsClosed는 1/True 또는 0/False를 반환하는 사용자 함수입니다. Main 결과는 문자열이며 성공 플래그가 아닙니다.

## 동작

- File(path)는 래퍼를 만듭니다. 블록에서 쓰기는 Create(), 읽기는 Open()을 호출하세요. Dispose는 Close()로 버퍼를 비우고 핸들을 해제합니다. 닫힌 MemoryStream의 Length()는 오류를 냅니다. 예제는 메모리만 사용하며 파일을 만들지 않습니다.
- 컴파일러는 보호 영역을 만들고 인터프리터는 현재 호출에 객체를 저장합니다. End Using, Return, Exit, Continue, 외부 점프는 안쪽부터 바깥쪽 순서로 닫습니다. 본문 안으로 점프하면 실행 전 오류가 발생합니다.
- 일반 오류는 외부 Catch 전에 리소스를 닫습니다. 실패한 Dispose는 재시도하지 않으며 외부 리소스도 해제합니다. 비상 정지는 스크립트 Catch/Finally를 건너뛰지만 네이티브 리소스를 해제하며 닫기 오류로 취소를 대체하지 않습니다. 일시 정지는 재개나 정지까지 리소스를 유지합니다. 새 스레드를 만들지 않으며 운영체제에서 막힌 닫기 작업을 강제로 중단하지 못합니다.
- 리소스를 열린 상태로 유지하며 오류를 처리하려면 Using 안에 Try/Catch를 넣으세요. On Error Resume Next에서 처리되지 않은 본문 오류는 리소스를 닫고 전체 블록 다음으로 진행합니다. 이미 닫힌 보호 영역에 다시 들어가지 않도록 On Error GoTo는 Using 내부 레이블을 대상으로 삼을 수 없습니다.
- 오류로 Using을 벗어난 뒤 외부 On Error GoTo 처리기의 Resume은 헤더부터 전체 블록을 다시 실행하며 리소스 식을 다시 계산합니다. Resume Next는 End Using 바로 다음 줄로 진행합니다. 닫힌 객체를 가리키는 변수는 다시 열리지 않으므로 재시도에는 새 리소스를 만드는 식을 사용하세요. 이미 수행한 작업이 반복될 수 있습니다.

## 예제

### 1. 메모리 스트림 닫기

```vb
# stream은 리소스이고 size는 열린 상태에서 Length()=0을 읽습니다. 종료 후 IsClosed가 오류를 잡아 True=1을 반환하고 Main은 "0:1"을 반환합니다. ByVal은 참조를 복사합니다. 이 학습용 함수는 모든 Length 오류를 닫힘으로 보므로 이 스트림에만 사용합니다.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**매개변수 및 실행 설명:**

stream은 리소스이고 size는 열린 상태에서 Length()=0을 읽습니다. 종료 후 IsClosed가 오류를 잡아 True=1을 반환하고 Main은 "0:1"을 반환합니다. ByVal은 참조를 복사합니다. 이 학습용 함수는 모든 Length 오류를 닫힘으로 보므로 이 스트림에만 사용합니다.

### 2. 보조 함수에서 반환

```vb
# ReadLength(stream)은 Integer 0을 계산합니다. Return이 Main에 size를 넘기기 전에 스트림을 닫습니다. 다음 Length는 실패하여 closed=True, 결과는 "0:1"입니다. 호출자가 계속 열어 두어야 하는 리소스는 전달하지 마세요.
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**매개변수 및 실행 설명:**

ReadLength(stream)은 Integer 0을 계산합니다. Return이 Main에 size를 넘기기 전에 스트림을 닫습니다. 다음 Length는 실패하여 closed=True, 결과는 "0:1"입니다. 호출자가 계속 열어 두어야 하는 리소스는 전달하지 마세요.

### 3. 오류 후 중첩 해제

```vb
# outer와 inner는 별개 스트림입니다. Throw "demo"는 inner부터 outer 순서로 닫습니다. Catch는 원래 메시지를 보존하고 IsClosed는 각각 1을 반환합니다. Main 결과 "demo:2"에서 2는 닫힌 객체 수이며 Boolean이 아닙니다.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**매개변수 및 실행 설명:**

outer와 inner는 별개 스트림입니다. Throw "demo"는 inner부터 outer 순서로 닫습니다. Catch는 원래 메시지를 보존하고 IsClosed는 각각 1을 반환합니다. Main 결과 "demo:2"에서 2는 닫힌 객체 수이며 Boolean이 아닙니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
