# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

비교 연산자는 두 값을 검사하여 IF, 변수 대입 또는 보조 함수 RETURN에서 사용할 논리 결과를 만듭니다.

## 정확한 구문

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## 매개변수

- `left` — 왼쪽 값: 리터럴, 선언된 변수, 식 또는 함수 결과입니다.
- `right` — 오른쪽 값입니다. 크기 비교는 Integer 또는 Decimal이 필요하며 동등 비교는 다른 값 종류도 지원합니다.
- `operator` — 식에서 =와 ==는 같음, <>는 다름, <와 >는 엄격한 크기 비교, <=와 >=는 같음을 포함합니다. 독립된 name = expression 문은 대입입니다.

## 반환값

비교가 성립하면 Integer 1(TRUE), 아니면 Integer 0(FALSE)입니다. 이 결과에 대해 result=1은 result=TRUE와 같고 result=0은 result=FALSE와 같습니다. 수량이나 ID는 의미가 다릅니다. 2는 0이 아니지만 2=TRUE는 거짓입니다. 0이 아닌 수량은 count<>0으로 검사하세요.

## 동작

- Integer와 Decimal은 숫자로 비교하므로 5=5.0은 참입니다. 텍스트는 자동 변환하지 않아 "5"=5는 거짓입니다. 문자열 동등 비교는 대소문자를 구분하는 서수 비교이므로 "Ore"<>"ore"입니다. 텍스트, 배열, 객체, Unit의 <, >, <=, >= 크기 비교는 오류입니다.
- 배열과 네이티브 객체의 동등 비교는 내용이 아닌 참조 동일성을 검사합니다. Unit끼리는 같지만 Unit은 숫자 0이 아닙니다. Integer/Decimal 숫자 쌍을 제외한 서로 다른 종류는 같지 않습니다. NaN은 자신과도 다르며 NaN을 포함한 숫자 크기 비교는 모두 거짓입니다.
- 산술을 먼저 계산하고 연속 비교는 왼쪽부터 처리합니다. 1<3<2는 (1<3)<2이므로 참입니다. 범위 검사는 (low<=value) AND (value<=high)로 쓰고 괄호로 묶음을 명확히 하세요.
- 이진 부동소수점은 반올림될 수 있습니다. 근사 측정값은 적절한 음수가 아닌 허용 오차로 Abs(actual-expected)<=tolerance를 사용하세요. 허용 오차는 스크립트에서 정하며 연산자가 자동 적용하지 않습니다.
- =는 동일한 선언 형식과 대응 필드를 비교하며 <>는 반대 결과입니다. 참조 필드는 동일성으로 비교합니다. 이는 엔진 확장이며 모든 VB.NET 구조에 =가 지원된다는 뜻은 아닙니다. 저장된 해시와 이미 방문한 쌍으로 공유 중첩 값을 반복해서 펼치는 작업을 방지합니다.

## 예제

### 1. 경계를 포함한 범위와 TRUE

```vb
# InRange는 value=4, low=2, high=5를 받습니다. 두 비교 모두 1이고 AND 결과도 1입니다. Main은 accepted=TRUE를 검사하여 1을 반환합니다. 보조 함수와 호출 코드 전체가 포함됩니다.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**매개변수 및 실행 설명:**

InRange는 value=4, low=2, high=5를 받습니다. 두 비교 모두 1이고 AND 결과도 1입니다. Main은 accepted=TRUE를 검사하여 1을 반환합니다. 보조 함수와 호출 코드 전체가 포함됩니다.

### 2. 텍스트, 숫자와 대소문자

```vb
# sameCase는 "Ore"와 "ore"를 비교하여 0입니다. sameKind는 "5"와 Integer 5를 비교하여 0입니다. converted는 CDbl("5")를 명시적으로 써서 1입니다. CStr로 진단 문자열 "0:0:1"을 반환합니다.
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**매개변수 및 실행 설명:**

sameCase는 "Ore"와 "ore"를 비교하여 0입니다. sameKind는 "5"와 Integer 5를 비교하여 0입니다. converted는 CDbl("5")를 명시적으로 써서 1입니다. CStr로 진단 문자열 "0:0:1"을 반환합니다.

### 3. 소수의 근사 동등성

```vb
# NearlyEqual은 0.1+0.2, expected=0.3, tolerance=0.000001을 받습니다. 음수 허용 오차는 거부합니다. Abs는 차이의 크기를 구하고 <=는 허용 범위 내 편차를 허용합니다. Main은 1을 반환합니다. 모든 보조 함수 인수를 명시합니다.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**매개변수 및 실행 설명:**

NearlyEqual은 0.1+0.2, expected=0.3, tolerance=0.000001을 받습니다. 음수 허용 오차는 거부합니다. Abs는 차이의 크기를 구하고 <=는 허용 범위 내 편차를 허용합니다. Main은 1을 반환합니다. 모든 보조 함수 인수를 명시합니다.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
