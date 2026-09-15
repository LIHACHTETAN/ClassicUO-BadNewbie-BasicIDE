# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

AS는 스칼라 변수의 변환 규칙을 지정합니다. 내부 값 종류는 Integer, Decimal, String, Array, Object, Unit(값 없음)입니다. Boolean은 Integer 1/0을 사용합니다. 이 Basic의 별칭은 VB.NET에서 같은 이름을 쓰는 형식의 저장 크기를 보장하지 않습니다.

## 정확한 구문

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## 매개변수

- `name` — 선언할 변수 이름입니다. 읽으면 현재 값을 얻으며 이후의 모든 대입에도 AS 변환을 다시 적용합니다.
- `type` — Integer, Long, Short, Byte: 부호 있는 32비트 정수, 범위 -2147483648…2147483647입니다. Short와 Byte는 범위를 줄이지 않습니다. Double, Single, Decimal: 내부 이름이 Decimal인 64비트 이진 부동소수점이며 정확한 십진 연산이 아닙니다. String: 문자열. Boolean, Bool: Integer 1/0. Variant, Object: 입력 값 종류를 유지하며 반드시 객체 인스턴스일 필요는 없습니다. 형식 이름의 대소문자는 구분하지 않습니다.
- `value` — 선택적 초기값으로 숫자, 문자열, 변수 또는 함수 결과를 지정합니다. AS는 선언 구문입니다. 식에서 명시적으로 변환하려면 CInt(value), CDbl(value), CStr(value), CBool(value)를 사용합니다.

## 반환값

AS 자체는 값을 반환하지 않습니다. 변수를 읽으면 저장된 종류와 값을 반환합니다. 논리 숫자는 TRUE=1, FALSE=0입니다. 개수 2는 0이 아니지만 2=TRUE는 거짓입니다. 아이템 존재 여부는 count<>0 또는 CBool(count)로 확인합니다.

## 동작

- 초기값이 없는 형식 지정 VAR는 정수/Boolean에 0, Double/Single/Decimal에 부동소수점 0, String에 빈 문자열을 줍니다. 형식 없는 VAR 및 VAR AS Variant/Object는 Unit입니다. 스칼라 DIM은 String에 빈 문자열, 나머지에 0을 초기값으로 넣습니다. Unit은 AS를 통해 대입해도 Unit입니다.
- AS Integer는 범위 안의 소수 부분을 0 방향으로 버립니다. CInt/CLng는 반올림하며 정확히 절반이면 0에서 멀어집니다. 2.6은 CInt에서 3이지만 AS Integer에서는 2입니다. 정수 문자열 전체는 십진 정수 또는 0x 16진수여야 하므로 "2.6"은 유효하지 않습니다. 변환 전에 범위를 확인하세요.
- AS Boolean은 원래 값을 숫자 0과 비교합니다. 0이 아닌 숫자는 1, 0은 0입니다. 단어를 해석하지 않으므로 문자열 "false"도 1이 됩니다. CBool은 먼저 숫자로 변환합니다. 숫자/논리 값을 사용하거나 문자열을 예상 단어와 명시적으로 비교하세요.
- AS String은 엔진의 문자열 표현을 사용합니다. AS Double/Single/Decimal은 소수점이 있는 숫자 문자열을 해석합니다. 숫자 AS는 Array를 0으로 바꾸지만 Object와 잘못된 숫자 문자열에는 TRY/CATCH로 처리할 수 있는 오류를 냅니다. 반면 CInt/CLng/CDbl/CSng/CBool은 느슨하게 읽어 인식할 수 없는 문자열, Array, Object, Unit을 먼저 0으로 처리합니다. 문자열 변환을 믿기 전에 IsNumeric(value)를 확인하세요.
- 선언은 초기식을 계산하고 AS 변환을 적용한 뒤 결과와 형식 이름을 저장합니다. 이후 대입마다 변환을 반복합니다. 부동소수점은 근삿값이며 정확한 십진 금액 계산을 보장하지 않습니다. 범위는 VAR / DIM, 이름 보호는 CONST를 참조하세요.
- As 뒤에는 선언된 Structure 이름도 지원합니다. 초기화 식이 없는 해당 형식의 VAR와 DIM은 기본 필드 값을 만듭니다. 동일한 선언 형식만 호환되며 서로 다른 구조 형식 간 변환은 없습니다. 중첩 복사와 참조 필드는 Structure / New를 참조하세요.

## 예제

### 1. 대입 변환과 반올림

```vb
# source=2.6은 부동소수점입니다. whole AS Integer는 2를 저장하고 CInt(source)는 rounded에 3을 반환합니다. Main은 2*10+3=23을 반환하여 두 변환을 함께 확인합니다.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**매개변수 및 실행 설명:**

source=2.6은 부동소수점입니다. whole AS Integer는 2를 저장하고 CInt(source)는 rounded에 3을 반환합니다. Main은 2*10+3=23을 반환하여 두 변환을 함께 확인합니다.

### 2. 개수와 논리 값의 차이

```vb
# count=2는 아이템 개수입니다. hasItems AS Boolean은 1이 됩니다. TRUE는 정확히 1이므로 count=TRUE는 거짓이고 count<>0은 참입니다. Main의 hasItems=1은 아이템이 있다는 뜻이지 개수가 하나라는 뜻은 아닙니다.
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**매개변수 및 실행 설명:**

count=2는 아이템 개수입니다. hasItems AS Boolean은 1이 됩니다. TRUE는 정확히 1이므로 count=TRUE는 거짓이고 count<>0은 참입니다. Main의 hasItems=1은 아이템이 있다는 뜻이지 개수가 하나라는 뜻은 아닙니다.

### 3. Variant는 값 종류를 유지

```vb
# value AS Variant는 처음 Integer 7, 다음 String "ore"를 저장합니다. text AS String은 비어 있는 상태로 시작합니다. CStr(12)는 문자열 "12"를 만들고 문자열을 연결하면 Main이 반환할 "ore12"가 됩니다. Variant는 값 종류 변경을 허용합니다.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**매개변수 및 실행 설명:**

value AS Variant는 처음 Integer 7, 다음 String "ore"를 저장합니다. text AS String은 비어 있는 상태로 시작합니다. CStr(12)는 문자열 "12"를 만들고 문자열을 연결하면 Main이 반환할 "ore12"가 됩니다. Variant는 값 종류 변경을 허용합니다.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
