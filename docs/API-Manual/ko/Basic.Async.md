# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Async Function은 스크립트 작업을 만듭니다. Await는 해당 함수를 중단하여 같은 스크립트의 다른 준비된 작업이 진행되도록 합니다. 새 스레드나 전체 VB.NET Task 라이브러리를 제공하는 기능은 아닙니다.

## 정확한 구문

```text
Async Function Work(ByVal value As Integer) As Task(Of Integer)
    Await Delay(100)
    Return value
End Function
Async Function Work() As Task
    Await Delay(100)
End Function
Delay(milliseconds) -> Object (ScriptTask)
Await task
Dim value = Await task
value = Await task
Return Await task
task.IsCompleted() -> Integer (0/1)
task.IsFaulted() -> Integer (0/1)
task.IsCanceled() -> Integer (0/1)
task.Result() -> T / Unit
```

## 매개변수

- `milliseconds` — Delay는 0..2147483647 밀리초의 Integer를 받습니다. 0은 즉시 완료하며 음수, 소수와 String은 잡을 수 있는 오류를 냅니다. 단조 시계로 최소 대기 시간을 정하며 정확한 실행 시각을 보장하지 않습니다.
- `Async Function / ByVal / Task(Of T)` — As Task는 값이 없고 As Task(Of T)는 Basic 스칼라 또는 Object/Variant 결과입니다. 매개변수는 명시적 ByVal 또는 ParamArray가 필요하며 Optional과 명명된 인수를 지원합니다. ByRef, Async Sub/Declare는 거부합니다. 작업은 프로시저 본문에서 만들고 전역 필드나 매개변수 기본값 초기화에서는 만들지 마세요.
- `task / Await` — 작업 변수는 형식을 생략하거나 As Object로 선언합니다. Await는 현재 실행의 작업을 독립 문장, 단일 스칼라 선언/대입의 전체 오른쪽, Return Await로 받습니다. 산술, 조건, 필드/인덱스 대입, Catch/Finally 및 Async Function 밖에서는 사용할 수 없습니다. 여러 함수가 같은 작업을 기다릴 수 있지만 순환 의존성은 오류입니다.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted는 성공·실패·취소 후 1, IsFaulted는 실패 시 1, IsCanceled는 취소 시 1입니다. 이 Integer 조건은 True/False와 비교할 수 있습니다. Result()는 저장된 값을 반환하고 미완료면 오류, 실패했으면 원래 오류를 다시 던집니다. 이전 실행의 작업은 재사용할 수 없습니다.

## 반환값

스크립트에서 Async Function과 Delay를 호출하면 즉시 T가 아닌 Object (ScriptTask)를 받습니다. Await와 Result()는 T를 반환하며 As Task와 Delay는 값 없는 Unit으로 끝납니다. 클라이언트가 Async Function을 진입점으로 실행하면 협력적으로 기다려 최종 결과를 받습니다. 숫자 데이터가 항상 Boolean인 것은 아닙니다.

## 동작

- 함수는 첫 번째 미완료 Await까지 즉시 실행합니다. 지역 변수, 반복 위치, With 객체와 디버거 프레임을 저장했다가 재개할 때 복원합니다. 이미 완료된 작업은 중단하지 않으며 Await 피연산자는 한 번만 계산합니다.
- 스크립트 소유 스레드는 안전한 확인 지점에서 기한을 검사하고 한 회에 최대 64개의 준비된 계속 작업을 실행합니다. 새 스레드는 없습니다. 동기 Wait나 오래 걸리는 게임/네이티브 호출은 다른 작업을 지연시킬 수 있으므로 Await Delay를 사용하세요. 미완료 작업 또는 아직 읽지 않은 실패 작업은 최대 1024개입니다.
- 일시 정지는 계속 실행을 막지만 시간은 흐릅니다. 재개하면 기한이 지난 작업을 처리합니다. Stop, 오류 또는 진입점 반환은 남은 작업을 취소하고 Using 자원과 반복자를 해제합니다. 비상 취소는 스크립트 Catch/Finally를 건너뜁니다. 읽지 않은 작업 오류는 진입점 종료 시 보고됩니다. IDE만 닫아서는 실행 중인 스크립트가 멈추지 않습니다.
- Task.Run/WhenAll, 외부 .NET 작업, Async Sub, Catch/Finally 내 Await, 지역 As Task 선언은 지원하지 않습니다. 필요한 작업보다 Main이 먼저 끝나지 않게 하세요. Async/Await는 예약어입니다.

## 예제

### 1. 독립적인 두 대기

```vb
# ValueLater는 value와 milliseconds를 값으로 받습니다. 결과를 읽기 전에 두 호출을 시작하여 10ms 후 22, 30ms 후 20을 얻습니다. Main은 최대 5000ms 기다린 후 Result()의 Integer를 더해 42를 반환합니다. Wait Until 시간 초과는 오류입니다.
Option Explicit On
Async Function ValueLater(ByVal value As Integer, ByVal milliseconds As Integer) As Task(Of Integer)
    Await Delay(milliseconds)
    Return value
End Function

Sub Main()
    Dim first = ValueLater(20, 30)
    Dim second = ValueLater(22, 10)
    Wait Until first.IsCompleted() AndAlso second.IsCompleted() Timeout 5000
    Return first.Result() + second.Result()
End Sub
```

**매개변수 및 실행 설명:**

ValueLater는 value와 milliseconds를 값으로 받습니다. 결과를 읽기 전에 두 호출을 시작하여 10ms 후 22, 30ms 후 20을 얻습니다. Main은 최대 5000ms 기다린 후 Result()의 Integer를 더해 42를 반환합니다. Wait Until 시간 초과는 오류입니다.

### 2. 대기 중 오류 잡기

```vb
# FailLater는 값이 없고 5ms 후 오류를 던집니다. ReadFailure가 Await에서 이를 받아 텍스트를 저장하고 Finally에서 공유 정리 플래그를 설정합니다. Main은 최대 5000ms 기다려 String "failed:1"을 반환합니다. 1은 True이며 Catch/Finally에는 Await가 없습니다.
Option Explicit On
Module State
    Public Dim cleaned As Boolean = False
End Module

Async Function FailLater() As Task
    Await Delay(5)
    Throw "failed"
End Function

Async Function ReadFailure() As Task(Of String)
    Dim message As String = ""
    Try
        Await FailLater()
    Catch problem
        message = problem
    Finally
        State.cleaned = True
    End Try
    Return message & ":" & CStr(State.cleaned)
End Function

Sub Main()
    Dim task = ReadFailure()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**매개변수 및 실행 설명:**

FailLater는 값이 없고 5ms 후 오류를 던집니다. ReadFailure가 Await에서 이를 받아 텍스트를 저장하고 Finally에서 공유 정리 플래그를 설정합니다. Main은 최대 5000ms 기다려 String "failed:1"을 반환합니다. 1은 True이며 Catch/Finally에는 Await가 없습니다.

### 3. 반복과 결과 전달

```vb
# IncrementLater(value)는 5ms 기다려 value+1을 반환합니다. SumLater는 total과 i를 유지하며 i=1..3 호출을 순서대로 기다립니다. ForwardResult가 Return Await로 9를 전달합니다. Main의 Integer 9는 합계이며 논리값이 아닙니다.
Option Explicit On
Async Function IncrementLater(ByVal value As Integer) As Task(Of Integer)
    Await Delay(5)
    Return value + 1
End Function

Async Function SumLater() As Task(Of Integer)
    Dim total As Integer = 0
    For Var i = 1 To 3
        Dim nextValue = Await IncrementLater(i)
        total += nextValue
    Next
    Return total
End Function

Async Function ForwardResult() As Task(Of Integer)
    Return Await SumLater()
End Function

Sub Main()
    Dim task = ForwardResult()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**매개변수 및 실행 설명:**

IncrementLater(value)는 5ms 기다려 value+1을 반환합니다. SumLater는 total과 i를 유지하며 i=1..3 호출을 순서대로 기다립니다. ForwardResult가 Return Await로 9를 전달합니다. Main의 Integer 9는 합계이며 논리값이 아닙니다.


### 내부 함수: 호출부터 결과까지

함수는 첫 번째 미완료 Await까지 즉시 실행합니다. 지역 변수, 반복 위치, With 객체와 디버거 프레임을 저장했다가 재개할 때 복원합니다. 이미 완료된 작업은 중단하지 않으며 Await 피연산자는 한 번만 계산합니다.

#### 1. Delay

Delay는 0..2147483647 밀리초의 Integer를 받습니다. 0은 즉시 완료하며 음수, 소수와 String은 잡을 수 있는 오류를 냅니다. 단조 시계로 최소 대기 시간을 정하며 정확한 실행 시각을 보장하지 않습니다.

due = monotonicNow + milliseconds
return task

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 함수 `Delay`.

#### 2. ResolveAwaitTask

작업 변수는 형식을 생략하거나 As Object로 선언합니다. Await는 현재 실행의 작업을 독립 문장, 단일 스칼라 선언/대입의 전체 오른쪽, Return Await로 받습니다. 산술, 조건, 필드/인덱스 대입, Catch/Finally 및 Async Function 밖에서는 사용할 수 없습니다. 여러 함수가 같은 작업을 기다릴 수 있지만 순환 의존성은 오류입니다.

validate owner and dependency chain
evaluate operand once

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; 함수 `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

함수는 첫 번째 미완료 Await까지 즉시 실행합니다. 지역 변수, 반복 위치, With 객체와 디버거 프레임을 저장했다가 재개할 때 복원합니다. 이미 완료된 작업은 중단하지 않으며 Await 피연산자는 한 번만 계산합니다.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 함수 `ExecuteSubrutine`.

#### 4. Pump

스크립트 소유 스레드는 안전한 확인 지점에서 기한을 검사하고 한 회에 최대 64개의 준비된 계속 작업을 실행합니다. 새 스레드는 없습니다. 동기 Wait나 오래 걸리는 게임/네이티브 호출은 다른 작업을 지연시킬 수 있으므로 Await Delay를 사용하세요. 미완료 작업 또는 아직 읽지 않은 실패 작업은 최대 1024개입니다.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 함수 `Pump`.

#### 5. GetResult

IsCompleted는 성공·실패·취소 후 1, IsFaulted는 실패 시 1, IsCanceled는 취소 시 1입니다. 이 Integer 조건은 True/False와 비교할 수 있습니다. Result()는 저장된 값을 반환하고 미완료면 오류, 실패했으면 원래 오류를 다시 던집니다. 이전 실행의 작업은 재사용할 수 없습니다.

if pending: error
if failed: rethrow
return saved value

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; 함수 `GetResult`.

#### 6. Release

일시 정지는 계속 실행을 막지만 시간은 흐릅니다. 재개하면 기한이 지난 작업을 처리합니다. Stop, 오류 또는 진입점 반환은 남은 작업을 취소하고 Using 자원과 반복자를 해제합니다. 비상 취소는 스크립트 Catch/Finally를 건너뜁니다. 읽지 않은 작업 오류는 진입점 종료 시 보고됩니다. IDE만 닫아서는 실행 중인 스크립트가 멈추지 않습니다.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 함수 `Release`.

스크립트에서 Async Function과 Delay를 호출하면 즉시 T가 아닌 Object (ScriptTask)를 받습니다. Await와 Result()는 T를 반환하며 As Task와 Delay는 값 없는 Unit으로 끝납니다. 클라이언트가 Async Function을 진입점으로 실행하면 협력적으로 기다려 최종 결과를 받습니다. 숫자 데이터가 항상 Boolean인 것은 아닙니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: ASYNC / awaitExpression / taskType
Analysis/AsyncValidator.cs: supported statement forms and signatures
Runtime/Interpreter.cs: ExecuteSubrutine / statement suspension / cleanup
Runtime/Interpreter.Async.cs: ResolveAwaitTask / ResumeAsync / WaitForTask
Runtime/ScriptAsyncScheduler.cs: Delay / Track / Pump / Release
Runtime/ObjectTypes/ScriptTaskObject.cs: GetResult / Complete / Awaiter
Runtime/SemanticScope.cs: SuspendCurrent / Resume
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/async
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/await-operator
-->
