# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Declare는 Basic 프로시저 이름을 네이티브 Windows x64 DLL의 내보낸 함수에 연결합니다. 아래 범위는 실행 중 코드 생성 없이 컴파일된 클라이언트에서도 동작하며, VB.NET 상호 운용 전체를 뜻하지 않습니다.

## 정확한 구문

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## 매개변수

- `name / Public / Private` — 로컬 이름은 대소문자를 구분하지 않고 UO. 없이 호출합니다. 파일 또는 Module 수준에 선언하며 본문과 End Function/End Sub가 없습니다. 기본 Public, Module 안에서는 Private을 사용할 수 있습니다. 기존 Basic/UO 이름을 덮어쓸 수 없으므로 다른 이름과 Alias를 사용하세요.
- `Lib / library.dll` — 필수 .dll 이름 또는 경로입니다. 단순 시스템 이름은 System32에서 먼저 찾고, 다른 상대 경로는 Include를 포함해 선언 파일을 기준으로 합니다. 절대 경로도 허용합니다. 현재 작업 폴더나 PATH는 검색하지 않습니다. 종속 DLL은 해당 DLL 옆이나 System32에 둘 수 있습니다.
- `Alias / export` — 선택적인 정확한 내보내기 이름으로 대소문자를 구분합니다. 생략하면 단순 로컬 이름을 사용합니다. 순번 내보내기는 지원하지 않습니다. 선언과 정확히 맞는 네이티브 Windows x64 함수가 필요하며 관리형 .NET 메서드는 아닙니다.
- `Ansi / Unicode / Auto` — 기본 Ansi는 Windows ANSI로 문자열을 복사해 표현 불가능한 문자가 손실될 수 있습니다. Unicode는 UTF-16입니다. 두 방식 모두 정확한 이름을 찾습니다. Auto는 UTF-16으로 정확한 이름부터 찾고 이어 W를 붙입니다. 실제 함수 인코딩을 알아내지는 못하므로 Unicode API는 Unicode와 명시적인 W 이름을 권장합니다.
- `ByVal arg As Type` — 매개변수는 0~4개로 각 항목에 ByVal과 As Integer, Double, Boolean 또는 String이 필요합니다. Integer는 부호 있는32비트, Double은64비트, Boolean은32비트 Windows BOOL이며 C/C++ bool이 아닙니다. String은 읽기 전용 임시 NUL 종료 입력 복사본으로 최대1048576 UTF-16단위이며 내부NUL은 금지됩니다. DLL은 포인터를 저장하거나 버퍼에 쓰면 안 됩니다. 명명된 인수는 로컬 매개변수 이름을 사용합니다. ByRef, Optional, ParamArray, 배열, 구조체, 포인터는 지원하지 않습니다.
- `As ResultType / Sub` — Function은 As Integer, Double 또는 Boolean이 필수입니다. Sub는 As 없이 Unit을 반환합니다. Integer/Boolean 인수는 Integer 값이어야 하며 Double은 Integer도 받습니다. 필요하면 CInt/CDbl/CStr로 명시 변환하세요. 문자열, 포인터,64비트 정수 반환은 지원되는 서명의 네이티브 래퍼가 필요합니다.

## 반환값

Integer는 네이티브 함수가 의미를 정하는 부호 있는32비트 숫자로, 반드시 성공 여부는 아닙니다. Double은64비트 실수입니다. As Boolean은0을0/False, 다른BOOL을1/True로 정규화합니다. 이러한 플래그에서는1/0과True/False 비교가 같습니다. Sub는 값이 없습니다(Unit). 예제 결과는1, "3:8", "missing export:1"입니다.

## 동작

- 지원하지 않는 선언은 실행 전에 SC031로 거부합니다. 루트 스크립트당 선언256개, 로드된 DLL64개까지입니다. 분석과IDE완성은DLL을 로드하지 않습니다. 실제 네이티브 서명을 알 수 없으므로 잘못 선언하면 클라이언트가 충돌할 수 있습니다.
- 첫 호출은DLL을 로드하고 이후에는 라이브러리와 주소를 재사용합니다. 인수는 작성 순서대로 한 번 평가한 뒤 이름에 맞게 재배치합니다. 로드, 아키텍처, 내보내기, 변환 오류는Try/Catch로 처리할 수 있지만 네이티브 메모리 위반은 일반적인 복구 가능 스크립트 오류가 아닙니다.
- 변환 오류를 포함해 호출이 끝나면 임시 문자열을 해제합니다. 루트 스크립트 완료·실패·취소 시 라이브러리를 해제합니다. IDE만 닫으면 실행 중인 스크립트와DLL은 유지됩니다.
- 스크립트 워커에서 동기 호출합니다. 일시정지와 중지는 호출 전후에 검사하며, 돌아오지 않는 네이티브 함수를 엔진이 중단할 수는 없습니다. 짧은 작업을 사용하고 기다릴 때는Basic Wait를 사용하세요. 관리형 DLL, Basic 콜백, 가변 인수 내보내기, 임의 포인터API는 지원하지 않습니다.

## 예제

### 1. 클라이언트 프로세스ID

```vb
# ClientProcessId는kernel32.dll의GetCurrentProcessId를 인수 없이 호출합니다. Main은 Windows 숫자ID를processId에 저장하고 processId > 0 비교로1/True를 반환합니다. ID 자체는Boolean이나UO시리얼이 아닙니다.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**매개변수 및 실행 설명:**

ClientProcessId는kernel32.dll의GetCurrentProcessId를 인수 없이 호출합니다. Main은 Windows 숫자ID를processId에 저장하고 processId > 0 비교로1/True를 반환합니다. ID 자체는Boolean이나UO시리얼이 아닙니다.

### 2. 문자열, 거듭제곱, 이름 인수

```vb
# TextLength(text)는UTF-16을lstrlenW에 전달해 길이를 반환합니다. Power(value, exponent)는두Double로pow를 호출합니다. Describe("ore", 2, 3)는세인수를 받고 Power의 이름 인수를 반대 순서로 작성하여"3:8"을 반환합니다. 보조 함수도 모두 제시합니다.
Option Explicit On
Declare Unicode Function TextLength Lib "kernel32.dll" Alias "lstrlenW"(ByVal text As String) As Integer
Declare Function Power Lib "ucrtbase.dll" Alias "pow"(ByVal value As Double, ByVal exponent As Double) As Double

Function Describe(ByVal text As String, ByVal value As Double, ByVal exponent As Double) As String
    Dim length = TextLength(text:=text)
    Dim powered = Power(exponent:=exponent, value:=value)
    Return CStr(length) & ":" & CStr(powered)
End Function

Sub Main()
    Return Describe("ore", 2, 3)
End Sub
```

**매개변수 및 실행 설명:**

TextLength(text)는UTF-16을lstrlenW에 전달해 길이를 반환합니다. Power(value, exponent)는두Double로pow를 호출합니다. Describe("ore", 2, 3)는세인수를 받고 Power의 이름 인수를 반대 순서로 작성하여"3:8"을 반환합니다. 보조 함수도 모두 제시합니다.

### 3. 없는 내보내기

```vb
# NativeDemo.MissingExport는 일부러 없는 이름입니다. TryRead가 오류를 잡아 status="missing export", Finally가 finished=1로 설정하고 Main은 "missing export:1"을 반환합니다. Private는 선언을 모듈 안으로 제한합니다. 일반 오류 처리 예이며 긴급 취소 뒤 스크립트 정리가 실행된다는 보장은 아닙니다.
Option Explicit On
Module NativeDemo
    Private Declare Function MissingExport Lib "kernel32.dll" Alias "BasicManualMissingExport_71cf"() As Integer
    Public Function TryRead() As String
        Dim status = "unexpected export"
        Dim finished = 0
        Try
            MissingExport()
        Catch problem
            status = "missing export"
        Finally
            finished = 1
        End Try
        Return status & ":" & CStr(finished)
    End Function
End Module

Sub Main()
    Return NativeDemo.TryRead()
End Sub
```

**매개변수 및 실행 설명:**

NativeDemo.MissingExport는 일부러 없는 이름입니다. TryRead가 오류를 잡아 status="missing export", Finally가 finished=1로 설정하고 Main은 "missing export:1"을 반환합니다. Private는 선언을 모듈 안으로 제한합니다. 일반 오류 처리 예이며 긴급 취소 뒤 스크립트 정리가 실행된다는 보장은 아닙니다.


### 내부 함수: 호출부터 결과까지

Declare는 Basic 프로시저 이름을 네이티브 Windows x64 DLL의 내보낸 함수에 연결합니다. 아래 범위는 실행 중 코드 생성 없이 컴파일된 클라이언트에서도 동작하며, VB.NET 상호 운용 전체를 뜻하지 않습니다.

#### 1. ExternalDeclaration

지원하지 않는 선언은 실행 전에 SC031로 거부합니다. 루트 스크립트당 선언256개, 로드된 DLL64개까지입니다. 분석과IDE완성은DLL을 로드하지 않습니다. 실제 네이티브 서명을 알 수 없으므로 잘못 선언하면 클라이언트가 충돌할 수 있습니다.

`source -> typed declaration -> SC031 on unsupported ABI`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; 함수 `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

필수 .dll 이름 또는 경로입니다. 단순 시스템 이름은 System32에서 먼저 찾고, 다른 상대 경로는 Include를 포함해 선언 파일을 기준으로 합니다. 절대 경로도 허용합니다. 현재 작업 폴더나 PATH는 검색하지 않습니다. 종속 DLL은 해당 DLL 옆이나 System32에 둘 수 있습니다.

`first call -> absolute DLL path -> cached library -> exact export`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 함수 `LibraryPath / GetCallable`.

#### 3. Invoke

매개변수는 0~4개로 각 항목에 ByVal과 As Integer, Double, Boolean 또는 String이 필요합니다. Integer는 부호 있는32비트, Double은64비트, Boolean은32비트 Windows BOOL이며 C/C++ bool이 아닙니다. String은 읽기 전용 임시 NUL 종료 입력 복사본으로 최대1048576 UTF-16단위이며 내부NUL은 금지됩니다. DLL은 포인터를 저장하거나 버퍼에 쓰면 안 됩니다. 명명된 인수는 로컬 매개변수 이름을 사용합니다. ByRef, Optional, ParamArray, 배열, 구조체, 포인터는 지원하지 않습니다.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 함수 `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function은 As Integer, Double 또는 Boolean이 필수입니다. Sub는 As 없이 Unit을 반환합니다. Integer/Boolean 인수는 Integer 값이어야 하며 Double은 Integer도 받습니다. 필요하면 CInt/CDbl/CStr로 명시 변환하세요. 문자열, 포인터,64비트 정수 반환은 지원되는 서명의 네이티브 래퍼가 필요합니다.

`Windows x64 argument slots -> native call -> declared result`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; 함수 `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

변환 오류를 포함해 호출이 끝나면 임시 문자열을 해제합니다. 루트 스크립트 완료·실패·취소 시 라이브러리를 해제합니다. IDE만 닫으면 실행 중인 스크립트와DLL은 유지됩니다.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 함수 `Dispose`.

Integer는 네이티브 함수가 의미를 정하는 부호 있는32비트 숫자로, 반드시 성공 여부는 아닙니다. Double은64비트 실수입니다. As Boolean은0을0/False, 다른BOOL을1/True로 정규화합니다. 이러한 플래그에서는1/0과True/False 비교가 같습니다. Sub는 값이 없습니다(Unit). 예제 결과는1, "3:8", "missing export:1"입니다.

<!-- implementation references (not callable script procedures):
Runtime/ExternalDeclaration.cs: type and declaration validation
Analysis/ExternalDeclarationValidator.cs: SC031
Runtime/ExternalLibraries.cs: LibraryPath / GetCallable / Invoke / Dispose
Runtime/ExternalCallSites.cs: CallInteger / CallDouble / CallVoid
Runtime/Interpreter.cs: CallSubrutine / CallObserved
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/declare-statement
https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
-->
