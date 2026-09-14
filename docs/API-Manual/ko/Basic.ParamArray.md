# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

매개변수는 SUB/FUNCTION에 데이터를 전달합니다. ByRef는 변경 값을 호출자에게 기록하고 ByVal은 호출자의 변수를 보존합니다. Optional은 생략한 인수를 보충하고 ParamArray는 나머지 인수를 모읍니다. 호출 명령이 아니라 선언 한정자입니다.

## 정확한 구문

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
```

## 매개변수

- `name / As type` — name / As type: 매개변수 이름과 선택적인 As 입력 형식 변환입니다. 위치 또는 name:=value로 연결하며 한정자는 선언에 씁니다. Basic.NamedArguments를 참고하세요.
- `ByRef` — ByRef: 쓰기 가능한 변수 또는 기존 인덱스 요소입니다. 이 엔진은 ByVal이 없어도 값을 다시 기록하므로 VB.NET 기본값과 다릅니다. 리터럴, 상수, 계산식은 임시 값입니다.
- `ByVal` — ByVal: 값의 지역 복사본입니다. 매개변수에 대입해도 호출자의 변수를 교체하지 않습니다. 배열과 객체는 참조를 공유하며 깊은 복사가 아닙니다.
- `Optional / defaultValue` — Optional / defaultValue: 마지막 인수를 생략하면 = 뒤의 식을 계산합니다. 명시적 기본값을 지정하세요. 없으면 생략된 매개변수는 초기화되지 않은 Unit을 받습니다.
- `ParamArray` — ParamArray values(): 마지막 매개변수가 나머지 값을 0개 이상 받습니다. 배열 하나는 그대로 사용하고 스칼라 인수는 새 배열로 묶습니다. GetArrayLength는 길이를 반환합니다.

## 반환값

한정자는 값을 반환하지 않습니다. RETURN은 결과를 따로 설정합니다. ByRef는 인수를 변경하는 것이지 반환값이 아닙니다. RETURN 없는 SUB는 Unit을 만듭니다. 예제 숫자는 계산 결과이며 TRUE/FALSE 플래그가 아닙니다.

## 동작

- 인수는 왼쪽부터 한 번씩 계산합니다. 인덱스 ByRef는 컨테이너와 인덱스/키를 저장합니다. 다른 인수가 컨테이너 변수를 재대입해도 기록 위치를 바꾸지 않습니다.
- 진입할 때 지역 매개변수를 만듭니다. 종료 시 내부 FINALLY 뒤에 매개변수 순서대로 ByRef 값을 기록하며 본문에서 오류로 나올 때도 같습니다. 같은 변수를 두 번 전달해도 지역 매개변수가 즉시 연결되지는 않습니다. 마지막 기록이 남습니다.
- ByVal은 호출자 변수의 교체를 막지만 공유 배열이나 객체 내부 수정은 허용합니다. ReDim은 새 지역 참조를 만듭니다. 독립 데이터에는 명시적 복사가 필요합니다.
- 위치 인수 호출: Optional은 뒤에서부터 생략하며 쉼표 사이의 빈 인수는 지원하지 않습니다. 기본식은 생략할 때마다 실행하는 엔진 식이며 VB.NET 상수일 필요가 없습니다. 위치 인수를 먼저 쓰고 첫 이름 있는 인수 뒤에는 모두 이름을 지정하세요. 필수 매개변수는 생략할 수 없습니다. 생략한 스크립트 Optional은 전달 식을 계산한 뒤 선언 순서대로 기본 식을 계산합니다. 네이티브 오버로드는 등록된 이름과 개수만 사용하며 임의 기본값을 추가하지 않습니다.
- ParamArray는 묶인 스칼라를 원래 변수에 다시 쓰지 않습니다. 배열을 명시적으로 전달하면 요소 변경이 호출자에게 보입니다. 다른 ParamArray로 전달해도 중첩을 추가하지 않습니다.
- 의도를 드러내도록 ByRef와 ByVal을 명시하세요. 이 규칙은 스크립트에서 사용자 프로시저를 호출할 때 적용되며 내장 명령 인수는 각 문서에 설명합니다.
- ParamArray는 이름으로 전달할 수 없습니다. 이름 있는 호출에서는 비워 둘 수 있지만 요소를 전달하려면 모두 위치 인수로 호출해야 합니다. 쉼표 사이 빈 자리는 지원하지 않습니다. 이 부분집합은 위치 인수 우선이며 최신 VB.NET의 자유 혼합은 아닙니다. 스레드나 게임 지연을 추가하지 않습니다.

## 예제

### 1. 비어 있거나 채워진 인수

```vb
# Sum()은 빈 배열로 0을, Sum(2,3,4)는 세 값으로 9를 반환합니다. For Each가 각 값을 방문합니다. Main은 Integer 9를 반환합니다.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Sub Main()
    Return Sum() + Sum(2, 3, 4)
End Sub
```

**매개변수 및 실행 설명:**

Sum()은 빈 배열로 0을, Sum(2,3,4)는 세 값으로 9를 반환합니다. For Each가 각 값을 방문합니다. Main은 Integer 9를 반환합니다.

### 2. 기존 배열 전달

```vb
# values에는 2와 5가 있습니다. Forward는 추가 포장 없이 Sum에 배열을 전달합니다. Sum은 합계 Integer 7을 반환합니다.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Function Forward(ParamArray values())
    Return Sum(values)
End Function
Sub Main()
    Dim values[1]
    values[0] = 2
    values[1] = 5
    Return Forward(values)
End Sub
```

**매개변수 및 실행 설명:**

values에는 2와 5가 있습니다. Forward는 추가 포장 없이 Sum에 배열을 전달합니다. Sum은 합계 Integer 7을 반환합니다.

### 3. 스칼라와 제공된 배열

```vb
# SetFirst(first,second)는 새 배열을 수정하므로 first=2와 second=3이 유지됩니다. SetFirst(packed)는 공유 packed[0]을 4에서 9로 바꿉니다. Main은 2*100+3*10+9, Integer 239를 반환합니다.
Option Explicit On
Sub SetFirst(ParamArray values())
    If GetArrayLength(values) > 0 Then
        values[0] = 9
    End If
End Sub
Sub Main()
    Var first = 2
    Var second = 3
    SetFirst(first, second)
    Dim packed[0]
    packed[0] = 4
    SetFirst(packed)
    Return first * 100 + second * 10 + packed[0]
End Sub
```

**매개변수 및 실행 설명:**

SetFirst(first,second)는 새 배열을 수정하므로 first=2와 second=3이 유지됩니다. SetFirst(packed)는 공유 packed[0]을 4에서 9로 바꿉니다. Main은 2*100+3*10+9, Integer 239를 반환합니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: parameterName / parameterModifier / defaultValue
Runtime/SubrutineDefinition.cs: WritableParameters / RequiredArgumentCount / HasParamArray
Runtime/Interpreter.cs: VisitCall / CreateArgumentWriter / CallSubrutine / EvaluateInitializer
Runtime/IndexedValueSlot.cs: Read / Write
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byref
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byval
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/optional
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/paramarray
-->
