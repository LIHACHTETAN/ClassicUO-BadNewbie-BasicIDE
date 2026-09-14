# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

이름 있는 인수는 선언된 매개변수 이름에 값을 연결하므로 선언 순서와 다르게 쓸 수 있습니다. 스크립트 프로시저, 함수, 모듈, 등록된 Basic/UO 함수와 네이티브 객체 메서드를 지원합니다.

## 정확한 구문

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## 매개변수

- `parameterName / [reservedName]` — 선언이나 시그니처의 이름으로 name:=value를 쓰며 대소문자를 구분하지 않습니다. 예약어 이름은 [to]:=100처럼 묶습니다. 대괄호는 이름을 이스케이프하며 배열 인덱스가 아닙니다. 알 수 없거나 중복된 이름은 오류입니다.
- `expression` — 제공한 식은 작성 순서대로 왼쪽에서 오른쪽으로 한 번씩 계산된 뒤 매개변수에 배치됩니다. 형식, 범위, ByVal/ByRef는 호출 함수의 규칙을 따릅니다. 이름 지정으로 일반 값이 수정 가능한 변수로 바뀌지 않습니다.
- `positionalExpression / optionalName` — 위치 인수를 먼저 쓰고 첫 이름 있는 인수 뒤에는 모두 이름을 지정하세요. 필수 매개변수는 생략할 수 없습니다. 생략한 스크립트 Optional은 전달 식을 계산한 뒤 선언 순서대로 기본 식을 계산합니다. 네이티브 오버로드는 등록된 이름과 개수만 사용하며 임의 기본값을 추가하지 않습니다.

## 반환값

:= 자체는 값을 반환하지 않습니다. 함수/API는 원래 결과를 반환하고 Sub에는 암시적 결과가 없습니다. 예제는 Integer 129와 String "21:12", "20:10:2"를 반환하며 Boolean 성공 표시가 아닙니다.

## 동작

- 준비 단계는 잘못된 이름, 중복, 필수 인수 누락 또는 모호성을 소스 위치와 SC027로 보고합니다. 동적 객체는 실행 시 인수 식을 계산하기 전에 확인합니다. 네이티브 오버로드가 없다고 인수 없는 호출로 대체하지 않습니다.
- 정적 호출 위치의 불변 매핑을 캐시합니다. 식은 소스 순서로 계산하고 매개변수 대입과 ByRef 쓰기는 매핑을 따릅니다. 기본값과 디버거 인수는 선택한 시그니처에 대응합니다. 동적 수신 객체는 매 호출마다 캡처하며 이전 객체를 재사용하지 않습니다.
- ParamArray는 이름으로 전달할 수 없습니다. 이름 있는 호출에서는 비워 둘 수 있지만 요소를 전달하려면 모두 위치 인수로 호출해야 합니다. 쉼표 사이 빈 자리는 지원하지 않습니다. 이 부분집합은 위치 인수 우선이며 최신 VB.NET의 자유 혼합은 아닙니다. 스레드나 게임 지연을 추가하지 않습니다.

## 예제

### 1. 가운데 Optional 생략

```vb
# Encode는 x, y=2, z=3을 선언합니다. z:=9를 먼저, x:=1을 나중에 제공하며 y는 2가 됩니다. 계산은 1*100+2*10+9=129입니다. Encode(1,2,9) 및 Encode(1,z:=9)와 같습니다.
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**매개변수 및 실행 설명:**

Encode는 x, y=2, z=3을 선언합니다. z:=9를 먼저, x:=1을 나중에 제공하며 y는 2가 됩니다. 계산은 1*100+2*10+9=129입니다. Encode(1,2,9) 및 Encode(1,z:=9)와 같습니다.

### 2. 올바른 변수에 ByRef 쓰기

```vb
# Change는 ByRef left와 right를 받습니다. right:=a는 a=1을 right에, left:=b는 b=2를 left에 연결합니다. left에 10, right에 20을 더한 뒤 b=12, a=21을 다시 씁니다. Main은 "21:12"를 반환합니다. := 왼쪽은 매개변수이고 오른쪽은 호출자 변수입니다.
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**매개변수 및 실행 설명:**

Change는 ByRef left와 right를 받습니다. right:=a는 a=1을 right에, left:=b는 b=2를 left에 연결합니다. left에 10, right에 20을 더한 뒤 b=12, a=21을 다시 씁니다. Main은 "21:12"를 반환합니다. := 왼쪽은 매개변수이고 오른쪽은 호출자 변수입니다.

### 3. 네이티브 목록 조작

```vb
# List()가 목록을 만듭니다. Add(value:=10)은 반환값 없이 10을 추가합니다. Insert(value:=20,index:=0)은 인덱스 0에 20을 넣고 10을 인덱스 1로 옮깁니다. Item(index:=...)은 요소를, Count()는 2를 반환합니다. Main 결과는 "20:10:2"입니다. UO.Name(...)도 같은 규칙을 쓰며 각 명령의 등록 이름과 반환 계약을 따릅니다.
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**매개변수 및 실행 설명:**

List()가 목록을 만듭니다. Add(value:=10)은 반환값 없이 10을 추가합니다. Insert(value:=20,index:=0)은 인덱스 0에 20을 넣고 10을 인덱스 1로 옮깁니다. Item(index:=...)은 요소를, Count()는 2를 반환합니다. Main 결과는 "20:10:2"입니다. UO.Name(...)도 같은 규칙을 쓰며 각 명령의 등록 이름과 반환 계약을 따릅니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
