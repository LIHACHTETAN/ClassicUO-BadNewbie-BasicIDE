# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Class는 객체별 상태와 스크립트 메서드를 묶습니다. New는 참조 객체를 생성합니다. 다른 변수에 대입해도 같은 객체를 가리키며, Structure의 값 복사와 다릅니다. 예제에 사용하는 생성자, 메서드, 속성 접근자를 모두 제시합니다.

## 정확한 구문

```text
[Public | Private] Class TypeName
    [Public | Private | Dim] field As FieldType
    Public Sub New([parameters]) ... End Sub
    [Public | Private] Sub Method([parameters]) ... End Sub
    [Public | Private] Function Method([parameters]) As ResultType ... End Function
    [Public | Private] [ReadOnly | WriteOnly] Property Name[()] As ValueType
        Get ... Return value / Name = value / Exit Property ... End Get
        Set(ByVal value As ValueType) ... End Set
    End Property
    Public Property AutoName As ValueType
End Class
Dim instance [As TypeName] = New TypeName(arguments)
instance.Property = expression
value = instance.Property
instance.Method(arguments)
With instance ... End With
```

## 매개변수

- `TypeName / Public / Private` — TypeName은 파일 또는 Module 수준의 고유한 단순 이름입니다. 모듈 밖에서는 ModuleName.TypeName을 사용합니다. Class 기본값은 Public이며 Private Class는 자신의 Module에만 보입니다. 상속, 인터페이스, 제네릭, 중첩 클래스, Shared, 오버로드, 소멸자, 인스턴스 Event 선언은 구현되지 않았습니다.
- `field As FieldType / Me` — 필드는 As Integer, Double, Boolean, String, Object 또는 선언된 Enum/Structure/Class 형식이 필요합니다. 기존 Basic 형식 별칭도 유효합니다. 필드는 기본 Private이므로 외부 접근에는 Public을 명시합니다. 초기값은 숫자/Boolean 0, String 빈 문자열, Structure 영값 필드, Object/Class Nothing(Unit)입니다. 다른 초기화는 Sub New에서 합니다. Me는 현재 인스턴스이며 재선언·재대입할 수 없습니다. 매개변수와 지역 변수는 다른 멤버 이름을 가릴 수 있습니다.
- `New / Sub New` — New TypeName(arguments)는 별도 필드를 만들고 Public Sub New를 한 번 실행합니다. 생성자가 없으면 New TypeName()만 허용합니다. 생성자는 하나이며 일반 Optional, 기본값, 명명된 인수 규칙을 따릅니다. 인수는 작성 순서대로 한 번 평가되며 실패하면 완성된 객체를 반환하지 않습니다. As TypeName만 선언한 변수는 Nothing입니다.
- `Sub / Function / arguments` — Sub/Function은 instance.Method(...), 클래스 내부에서는 Method(...)/Me.Method(...)로 호출합니다. Private은 같은 Class 코드에서만 호출하며 같은 형식의 다른 인스턴스에도 적용됩니다. 형식, ByVal/ByRef, Optional, ParamArray, 명명된 인수를 지원하되 ParamArray 요소의 이름 지정은 불가합니다. Function은 선언 형식, Sub는 Unit을 반환합니다. TypeName.Method(...)와 instance.New(...)는 잘못된 호출입니다. 인스턴스 메서드의 AddressOf에는 파일/모듈 래퍼 프로시저가 필요합니다.
- `Property / Get / Set` — Property Name[()] As ValueType에는 인덱스 매개변수가 없습니다. 읽기는 호출 괄호 없이 instance.Name입니다. Get은 Return 또는 Name 대입으로 반환하고 Exit Property는 그 결과나 기본값을 반환합니다. 대입은 Set(ByVal value As ValueType)을 실행하며 마지막 Get을 읽지 않습니다. 일반 속성은 Get/Set을 하나씩 요구합니다. 접근 범위는 Property에 지정하고 Set은 같은 형식의 명시적인 ByVal 매개변수 하나가 필요합니다.
- `ReadOnly / WriteOnly / auto Property` — 본문이 있는 ReadOnly는 Get만, WriteOnly는 Set만 포함합니다. 금지된 접근은 잡을 수 있는 오류입니다. 자동 속성은 Get/Set과 End Property 없이 값을 직접 저장합니다. 자동 ReadOnly는 해당 인스턴스의 Sub New에서만 대입할 수 있고 Set 없는 WriteOnly는 무효입니다. ReadOnly가 Class 참조를 반환해도 참조 대상의 변경 가능한 멤버는 수정할 수 있습니다.
- `ByVal / ByRef / With` — ByVal은 참조를 복사합니다. 멤버 변경은 원본에 영향을 주지만 매개변수 교체는 호출자 변수를 교체하지 않습니다. ByRef는 엔진의 copy-in/copy-out 규칙에 따라 새 참조도 되씁니다. 동등 비교는 객체 동일성입니다. With instance는 객체를 한 번 캡처하여 필드·속성·메서드에 사용합니다. Class는 자동 IDisposable이 아니므로 Using은 지원되는 리소스 객체에 적용합니다.

## 반환값

New는 Class 참조를 담은 Object를 반환하며 UO ID/그래픽이 아닙니다. Get/Function은 선언 형식, Set/Sub/선언은 Unit입니다. New 없는 변수는 Nothing입니다. 참조 동일성과 As Boolean은 1/True 또는 0/False이고 Integer 수량은 자동 성공 플래그가 아닙니다. Main 결과: "5:2:1", "1:0:6", "ore:1:replacement:0".

## 동작

- SC032는 Option Explicit 없이도 잘못된 선언을 실행 전에 거부합니다. 한도: 클래스 256개, 클래스별 필드/속성 256개와 메서드 256개, New/Get/Set을 포함한 중첩 호출 32단계. 대입/ByRef 경로는 64개 구성 요소까지입니다. 순환 참조는 허용합니다. 메타데이터·기본값은 미리 준비하고 변경 가능한 저장소는 각 New마다 따로 만듭니다.
- 대상 경로를 오른쪽 식/인수의 부수 효과 전에 캡처하여 경로의 각 Get을 한 번 평가합니다. 프로시저가 중간 변수를 교체해도 되쓰기 대상은 원래 객체입니다. 값은 선언 형식으로 변환합니다. 생성자·메서드·접근자 오류는 Try/Catch로 처리하며 이전 변경은 취소하지 않습니다.
- 일시 중지·정지·소스 위치·깊이 제한은 일반 스크립트 프레임을 사용합니다. IDE만 닫아서는 스크립트가 멈추지 않습니다. 검사기는 Get 실행이나 순환 탐색 없이 형식과 멤버 수를 표시합니다. Watch는 저장 필드/자동 속성을 읽을 수 있지만 사용자 Get, 메서드, 생성자를 실행할 수 없습니다. 임의 .NET 클래스가 아닌 설명된 Basic 부분집합입니다.

## 예제

### 1. 독립 객체와 공유 참조

```vb
# New Counter(label:="ore", start:=2)는 String label과 Integer start를 전달하고 Label/stored를 설정합니다. second에는 독립 필드가 있고 alias=first는 참조 복사입니다. Add(amount:=3)는 Value.Set으로 음수를 검사하고 쓴 뒤 Value.Get의 Integer를 반환합니다. first=5, second=2, alias=first는 1/True입니다. 모든 도우미 메서드를 포함합니다.
Option Explicit On
Class Counter
    Private stored As Integer
    Public Property Label As String
    Public Sub New(ByVal label As String, ByVal start As Integer)
        Me.Label = label
        stored = start
    End Sub
    Public Property Value As Integer
        Get
            Return stored
        End Get
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Value must be non-negative"
            End If
            stored = value
        End Set
    End Property
    Public Function Add(ByVal amount As Integer) As Integer
        Me.Value = stored + amount
        Return Me.Value
    End Function
End Class

Sub Main()
    Dim first = New Counter(label:="ore", start:=2)
    Dim second = New Counter("wood", 2)
    Dim alias = first
    alias.Add(amount:=3)
    Return CStr(first.Value) & ":" & CStr(second.Value) & ":" & CStr(alias = first)
End Sub
```

**매개변수 및 실행 설명:**

New Counter(label:="ore", start:=2)는 String label과 Integer start를 전달하고 Label/stored를 설정합니다. second에는 독립 필드가 있고 alias=first는 참조 복사입니다. Add(amount:=3)는 Value.Set으로 음수를 검사하고 쓴 뒤 Value.Get의 Integer를 반환합니다. first=5, second=2, alias=first는 1/True입니다. 모든 도우미 메서드를 포함합니다.

### 2. 읽기·쓰기와 Boolean

```vb
# Limit=10은 value=10으로 Set을 호출합니다. Remaining.Get은 결과 이름에 대입하고 Exit Property로 반환합니다. TrySpend(cost:=4)는 4를 빼고 1/True, cost=9는 남은 6보다 커서 0/False입니다. Limit=-3은 저장 전에 오류를 내고 Catch는 Remaining=6을 읽습니다. Main은 "1:0:6"이며 서버 동작은 없습니다.
Option Explicit On
Class Budget
    Private amount As Integer
    Public ReadOnly Property Remaining() As Integer
        Get
            Remaining = amount
            Exit Property
        End Get
    End Property
    Public WriteOnly Property Limit As Integer
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Limit must be non-negative"
            End If
            amount = value
        End Set
    End Property
    Public Function TrySpend(ByVal cost As Integer) As Boolean
        If cost < 0 Then
            Throw "cost must be non-negative"
        End If
        If cost > amount Then
            Return False
        End If
        amount -= cost
        Return True
    End Function
End Class

Sub Main()
    Dim budget = New Budget()
    budget.Limit = 10
    Dim paid = budget.TrySpend(4)
    Dim refused = budget.TrySpend(9)
    Try
        budget.Limit = -3
    Catch problem
        Return CStr(paid) & ":" & CStr(refused) & ":" & CStr(budget.Remaining)
    End Try
    Return "unexpected"
End Sub
```

**매개변수 및 실행 설명:**

Limit=10은 value=10으로 Set을 호출합니다. Remaining.Get은 결과 이름에 대입하고 Exit Property로 반환합니다. TrySpend(cost:=4)는 4를 빼고 1/True, cost=9는 남은 6보다 커서 0/False입니다. Limit=-3은 저장 전에 오류를 내고 Catch는 Remaining=6을 읽습니다. Main은 "1:0:6"이며 서버 동작은 없습니다.

### 3. Module, ByVal, ByRef 교체

```vb
# Jobs.WorkItem(name)은 String Name을 저장하고 Done은 0으로 시작합니다. Tick(ByVal job)은 공유 Done을 1로 만들지만 뒤의 "local" 교체는 지역 매개변수에만 적용됩니다. Replace(ByRef job, ByVal name)은 "replacement"를 생성하여 호출자 참조를 되씁니다. 명명된 인수를 의도적으로 역순으로 전달합니다. original은 "ore"/1이고 job은 새로운 "replacement"/0입니다. Module Jobs 전체를 제시합니다.
Option Explicit On
Module Jobs
    Public Class WorkItem
        Public Property Name As String
        Public Done As Integer
        Public Sub New(ByVal name As String)
            Me.Name = name
        End Sub
    End Class
    Public Sub Tick(ByVal job As WorkItem)
        job.Done += 1
        job = New WorkItem("local")
    End Sub
    Public Sub Replace(ByRef job As WorkItem, ByVal name As String)
        job = New WorkItem(name)
    End Sub
End Module

Sub Main()
    Dim job As Jobs.WorkItem = New Jobs.WorkItem("ore")
    Dim original = job
    Jobs.Tick(job)
    Jobs.Replace(name:="replacement", job:=job)
    Return original.Name & ":" & CStr(original.Done) & ":" & job.Name & ":" & CStr(job.Done)
End Sub
```

**매개변수 및 실행 설명:**

Jobs.WorkItem(name)은 String Name을 저장하고 Done은 0으로 시작합니다. Tick(ByVal job)은 공유 Done을 1로 만들지만 뒤의 "local" 교체는 지역 매개변수에만 적용됩니다. Replace(ByRef job, ByVal name)은 "replacement"를 생성하여 호출자 참조를 되씁니다. 명명된 인수를 의도적으로 역순으로 전달합니다. original은 "ore"/1이고 job은 새로운 "replacement"/0입니다. Module Jobs 전체를 제시합니다.


### 내부 함수: 호출부터 결과까지

Class는 객체별 상태와 스크립트 메서드를 묶습니다. New는 참조 객체를 생성합니다. 다른 변수에 대입해도 같은 객체를 가리키며, Structure의 값 복사와 다릅니다. 예제에 사용하는 생성자, 메서드, 속성 접근자를 모두 제시합니다.

#### 1. ClassCatalog.Build / Complete

SC032는 Option Explicit 없이도 잘못된 선언을 실행 전에 거부합니다. 한도: 클래스 256개, 클래스별 필드/속성 256개와 메서드 256개, New/Get/Set을 포함한 중첩 호출 32단계. 대입/ByRef 경로는 64개 구성 요소까지입니다. 순환 참조는 허용합니다. 메타데이터·기본값은 미리 준비하고 변경 가능한 저장소는 각 New마다 따로 만듭니다.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; 함수 `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments)는 별도 필드를 만들고 Public Sub New를 한 번 실행합니다. 생성자가 없으면 New TypeName()만 허용합니다. 생성자는 하나이며 일반 Optional, 기본값, 명명된 인수 규칙을 따릅니다. 인수는 작성 순서대로 한 번 평가되며 실패하면 완성된 객체를 반환하지 않습니다. As TypeName만 선언한 변수는 Nothing입니다.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; 함수 `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType에는 인덱스 매개변수가 없습니다. 읽기는 호출 괄호 없이 instance.Name입니다. Get은 Return 또는 Name 대입으로 반환하고 Exit Property는 그 결과나 기본값을 반환합니다. 대입은 Set(ByVal value As ValueType)을 실행하며 마지막 Get을 읽지 않습니다. 일반 속성은 Get/Set을 하나씩 요구합니다. 접근 범위는 Property에 지정하고 Set은 같은 형식의 명시적인 ByVal 매개변수 하나가 필요합니다.

`check member visibility -> stored value OR Get frame -> declared value type`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; 함수 `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

대상 경로를 오른쪽 식/인수의 부수 효과 전에 캡처하여 경로의 각 Get을 한 번 평가합니다. 프로시저가 중간 변수를 교체해도 되쓰기 대상은 원래 객체입니다. 값은 선언 형식으로 변환합니다. 생성자·메서드·접근자 오류는 Try/Catch로 처리하며 이전 변경은 취소하지 않습니다.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; 함수 `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Sub/Function은 instance.Method(...), 클래스 내부에서는 Method(...)/Me.Method(...)로 호출합니다. Private은 같은 Class 코드에서만 호출하며 같은 형식의 다른 인스턴스에도 적용됩니다. 형식, ByVal/ByRef, Optional, ParamArray, 명명된 인수를 지원하되 ParamArray 요소의 이름 지정은 불가합니다. Function은 선언 형식, Sub는 Unit을 반환합니다. TypeName.Method(...)와 instance.New(...)는 잘못된 호출입니다. 인스턴스 메서드의 AddressOf에는 파일/모듈 래퍼 프로시저가 필요합니다.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; 함수 `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

일시 중지·정지·소스 위치·깊이 제한은 일반 스크립트 프레임을 사용합니다. IDE만 닫아서는 스크립트가 멈추지 않습니다. 검사기는 Get 실행이나 순환 탐색 없이 형식과 멤버 수를 표시합니다. Watch는 저장 필드/자동 속성을 읽을 수 있지만 사용자 Get, 메서드, 생성자를 실행할 수 없습니다. 임의 .NET 클래스가 아닌 설명된 Basic 부분집합입니다.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; 함수 `ClassObject.DisplayValue`.

New는 Class 참조를 담은 Object를 반환하며 UO ID/그래픽이 아닙니다. Get/Function은 선언 형식, Set/Sub/선언은 Unit입니다. New 없는 변수는 Nothing입니다. 참조 동일성과 As Boolean은 1/True 또는 0/False이고 Integer 수량은 자동 성공 플래그가 아닙니다. Main 결과: "5:2:1", "1:0:6", "ore:1:replacement:0".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: classDeclaration / classProperty / subrutine / newStructure
Runtime/ClassCatalog.cs: Build / Complete
Runtime/ObjectTypes/ClassObject.cs: Member / Read / Write
Runtime/Interpreter.Classes.cs: ConstructClass / CallClassMethod / InvokeAccessor
Runtime/MemberAccess.cs: Resolve / Read / Write
Runtime/SemanticScope.cs: TryMemberSlot / Coerce
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/class-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/property-statement
-->
