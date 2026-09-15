# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

AddressOf는 스크립트의 Sub 또는 Function 참조를 가져오며 즉시 호출하지 않습니다. 참조를 인수로 전달하거나 함수에서 반환하고 컬렉션에 저장하여 처리 규칙을 선택할 수 있습니다.

## 정확한 구문

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## 매개변수

- `ProcedureName` — 선언된 프로시저 이름이며 필요하면 Module 이름을 붙입니다. 일치하는 선언은 하나여야 합니다. 알 수 없는 이름, 접근할 수 없는 Private, 오버로드 이름은 실행 전에 거부합니다. Basic 내장 함수나 UO 명령은 고유한 이름의 스크립트 래퍼를 만든 뒤 그 AddressOf를 사용합니다. 이름 뒤에 괄호를 붙이지 않습니다.
- `callback / arguments` — callback은 Object 값입니다. callback(...)과 callback.Invoke(...)는 현재 스크립트 스레드에서 동기 호출합니다. 명명된 인수는 실제 매개변수 이름을 사용합니다. 컬렉션 요소를 먼저 변수에 저장한 뒤 호출하세요. 인수 계산 전에 참조를 고정하므로 인수가 callback을 바꾸더라도 이번 호출 대상은 유지됩니다.
- `ByRef / ByVal / Optional / ParamArray` — ByVal은 값이나 참조를 복사하고 ByRef는 변경을 다시 기록합니다. Optional은 생략한 기본값을 계산하고 ParamArray는 위치 인수를 모읍니다. 명명된 인수는 위치 인수 뒤에 씁니다. ParamArray 값은 위치 인수만 사용하는 호출이 필요합니다. 잘못된 이름이나 개수는 인수 부작용 전에 오류가 됩니다.

## 반환값

AddressOf는 Object 참조를 반환합니다. ID, 메모리 주소, Boolean 또는 함수 실행 결과가 아닙니다. Function 호출은 함수 결과를 반환하며 Return 식이 없는 Sub는 값을 반환하지 않습니다(Unit). IsPositive는 1/True 또는 0/False를 반환합니다. 예제 1, 3의 Main은 String, 예제 2는 Integer 15를 반환합니다.

## 동작

- 참조는 생성 함수의 지역 변수를 캡처하지 않습니다. 람다나 클로저가 아닙니다. 로드된 스크립트에 속하므로 다른 런타임이나 다시 로드한 스크립트에서는 이전 참조를 호출할 수 없습니다. Public 팩터리는 자신의 Private 도우미 참조를 의도적으로 반환할 수 있습니다.
- 준비 단계에서 이름과 접근 권한을 검사합니다. 인터프리터는 AddressOf 위치마다 불변 참조를 캐시합니다. 호출마다 현재 변수를 읽고 시그니처를 확인한 뒤 인수를 작성 순서대로 한 번씩 계산하여 일반 프로시저 프레임으로 들어갑니다. ByRef와 예외 처리는 직접 호출과 같습니다.
- 스레드나 타이머를 만들지 않습니다. 일시 정지와 취소는 일반 검사 지점을 사용하며 콜백 안의 반복문에도 적용됩니다. 오류는 호출자의 Catch/Finally로 전달됩니다. Catch가 비상 정지를 삼키지 않습니다. 차단되는 네이티브 호출에는 고유한 취소 제한이 남습니다.
- 이 기능은 Delegate 형식 선언, 람다, DLL 함수 포인터, 오버로드 참조를 지원하지 않습니다. AddressOf에 UO.를 붙이지 않으며 래퍼 안의 게임 명령에는 UO.를 유지합니다.

## 예제

### 1. 조건 함수로 목록 필터링

```vb
# values는 입력 List이고 predicate는 AddressOf IsPositive입니다. FilterValues는 수마다 predicate(number)를 한 번 호출합니다. 양수 4와 7만 남아 selected.Count()=2, selected[0]=4이므로 Main은 "2:4"를 반환합니다. 두 도우미는 스크립트에 전체 코드가 있으며 추가 API 명령이 아닙니다.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**매개변수 및 실행 설명:**

values는 입력 List이고 predicate는 AddressOf IsPositive입니다. FilterValues는 수마다 predicate(number)를 한 번 호출합니다. 양수 4와 7만 남아 selected.Count()=2, selected[0]=4이므로 Main은 "2:4"를 반환합니다. 두 도우미는 스크립트에 전체 코드가 있으며 추가 API 명령이 아닙니다.

### 2. 호출자의 변수 변경

```vb
# AddAmount의 total은 ByRef, amount는 ByVal이며 기본값은 1입니다. update(total)은 10을 11로 바꿉니다. Invoke(amount:=4, total:=total)는 이름으로 연결하여 11을 15로 바꿉니다. ByRef가 원래 변수에 다시 기록합니다. Sub는 값을 반환하지 않으며 Main은 Boolean이 아닌 Integer 15를 반환합니다.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**매개변수 및 실행 설명:**

AddAmount의 total은 ByRef, amount는 ByVal이며 기본값은 1입니다. update(total)은 10을 11로 바꿉니다. Invoke(amount:=4, total:=total)는 이름으로 연결하여 11을 15로 바꿉니다. ByRef가 원래 변수에 다시 기록합니다. Sub는 값을 반환하지 않으며 Main은 Boolean이 아닌 Integer 15를 반환합니다.

### 3. 비공개 규칙과 오류 처리

```vb
# Rules.Create는 Private CheckedDouble 참조를 반환합니다. 외부에서 AddressOf Rules.CheckedDouble을 직접 가져올 수 없습니다. operation(6)은 12를 반환합니다. operation(-1)은 대입 전에 "negative"를 발생시켜 result는 12로 유지됩니다. Catch는 메시지를 받고 Finally는 ":done"을 붙입니다. Main은 "12:negative:done"를 반환합니다. IDE를 닫는 것만으로 스크립트는 멈추지 않습니다.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**매개변수 및 실행 설명:**

Rules.Create는 Private CheckedDouble 참조를 반환합니다. 외부에서 AddressOf Rules.CheckedDouble을 직접 가져올 수 없습니다. operation(6)은 12를 반환합니다. operation(-1)은 대입 전에 "negative"를 발생시켜 result는 12로 유지됩니다. Catch는 메시지를 받고 Finally는 ":done"을 붙입니다. Main은 "12:negative:done"를 반환합니다. IDE를 닫는 것만으로 스크립트는 멈추지 않습니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
