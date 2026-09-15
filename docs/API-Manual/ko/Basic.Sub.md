# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Sub는 여러 문장을 이름 있는 프로시저로 묶습니다. 아이템 처리, 검증, 마무리 작업을 재사용할 때 유용합니다. 호출은 현재 스크립트에서 동기적으로 실행되며 별도의 백그라운드 스크립트를 시작하지 않습니다.

## 정확한 구문

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## 매개변수

- `name` — 이름은 대소문자를 구분하지 않습니다. 직접 작성한 호출에는 UO.를 붙이지 않으며 모듈 멤버는 Tools.Work(...)로 호출합니다. Public/Private 접근 규칙은 Basic.Module 및 Basic.Visibility를 참고하세요.
- `parameters / arguments` — 매개변수는 괄호 안에 선언하고 인수를 선언 순서대로 전달합니다. 기본은 ByRef이며 ByVal은 값 복사, Optional은 생략한 값, 마지막 ParamArray는 추가 인수 묶음을 처리합니다. 형식, 배열, 공유 참조, 되쓰기는 다섯 매개변수 장에서 설명합니다.
- `statements / End Sub` — 본문은 비어 있어도 되지만 End Sub로 닫아야 합니다. 재귀를 포함하여 호출마다 별도의 지역 변수를 가집니다. 프로시저는 파일이나 모듈 수준에 선언하며 다른 프로시저 안에 선언하지 않습니다.
- `Call` — name(arguments)에서 Call은 선택 사항입니다. Call name arguments는 괄호 없는 인수도 허용하고 Call name은 매개변수 없이 호출합니다. Call은 반환값을 버립니다. 인수 표현식의 의미는 그대로이며 사용자 이름에 UO.를 추가하지 않습니다.
- `Exit Sub / Return` — Exit Sub 또는 표현식 없는 Return은 현재 호출을 끝냅니다. Sub 안의 Return expression은 Basic 호환 확장이며 일반 VB.NET Sub에는 없습니다. Sub 안에서 Exit Function을 쓰면 로드 오류입니다.

## 반환값

End Sub, Exit Sub, 빈 Return은 Unit을 반환합니다. 의미 있는 결과가 없다는 뜻이며 성공 플래그나 ID가 아닙니다. 기존 Basic Sub는 Return expression으로 값을 반환할 수 있습니다. ByRef는 별도로 호출자의 변수를 바꿀 수 있습니다. 결과 계산용 도우미에는 Function을 권장합니다.

## 동작

- 준비 단계는 호환 선언과 Call 형식을 정규화하고 블록을 검증하며 이름을 해석합니다. 진입 전에 인수를 계산하고 연결합니다. 호출은 준비된 명령을 재사용하지만 지역 값은 공유하지 않습니다.
- 인터프리터는 호출 범위를 만들고 본문을 실행한 뒤 호출 다음 문장으로 돌아옵니다. 정상 종료와 Exit Sub는 벗어나는 Finally를 실행한 다음 매개변수 되쓰기를 완료합니다. 예외는 활성 오류 처리기로 전달되며 실패한 호출은 성공을 뜻하지 않습니다.
- 일시 중지와 정지 검사는 유지됩니다. 새 스레드, 자동 지연, 시간 제한은 생기지 않습니다. 재귀에는 종료 조건이 필요합니다. Sub 이름에 대입해도 반환 결과가 설정되지 않으므로 그 용도에는 Function을 사용합니다.
- 중첩 스크립트 프로시저 호출은 콜백과 이벤트 처리기를 포함해 32프레임으로 제한됩니다. 초과하면 잡을 수 있는 오류가 발생하므로 깊은 처리는 반복문을 사용하세요. 반환이나 오류 시 프레임이 해제되어 이후 호출이 가능합니다.

## 예제

### 1. 세 가지 호출 형식

```vb
# total은 4로 시작합니다. AddAmount는 total을 ByRef로 받고 생략한 amount는 1, 명시한 3과 2는 ByVal입니다. 괄호 있는 Call, 괄호 없는 Call, 일반 호출은 같은 도우미를 실행합니다. Main은 4+1+3+2=10을 명시적으로 반환합니다.
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**매개변수 및 실행 설명:**

total은 4로 시작합니다. AddAmount는 total을 ByRef로 받고 생략한 amount는 1, 명시한 3과 2는 ByVal입니다. 괄호 있는 Call, 괄호 없는 Call, 일반 호출은 같은 도우미를 실행합니다. Main은 4+1+3+2=10을 명시적으로 반환합니다.

### 2. 공개 진입점과 비공개 도우미

```vb
# Batches.SumInto는 total을 ByRef로 받고 3,-9,4를 values에 모읍니다. For Each가 AppendAmount를 호출합니다. 음수 검사는 도우미만 종료하므로 -9를 건너뛰고 반복을 계속합니다. 초기값 2에서 2+3+4=9가 됩니다. 외부에서는 공개된 전체 모듈 이름으로 호출합니다.
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**매개변수 및 실행 설명:**

Batches.SumInto는 total을 ByRef로 받고 3,-9,4를 values에 모읍니다. For Each가 AppendAmount를 호출합니다. 음수 검사는 도우미만 종료하므로 -9를 건너뛰고 반복을 계속합니다. 초기값 2에서 2+3+4=9가 됩니다. 외부에서는 공개된 전체 모듈 이름으로 호출합니다.

### 3. 조기 종료와 정리

```vb
# Finish는 trace=1을 설정하고 종료하여 trace=99를 실행하지 않습니다. Finally가 2를 덧붙여 trace=12를 ByRef로 돌려줍니다. LegacyValue는 Basic Sub의 Return 7을 보여 줍니다. Main은 12*10+7=127을 반환합니다. trace 숫자는 예제에서 정한 값이며 게임 결과 코드가 아닙니다.
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**매개변수 및 실행 설명:**

Finish는 trace=1을 설정하고 종료하여 trace=99를 실행하지 않습니다. Finally가 2를 덧붙여 trace=12를 ByRef로 돌려줍니다. LegacyValue는 Basic Sub의 Return 7을 보여 줍니다. Main은 12*10+7=127을 반환합니다. trace 숫자는 예제에서 정한 값이며 게임 결과 코드가 아닙니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
