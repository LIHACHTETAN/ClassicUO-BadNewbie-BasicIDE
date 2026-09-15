# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Event는 스크립트 이벤트를 선언합니다. AddHandler는 Sub를 등록하고 RemoveHandler는 해제하며, RaiseEvent는 등록 순서대로 처리기를 동기 실행합니다.

## 정확한 구문

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## 매개변수

- `EventName / Public / Private` — 파일 수준(암시적 스크립트 모듈)이나 Module 내부의 프로시저 바깥에 단순 이름을 선언합니다. 기본 접근은 Public이며 Private은 Module이 필요합니다. 외부 등록에는 Module.EventName을 사용합니다. Public 이벤트도 선언한 모듈만 RaiseEvent로 발생시킬 수 있습니다. 프로시저나 변수와 같은 이름은 사용할 수 없습니다.
- `Handler / callback` — Handler는 유일하게 선언된 Sub로, AddressOf 또는 현재 로드한 스크립트의 콜백 변수/팩터리로 전달합니다. Function, 이름 문자열, 다른 스크립트 참조, 오버로드 그룹은 허용되지 않습니다. 매개변수 개수·형식·ByVal/ByRef가 정확히 일치해야 합니다. 일반 프로시저는 기존 기본값 ByRef를 유지하므로 처리기에는 ByVal을 명시하세요.
- `arguments / ByVal / ByRef` — RaiseEvent에는 모든 위치 인수가 필요합니다. Optional, ParamArray, 기본값, 이름 있는 이벤트 인수, Safe Call은 지원하지 않습니다. Event 매개변수 기본값은 ByVal이며 스칼라나 참조를 복사하고 객체 내용은 복사하지 않습니다. ByRef 변경은 다음 처리기에 전달되고 호출자의 쓰기 가능한 변수나 인덱스 요소에 복사됩니다. 인수와 인덱스는 작성 순서대로 한 번씩 평가합니다.

## 반환값

Event, AddHandler, RemoveHandler, RaiseEvent는 값을 반환하지 않습니다(Unit). Boolean, ID, 구독자 수도 아닙니다. 결과는 ByRef 또는 Module 공유 상태로 전달하세요. 각 예제의 Main은 String "ready", Integer 8, String "ABAC:handler failed"를 반환합니다.

## 동작

- 구독은 인터프리터마다 별개입니다. 다른 스크립트나 다시 로드한 스크립트는 구독 없이 시작합니다. 같은 로드된 인터프리터로 다시 진입하면 해제하거나 인터프리터를 폐기할 때까지 유지됩니다. IDE를 닫아도 실행 중인 스크립트와 구독은 남지만 독립적인 백그라운드 이벤트 서비스가 생기지는 않습니다.
- AddHandler는 끝에 추가하며 중복 등록은 같은 Sub를 반복 호출합니다. RemoveHandler는 마지막으로 일치하는 등록을 지우고, 없으면 아무 일도 하지 않습니다. 선언·접근·시그니처를 검사하고 인수를 평가한 뒤 순서 있는 목록을 고정합니다. 처리기 안의 구독 변경은 다음 RaiseEvent부터 적용됩니다.
- 처리기 오류는 남은 호출을 중단하고 호출자의 Catch/Finally로 전달됩니다. 이미 발생한 ByRef 변경은 복사됩니다. 일시 정지와 긴급 중지는 처리기 안에서도 작동하며 Catch는 긴급 중지를 삼키지 않습니다. 새 스레드를 만들지 않습니다. 차단되는 네이티브 호출은 자체 취소 제한을 유지합니다.
- 제한은 이벤트당 4096개 구독, 16단계 RaiseEvent 중첩, 32개 스크립트 프로시저 프레임입니다. 순환이나 깊은 재귀는 클라이언트 스택을 넘치게 하지 않고 잡을 수 있는 스크립트 오류를 냅니다. 깊은 처리는 반복문을 사용하세요. 공유 스칼라는 Module 필드에 저장합니다. 기존 파일 수준 스칼라는 복사본으로 상속됩니다.
- 스크립트가 선언하고 명시적으로 발생시키는 이벤트이며 게임 패킷이나 저널 변경을 자동 구독하지 않습니다. Handles, WithEvents, Custom Event, 이벤트 대리자 형식, 클래스 이벤트는 여기서 구현되지 않았습니다. Basic 키워드는 UO. 없이, 게임 API는 UO.를 붙여 씁니다.

## 예제

### 1. 등록 및 해제

```vb
# Feed.Message는 text As String을 ByVal로 전달합니다. 전체가 표시된 Feed.Publish가 이벤트를 발생시키고 Record는 공유 State.log에 추가합니다. handler가 Record를 등록하여 "ready"를 저장합니다. 다른 줄의 AddressOf Record도 같은 Sub로 인식해 해제합니다. 해제 후 "ignored"는 추가되지 않으며 Main은 "ready"를 반환합니다.
Option Explicit On
Module Feed
    Public Event Message(ByVal text As String)
    Public Sub Publish(ByVal text As String)
        RaiseEvent Message(text)
    End Sub
End Module

Module State
    Public Dim log As String = ""
End Module

Sub Record(ByVal text As String)
    State.log = State.log & text
End Sub

Sub Main()
    Dim handler = AddressOf Record
    AddHandler Feed.Message, handler
    Feed.Publish("ready")
    RemoveHandler Feed.Message, AddressOf Record
    Feed.Publish("ignored")
    Return State.log
End Sub
```

**매개변수 및 실행 설명:**

Feed.Message는 text As String을 ByVal로 전달합니다. 전체가 표시된 Feed.Publish가 이벤트를 발생시키고 Record는 공유 State.log에 추가합니다. handler가 Record를 등록하여 "ready"를 저장합니다. 다른 줄의 AddressOf Record도 같은 Sub로 인식해 해제합니다. 해제 후 "ignored"는 추가되지 않으며 Main은 "ready"를 반환합니다.

### 2. 값을 연속으로 변경

```vb
# Adjust와 두 Sub는 total As Integer ByRef를 선언합니다. Increment가 3을 4로 바꾸고 DoubleValue는 4를 받아 8로 만듭니다. RaiseEvent가 Main에 8을 복사한 후 두 구독을 해제합니다. Integer 8은 수량이지 True/False가 아니며 RaiseEvent 자체는 값을 반환하지 않습니다.
Option Explicit On
Event Adjust(ByRef total As Integer)

Sub Increment(ByRef total As Integer)
    total += 1
End Sub

Sub DoubleValue(ByRef total As Integer)
    total *= 2
End Sub

Sub Main()
    Dim total As Integer = 3
    AddHandler Adjust, AddressOf Increment
    AddHandler Adjust, AddressOf DoubleValue
    RaiseEvent Adjust(total)
    RemoveHandler Adjust, AddressOf Increment
    RemoveHandler Adjust, AddressOf DoubleValue
    Return total
End Sub
```

**매개변수 및 실행 설명:**

Adjust와 두 Sub는 total As Integer ByRef를 선언합니다. Increment가 3을 4로 바꾸고 DoubleValue는 4를 받아 8로 만듭니다. RaiseEvent가 Main에 8을 복사한 후 두 구독을 해제합니다. Integer 8은 수량이지 True/False가 아니며 RaiseEvent 자체는 값을 반환하지 않습니다.

### 3. 오류를 처리하고 계속

```vb
# Ready에는 매개변수가 없습니다. First가 A를, Failing이 B를 추가하고 오류를 던져 이번에는 Last를 건너뜁니다. Catch가 메시지를 저장하고 Finally가 Failing을 해제합니다. 다음 호출은 AC를 추가하며 Main은 "ABAC:handler failed"를 반환합니다. 모든 처리기와 State가 포함되어 있습니다.
Option Explicit On
Event Ready()
Module State
    Public Dim log As String = ""
End Module

Sub First()
    State.log = State.log & "A"
End Sub

Sub Failing()
    State.log = State.log & "B"
    Throw "handler failed"
End Sub

Sub Last()
    State.log = State.log & "C"
End Sub

Sub Main()
    Dim message As String = ""
    AddHandler Ready, AddressOf First
    AddHandler Ready, AddressOf Failing
    AddHandler Ready, AddressOf Last
    Try
        RaiseEvent Ready()
    Catch problem
        message = problem
    Finally
        RemoveHandler Ready, AddressOf Failing
    End Try
    RaiseEvent Ready()
    Return State.log & ":" & message
End Sub
```

**매개변수 및 실행 설명:**

Ready에는 매개변수가 없습니다. First가 A를, Failing이 B를 추가하고 오류를 던져 이번에는 Last를 건너뜁니다. Catch가 메시지를 저장하고 Finally가 Failing을 해제합니다. 다음 호출은 AC를 추가하며 Main은 "ABAC:handler failed"를 반환합니다. 모든 처리기와 State가 포함되어 있습니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
