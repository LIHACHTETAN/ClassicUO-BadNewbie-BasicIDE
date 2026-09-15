# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Function은 수량, 문자열, List/Dictionary 참조 등을 반환하는 도우미 함수입니다. 사용자 함수에는 UO.가 필요 없으며 Function GetType(value)를 선언해도 UO.GetType(item)은 별도의 게임 API로 유지됩니다.

## 정확한 구문

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## 매개변수

- `name` — 대소문자를 구분하지 않는 이름은 호출 이름이자 본문 안의 암시적 지역 결과 변수입니다. name은 현재 결과를 읽고 name(arguments)는 재귀를 포함하여 함수를 호출합니다. Dim, Var, Const 또는 매개변수로 결과를 다시 선언하지 마세요.
- `parameters / arguments` — 위치 인수는 Sub와 같은 기본 ByRef, ByVal, Optional, 마지막 ParamArray 규칙을 따릅니다. Basic.Parameters 및 개별 장을 참고하세요. 모듈 함수 Tools.Calculate(...)는 Public/Private 접근 규칙을 따릅니다.
- `As type` — 선택적 결과 형식입니다. Integer/Long/Short/Byte는 엔진의 Integer, Double/Single/Decimal은 Double, String은 텍스트, Boolean/Bool은 1/0 정규화, Object/Variant는 값의 종류 보존을 사용합니다. VB.NET의 모든 숫자 비트 폭을 구현한 것은 아닙니다. 알 수 없는 형식은 거부됩니다. As가 없으면 Variant이며 이름 접미사로 결과 형식을 추론하지 않습니다.
- `name = expression` — 결과를 저장하고 다음 문장을 계속 실행합니다. 함수를 종료하지 않습니다. 결과를 다시 읽거나 += 등으로 수정할 수 있습니다. 현재 호출의 지역 변수이며 전역 변수나 새 호출이 아닙니다.
- `Return / Exit Function / End Function` — Return expression은 형식이 있는 결과를 대입하고 종료를 시작합니다. 빈 Return, Exit Function, End Function 도달은 현재 결과를 반환합니다. End Function은 필수이며 Function 안의 Exit Sub는 로드 오류입니다.

## 반환값

정상 Finally 처리 후의 현재 결과를 반환합니다. 초기값은 Integer 0, Double 0.0, Boolean FALSE/0, String 빈 문자열입니다. 형식 생략 및 Variant/Object는 의미 있는 값이 없는 Unit으로 시작합니다. List/Dictionary/Object는 참조를 유지합니다. Boolean은 숫자 1/0이므로 TRUE/FALSE와 비교할 수 있지만 임의의 수량이나 ID는 자동 성공 코드가 아닙니다.

## 동작

- 준비 단계는 실제 Function 선언을 유지하고 결과 형식과 종료 문장을 검증하며 지역 결과를 연결한 뒤 명령을 한 번 준비합니다. 호출마다 인수와 새로운 형식 결과를 초기화합니다. 이름 대입은 일반 형식 변수의 변환 규칙을 사용합니다.
- Return이 결과를 저장한 뒤 벗어나는 Finally를 안쪽부터 바깥쪽으로 실행합니다. Finally는 호출자에게 돌아가기 전 결과를 수정할 수 있습니다. 성공적으로 끝난 후 ByRef 되쓰기가 완료됩니다. 처리되지 않은 예외나 잘못된 변환은 오류로 전달되며 성공값을 만들지 않습니다.
- 재귀는 독립된 매개변수, 지역 값, 결과를 가집니다. Factorial(n-1)은 호출자의 결과를 덮어쓰지 않습니다. 무한 재귀를 막을 종료 조건이 필요합니다. 스레드, 지연, 시간 제한을 자동으로 추가하지 않으며 일시 중지와 정지 검사는 유지됩니다.
- 중첩 스크립트 프로시저 호출은 콜백과 이벤트 처리기를 포함해 32프레임으로 제한됩니다. 초과하면 잡을 수 있는 오류가 발생하므로 깊은 처리는 반복문을 사용하세요. 반환이나 오류 시 프레임이 해제되어 이후 호출이 가능합니다.

## 예제

### 1. 대입 후 계속 실행

```vb
# TotalPrice는 count와 price를 ByVal로 받고 Integer를 반환합니다. 음수는 즉시 -1을 반환하고, 그 외에는 count*price를 저장한 다음 고정값 2를 더합니다. (3,4)는 14, (-1,4)는 -1이 되어 Main은 14:-1을 반환합니다. -1은 도우미에서 정한 규칙입니다.
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**매개변수 및 실행 설명:**

TotalPrice는 count와 price를 ByVal로 받고 Integer를 반환합니다. 음수는 즉시 -1을 반환하고, 그 외에는 count*price를 저장한 다음 고정값 2를 더합니다. (3,4)는 14, (-1,4)는 -1이 되어 Main은 14:-1을 반환합니다. -1은 도우미에서 정한 규칙입니다.

### 2. 독립된 재귀 결과

```vb
# Factorial은 n을 ByVal로 받고 결과를 1로 초기화합니다. n<=1이면 Exit Function으로 1을 반환하고, 아니면 새 호출을 이용해 n*Factorial(n-1)을 계산합니다. 작은 음이 아닌 입력에서 5!+3!=120+6=126입니다. 음수도 기본 분기로 들어가므로 이 예제는 팩토리얼의 전체 수학적 정의역을 검증하지 않습니다.
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**매개변수 및 실행 설명:**

Factorial은 n을 ByVal로 받고 결과를 1로 초기화합니다. n<=1이면 Exit Function으로 1을 반환하고, 아니면 새 호출을 이용해 n*Factorial(n-1)을 계산합니다. 작은 음이 아닌 입력에서 5!+3!=120+6=126입니다. 음수도 기본 분기로 들어가므로 이 예제는 팩토리얼의 전체 수학적 정의역을 검증하지 않습니다.

### 3. Return, 두 Finally, ByRef

```vb
# Calculate는 trace를 ByRef로 받습니다. Return 1이 결과를 저장하고 종료를 시작합니다. 안쪽 Finally는 결과와 trace를 1에서 12로, 바깥쪽은 123으로 바꿉니다. Main은 두 값 123을 받아 123:123을 반환합니다. Return expression 이후에도 Finally가 결과를 바꿀 수 있습니다. 게임 이동이나 시간을 흉내 내는 예제가 아닙니다.
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**매개변수 및 실행 설명:**

Calculate는 trace를 ByRef로 받습니다. Return 1이 결과를 저장하고 종료를 시작합니다. 안쪽 Finally는 결과와 trace를 1에서 12로, 바깥쪽은 123으로 바꿉니다. Main은 두 값 123을 받아 123:123을 반환합니다. Return expression 이후에도 Finally가 결과를 바꿀 수 있습니다. 게임 이동이나 시간을 흉내 내는 예제가 아닙니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
