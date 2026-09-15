# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Declare connects a Basic procedure name to an exported function in a native Windows x64 DLL. The supported subset works in the compiled client without generating code at runtime. It is not a complete VB.NET interop layer.

## Exact syntax

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Parameters

- `name / Public / Private` — The local name is case-insensitive and is called without UO. Declare belongs at file or Module scope, has no body and no End Function/End Sub. Public is the default; Private is available inside Module. A declaration cannot replace a built-in Basic or UO command; use a different local name and Alias.
- `Lib / library.dll` — Required .dll filename or path. A bare system filename resolves in System32 first; otherwise a relative path is based on the file containing the declaration, including an Include file. Absolute paths are accepted. The process working directory and PATH are not searched. Native dependencies may be beside that DLL or in System32.
- `Alias / export` — Optional exact, case-sensitive exported name; by default the simple local name is used. Numeric ordinals are unsupported. The DLL must export a native Windows x64 function with exactly the declared signature, not a managed .NET method.
- `Ansi / Unicode / Auto` — Ansi is the default and copies input text in the Windows ANSI encoding; unrepresentable characters can be lost. Unicode uses UTF-16. Both use the exact export name. Auto uses UTF-16, tries the exact name first, then appends W. Auto cannot infer an export’s actual encoding: prefer Unicode with an explicit W export for Unicode APIs.
- `ByVal arg As Type` — Zero to four parameters, each explicitly ByVal and As Integer, Double, Boolean or String. Integer is signed 32-bit; Double is 64-bit; Boolean is a 32-bit Windows BOOL, not C/C++ bool. String is an input-only temporary NUL-terminated copy, at most 1048576 UTF-16 units, with no embedded NUL. The DLL must neither retain its pointer nor write into it. Named arguments use local parameter names. ByRef, Optional, ParamArray, arrays, structures and pointers are unsupported.
- `As ResultType / Sub` — Function requires As Integer, Double or Boolean. Sub has no As clause and produces Unit. Integer/Boolean inputs must already be Integer values; Double also accepts Integer. Convert deliberately with CInt/CDbl/CStr when needed. Returned strings, pointers and 64-bit integers are unsupported; use a native wrapper with the supported signature.

## Returns

Integer returns a signed 32-bit number; its meaning comes from the native function and is not automatically success/failure. Double returns a 64-bit floating-point value. As Boolean converts native zero to 0/False and any nonzero BOOL to 1/True; comparisons with 1/0 or True/False are equivalent only for these normalized flags. Sub returns no value (Unit). Examples return 1, "3:8", and "missing export:1".

## Behavior

- Unsupported declarations are rejected before execution with SC031. There are at most 256 declarations and 64 loaded libraries per root script. Parsing, validation and IDE completion do not load DLLs. The native library’s actual signature cannot be inferred from Declare: a wrong declaration can crash the client.
- The first call resolves and loads the DLL; later calls in that script reuse the library and export address. Argument expressions are evaluated once in source order, then named arguments are reordered. Load, architecture, missing-export and argument-conversion errors can be caught with Try/Catch. A native memory violation is not a normal recoverable script error.
- Temporary strings are freed after each call, including conversion failures. All library handles are released after the root script exits, fails or is cancelled. Closing the IDE alone keeps the running script and its libraries alive.
- Calls are synchronous on the script worker. Pause and stop are checked before and after a native call; a native function that never returns cannot be interrupted by the script engine. Use short native operations and Basic Wait for cooperative waiting. This interface does not run managed DLLs, callbacks into Basic, variadic exports or arbitrary pointer-based APIs.

## Examples

### 1. Read the client process ID

```vb
# ClientProcessId maps to GetCurrentProcessId in kernel32.dll and has no parameters. Main stores the numeric Windows process ID in processId. The comparison processId > 0 returns 1/True; the ID itself is not Boolean and is not a UO serial.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Parameter and execution notes:**

ClientProcessId maps to GetCurrentProcessId in kernel32.dll and has no parameters. Main stores the numeric Windows process ID in processId. The comparison processId > 0 returns 1/True; the ID itself is not Boolean and is not a UO serial.

### 2. Text, floating point and named arguments

```vb
# TextLength(text) passes input text as UTF-16 to lstrlenW and returns its length. Power(value, exponent) maps to pow and uses two Double parameters. Describe("ore", 2, 3) receives all three arguments, calls Power with named parameters in reversed writing order, and returns the string "3:8". Every helper is shown; there is no hidden script dependency.
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

**Parameter and execution notes:**

TextLength(text) passes input text as UTF-16 to lstrlenW and returns its length. Power(value, exponent) maps to pow and uses two Double parameters. Describe("ore", 2, 3) receives all three arguments, calls Power with named parameters in reversed writing order, and returns the string "3:8". Every helper is shown; there is no hidden script dependency.

### 3. A missing export and cleanup

```vb
# NativeDemo.MissingExport intentionally names a nonexistent export. TryRead catches the lookup error, sets status to "missing export", and Finally sets finished to 1. Main returns "missing export:1". Private keeps the DLL declaration inside its module; the public helper provides the documented result. Finally here is normal error handling, not a promise to execute script cleanup after emergency cancellation.
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

**Parameter and execution notes:**

NativeDemo.MissingExport intentionally names a nonexistent export. TryRead catches the lookup error, sets status to "missing export", and Finally sets finished to 1. Main returns "missing export:1". Private keeps the DLL declaration inside its module; the public helper provides the documented result. Finally here is normal error handling, not a promise to execute script cleanup after emergency cancellation.


### Internal functions: from call to result

Declare connects a Basic procedure name to an exported function in a native Windows x64 DLL. The supported subset works in the compiled client without generating code at runtime. It is not a complete VB.NET interop layer.

#### 1. ExternalDeclaration

Unsupported declarations are rejected before execution with SC031. There are at most 256 declarations and 64 loaded libraries per root script. Parsing, validation and IDE completion do not load DLLs. The native library’s actual signature cannot be inferred from Declare: a wrong declaration can crash the client.

`source -> typed declaration -> SC031 on unsupported ABI`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; function `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Required .dll filename or path. A bare system filename resolves in System32 first; otherwise a relative path is based on the file containing the declaration, including an Include file. Absolute paths are accepted. The process working directory and PATH are not searched. Native dependencies may be beside that DLL or in System32.

`first call -> absolute DLL path -> cached library -> exact export`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; function `LibraryPath / GetCallable`.

#### 3. Invoke

Zero to four parameters, each explicitly ByVal and As Integer, Double, Boolean or String. Integer is signed 32-bit; Double is 64-bit; Boolean is a 32-bit Windows BOOL, not C/C++ bool. String is an input-only temporary NUL-terminated copy, at most 1048576 UTF-16 units, with no embedded NUL. The DLL must neither retain its pointer nor write into it. Named arguments use local parameter names. ByRef, Optional, ParamArray, arrays, structures and pointers are unsupported.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; function `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function requires As Integer, Double or Boolean. Sub has no As clause and produces Unit. Integer/Boolean inputs must already be Integer values; Double also accepts Integer. Convert deliberately with CInt/CDbl/CStr when needed. Returned strings, pointers and 64-bit integers are unsupported; use a native wrapper with the supported signature.

`Windows x64 argument slots -> native call -> declared result`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; function `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Temporary strings are freed after each call, including conversion failures. All library handles are released after the root script exits, fails or is cancelled. Closing the IDE alone keeps the running script and its libraries alive.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; function `Dispose`.

Integer returns a signed 32-bit number; its meaning comes from the native function and is not automatically success/failure. Double returns a 64-bit floating-point value. As Boolean converts native zero to 0/False and any nonzero BOOL to 1/True; comparisons with 1/0 or True/False are equivalent only for these normalized flags. Sub returns no value (Unit). Examples return 1, "3:8", and "missing export:1".

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
