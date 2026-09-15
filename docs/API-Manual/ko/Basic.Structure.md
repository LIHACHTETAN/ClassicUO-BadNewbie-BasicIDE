# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Structure는 X, Y, Z 같은 형식 지정 필드를 하나의 값으로 묶습니다. 이 엔진은 값을 복사하는 데이터 구조를 지원하며, VB.NET의 Structure 전체 기능을 구현한 것은 아닙니다.

## 정확한 구문

```text
[Public | Private] Structure TypeName
    [Public | Dim | VAR] field As FieldType
End Structure
Dim value As TypeName
Dim value = New TypeName()
copy = value
value.field = expression
Sub Change(ByRef value As TypeName)
Function Copy(ByVal value As TypeName) As TypeName
```

## 매개변수

- `TypeName / Public / Private` — 파일 수준 또는 Module 안에 선언하는 고유한 단순 형식 이름입니다. 기본은 Public입니다. Private는 Module 내부에서만 허용되며 외부에서는 해당 형식 이름을 사용할 수 없습니다. 공개 모듈 형식은 ModuleName.TypeName으로 지정합니다. 키워드와 필드 이름은 번역하지 않습니다.
- `field / FieldType` — 고유한 필드 이름, As, 지원되는 스칼라 형식·Enum·다른 Structure를 지정합니다. 필드는 공개이며 Public, Dim, VAR를 쓸 수 있습니다. 형식: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. 정수 별칭은 모두 부호 있는 32비트입니다. 중첩 구조의 순환은 금지됩니다.
- `Dim / New` — Dim value As TypeName과 New TypeName()은 사용자 코드를 호출하지 않고 기본값을 만듭니다. New의 괄호는 비워야 합니다. X/Y/Z 인수를 받지 않으므로 생성 후 필드에 대입합니다. Dim copy = value는 식의 값을 얻습니다. UO. 접두사는 필요 없습니다.
- `value.field / copy` — 점으로 필드를 읽고 쓰며 route.Start.X 같은 중첩 경로도 가능합니다. 쓰기 시 필드 형식을 확인하고 이를 포함한 값을 교체합니다. copy = value는 스칼라와 중첩 구조 값을 복사하므로 copy.X 변경이 value.X를 바꾸지 않습니다. 구조 형식이 호환되어야 합니다.
- `ByVal / ByRef` — ByVal은 값의 복사본을 전달합니다. ByRef는 진입 시 복사하고 종료 시 호출자에 다시 기록하며, 쓰기 가능한 필드 인수도 지원합니다. 한정자를 명시하세요. 생략하면 기존 Basic 규칙이 적용됩니다. Return으로 구조를 반환하고 Function에 As TypeName을 선언할 수 있습니다.

## 반환값

선언과 대입에는 결과가 없습니다(Unit). New와 해당 함수는 구조 값을 반환하며 실행 관찰에서는 Object로 표현되고 표시 내용에 선언된 형식 이름이 포함됩니다. 좌표는 수량이며 Boolean 플래그가 아닙니다. =와 <>는 1/True 또는 0/False를 반환합니다. 예제의 String 결과: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

## 동작

- 선언은 초기화 식 실행 전에 검사합니다. 스크립트당 최대 256개 형식, 형식마다 1–256개 필드, 중첩은 최대 32단계입니다. 중복·알 수 없는 필드 형식, 순환, 제한 초과는 SC030을 발생시킵니다. 이름 바인딩 단계에서 Private를 검사합니다.
- 기본 필드 값: 정수/Enum 0, 실수 0, Boolean 0/False, String 빈 문자열, Object/Variant는 대입 전 Unit. 중첩 구조도 자체 기본값을 갖습니다. 필드 선언 안의 초기화는 지원되지 않으므로 생성 후 대입하세요.
- Object와 배열 필드는 복사 시 참조를 유지하므로 두 복사본이 List, Dictionary 또는 배열을 공유할 수 있습니다. 스칼라와 중첩 값은 독립적으로 변경되지만 공유 컬렉션의 내용 변경은 양쪽에 보입니다. List는 추가 당시의 구조 값을 저장합니다.
- =는 동일한 선언 형식과 대응 필드를 비교하며 <>는 반대 결과입니다. 참조 필드는 동일성으로 비교합니다. 이는 엔진 확장이며 모든 VB.NET 구조에 =가 지원된다는 뜻은 아닙니다. 저장된 해시와 이미 방문한 쌍으로 공유 중첩 값을 반복해서 펼치는 작업을 방지합니다.
- 지원 범위: 공개 형식 지정 데이터 필드, Module 가시성, New(), 대입, 매개변수와 반환값. 내부 메서드, 사용자 생성자, 필드 초기화, 속성, 상속, 비공개 필드는 지원하지 않습니다. WITH .field와 array[index].field도 지원하지 않습니다. 요소를 변수로 읽고 수정한 뒤 다시 저장하세요. 선언을 Include 파일에 둘 수 있습니다.

## 예제

### 1. 좌표와 독립적인 복사본

```vb
# original은 X=1445, Y=1690이며 Z는 0입니다. copy에 값을 복사하고 copy.X += 2로 복사본만 변경합니다. New Position()은 Z=0인 empty를 만듭니다. 결과는 1445:1447:1690:0입니다. 저장된 좌표를 다루며 캐릭터를 이동시키는 스크립트는 아닙니다.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
    Public Z As Integer
End Structure

Sub Main()
    Dim original As Position
    original.X = 1445
    original.Y = 1690
    Dim copy = original
    copy.X += 2
    Dim empty = New Position()
    Return CStr(original.X) & ":" & CStr(copy.X) & ":" & CStr(copy.Y) & ":" & CStr(empty.Z)
End Sub
```

**매개변수 및 실행 설명:**

original은 X=1445, Y=1690이며 Z는 0입니다. copy에 값을 복사하고 copy.X += 2로 복사본만 변경합니다. New Position()은 Z=0인 empty를 만듭니다. 결과는 1445:1447:1690:0입니다. 저장된 좌표를 다루며 캐릭터를 이동시키는 스크립트는 아닙니다.

### 2. 중첩 경로, ByVal과 ByRef

```vb
# Route에는 Position 형식의 Start와 Finish가 있습니다. Shift(point ByVal, dx ByVal)는 복사본의 X에 dx를 더하고 Position을 반환합니다. point:=route.Start, dx:=5이면 shifted.X=15이고 Start.X는 10입니다. Advance(route ByRef, dx ByVal)는 Finish.X에 4를 더한 뒤 Route를 다시 기록하여 24를 만듭니다. Main 결과는 10:15:24이며 모든 보조 프로시저가 표시되어 있습니다.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
End Structure
Structure Route
    Public Start As Position
    Public Finish As Position
End Structure

Function Shift(ByVal point As Position, ByVal dx As Integer) As Position
    point.X += dx
    Return point
End Function

Sub Advance(ByRef route As Route, ByVal dx As Integer)
    route.Finish.X += dx
End Sub

Sub Main()
    Dim route As Route
    route.Start.X = 10
    route.Finish.X = 20
    Dim shifted = Shift(point:=route.Start, dx:=5)
    Advance(route:=route, dx:=4)
    Return CStr(route.Start.X) & ":" & CStr(shifted.X) & ":" & CStr(route.Finish.X)
End Sub
```

**매개변수 및 실행 설명:**

Route에는 Position 형식의 Start와 Finish가 있습니다. Shift(point ByVal, dx ByVal)는 복사본의 X에 dx를 더하고 Position을 반환합니다. point:=route.Start, dx:=5이면 shifted.X=15이고 Start.X는 10입니다. Advance(route ByRef, dx ByVal)는 Finish.X에 4를 더한 뒤 Route를 다시 기록하여 24를 만듭니다. Main 결과는 10:15:24이며 모든 보조 프로시저가 표시되어 있습니다.

### 3. 저장한 값과 공유 컬렉션

```vb
# Entry에는 값 필드 Point와 Object 필드 Items가 있습니다. first.Point.X=2이며 Items는 문자열 하나를 가진 List()입니다. snapshots.Add(first)는 값을 저장합니다. second=first 후 second.Point.X=4로 바꿔도 저장된 2는 유지됩니다. second.Items.Add("ingot")는 공유 List를 바꾸므로 first.Items.Count()=2입니다. saved=snapshots[0]으로 요소 필드를 읽습니다. 결과: 2:4:2:2.
Option Explicit On
Structure Position
    Public X As Integer
End Structure
Structure Entry
    Public Point As Position
    Public Items As Object
End Structure

Sub Main()
    Dim first As Entry
    first.Point.X = 2
    first.Items = List()
    first.Items.Add("ore")
    Dim snapshots = List()
    snapshots.Add(first)

    Dim second = first
    second.Point.X = 4
    second.Items.Add("ingot")
    Dim saved = snapshots[0]
    Return CStr(first.Point.X) & ":" & CStr(second.Point.X) & ":" & CStr(saved.Point.X) & ":" & CStr(first.Items.Count())
End Sub
```

**매개변수 및 실행 설명:**

Entry에는 값 필드 Point와 Object 필드 Items가 있습니다. first.Point.X=2이며 Items는 문자열 하나를 가진 List()입니다. snapshots.Add(first)는 값을 저장합니다. second=first 후 second.Point.X=4로 바꿔도 저장된 2는 유지됩니다. second.Items.Add("ingot")는 공유 List를 바꾸므로 first.Items.Count()=2입니다. saved=snapshots[0]으로 요소 필드를 읽습니다. 결과: 2:4:2:2.


### 내부 함수: 호출부터 결과까지

Structure는 X, Y, Z 같은 형식 지정 필드를 하나의 값으로 묶습니다. 이 엔진은 값을 복사하는 데이터 구조를 지원하며, VB.NET의 Structure 전체 기능을 구현한 것은 아닙니다.

#### 1. Build / PrepareDefault

선언은 초기화 식 실행 전에 검사합니다. 스크립트당 최대 256개 형식, 형식마다 1–256개 필드, 중첩은 최대 32단계입니다. 중복·알 수 없는 필드 형식, 순환, 제한 초과는 SC030을 발생시킵니다. 이름 바인딩 단계에서 Private를 검사합니다.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; 함수 `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName과 New TypeName()은 사용자 코드를 호출하지 않고 기본값을 만듭니다. New의 괄호는 비워야 합니다. X/Y/Z 인수를 받지 않으므로 생성 후 필드에 대입합니다. Dim copy = value는 식의 값을 얻습니다. UO. 접두사는 필요 없습니다.

`resolve TypeName -> prepared default value; no procedure call`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 함수 `VisitNewStructure`.

#### 3. WithField / SetVar

점으로 필드를 읽고 쓰며 route.Start.X 같은 중첩 경로도 가능합니다. 쓰기 시 필드 형식을 확인하고 이를 포함한 값을 교체합니다. copy = value는 스칼라와 중첩 구조 값을 복사하므로 copy.X 변경이 value.X를 바꾸지 않습니다. 구조 형식이 호환되어야 합니다.

`resolve path -> coerce field -> replace path -> assign new root value`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; 함수 `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal은 값의 복사본을 전달합니다. ByRef는 진입 시 복사하고 종료 시 호출자에 다시 기록하며, 쓰기 가능한 필드 인수도 지원합니다. 한정자를 명시하세요. 생략하면 기존 Basic 규칙이 적용됩니다. Return으로 구조를 반환하고 Function에 As TypeName을 선언할 수 있습니다.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 함수 `CreateArgumentWriter`.

#### 5. ValueEquals

=는 동일한 선언 형식과 대응 필드를 비교하며 <>는 반대 결과입니다. 참조 필드는 동일성으로 비교합니다. 이는 엔진 확장이며 모든 VB.NET 구조에 =가 지원된다는 뜻은 아닙니다. 저장된 해시와 이미 방문한 쌍으로 공유 중첩 값을 반복해서 펼치는 작업을 방지합니다.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; 함수 `ValueEquals`.

선언과 대입에는 결과가 없습니다(Unit). New와 해당 함수는 구조 값을 반환하며 실행 관찰에서는 Object로 표현되고 표시 내용에 선언된 형식 이름이 포함됩니다. 좌표는 수량이며 Boolean 플래그가 아닙니다. =와 <>는 1/True 또는 0/False를 반환합니다. 예제의 String 결과: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryMemberRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
