# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Declare пов’язує ім’я процедури Basic з експортованою функцією нативної DLL Windows x64. Описані можливості працюють у скомпільованому клієнті без генерації коду під час виконання; це не повний механізм взаємодії VB.NET.

## Точний синтаксис

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Параметри

- `name / Public / Private` — Локальне ім’я без урахування регістру, виклик без UO. Оголошення на рівні файла або Module, без тіла та End Function/End Sub. Типово Public; Private дозволено в Module. Не можна перекривати вбудовані Basic/UO-команди: використайте інше ім’я та Alias.
- `Lib / library.dll` — Обов’язкове ім’я або шлях .dll. Просте системне ім’я спочатку шукається в System32; інший відносний шлях — від файла оголошення, зокрема Include. Абсолютний шлях дозволено. Поточний каталог процесу та PATH не переглядаються. Залежності DLL шукаються поряд із нею або в System32.
- `Alias / export` — Необов’язкове точне ім’я експорту з урахуванням регістру; типово просте локальне ім’я. Експорт за номером не підтримується. Потрібна нативна Windows x64 DLL з відповідною сигнатурою, а не керований метод .NET.
- `Ansi / Unicode / Auto` — Типово Ansi: копія в ANSI-кодуванні Windows, де деякі символи можуть втрачатися. Unicode передає UTF-16. Обидва використовують точне ім’я. Auto передає UTF-16, перевіряє точне ім’я, потім додає W. Реальне кодування експорту не визначається автоматично: для Unicode API краще явно вказати Unicode та експорт із W.
- `ByVal arg As Type` — Від нуля до чотирьох параметрів із явними ByVal та As Integer, Double, Boolean або String. Integer — знакові 32 біти; Double — 64 біти; Boolean — 32-бітний Windows BOOL, не C/C++ bool. String — тимчасова вхідна копія із завершальним NUL, до 1048576 одиниць UTF-16, без NUL усередині. DLL не може зберігати вказівник чи писати в буфер. Іменовані аргументи використовують локальні імена. ByRef, Optional, ParamArray, масиви, структури та вказівники не підтримуються.
- `As ResultType / Sub` — Function вимагає As Integer, Double або Boolean. Sub без As повертає Unit. Аргументи Integer/Boolean мають бути Integer; Double також приймає Integer. За потреби явно використайте CInt/CDbl/CStr. Повернення рядка, вказівника чи 64-бітного цілого потребує окремого нативного адаптера з підтримуваною сигнатурою.

## Повертає

Integer повертає знакове 32-бітне число зі значенням, визначеним DLL, не обов’язково ознаку успіху. Double — 64-бітне дробове значення. As Boolean перетворює нуль на 0/False, будь-який ненульовий BOOL — на 1/True: для цих нормалізованих прапорців перевірки через 1/0 та True/False рівнозначні. Sub не повертає значення (Unit). Приклади: 1, "3:8", "missing export:1".

## Поведінка

- Непідтримувані оголошення відхиляються до запуску з SC031. Межі: 256 оголошень, 64 завантажені бібліотеки на кореневий скрипт. Аналіз та підказки не завантажують DLL. Реальна сигнатура експорту невідома движку; неправильне оголошення може аварійно завершити клієнт.
- Перший виклик завантажує DLL, наступні повторно використовують бібліотеку й адресу. Аргументи обчислюються один раз у порядку запису, потім переставляються за іменами. Помилки завантаження, архітектури, експорту й перетворення можна перехопити Try/Catch; порушення нативної пам’яті не є звичайною помилкою скрипта.
- Тимчасові рядки звільняються після виклику, включно з помилками перетворення. Бібліотеки звільняються після завершення, помилки чи скасування кореневого скрипта. Закриття IDE саме по собі не зупиняє скрипт і не звільняє його бібліотеки.
- Виклик синхронний у потоці скрипта. Пауза й зупинка перевіряються до та після виклику; DLL, що не повертає керування, не можна перервати движком. Використовуйте короткі операції та Basic Wait для очікування. Керовані DLL, зворотні виклики в Basic, змінна кількість аргументів і довільні API з вказівниками не підтримуються.

## Приклади

### 1. ID процесу клієнта

```vb
# ClientProcessId викликає GetCurrentProcessId у kernel32.dll без параметрів. Main зберігає числовий Windows ID у processId. Порівняння processId > 0 повертає 1/True; сам ID не є Boolean або серійним номером UO.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Пояснення параметрів і виконання:**

ClientProcessId викликає GetCurrentProcessId у kernel32.dll без параметрів. Main зберігає числовий Windows ID у processId. Порівняння processId > 0 повертає 1/True; сам ID не є Boolean або серійним номером UO.

### 2. Текст, степінь та іменовані аргументи

```vb
# TextLength(text) передає UTF-16 до lstrlenW і повертає довжину. Power(value, exponent) викликає pow з двома Double. Describe("ore", 2, 3) приймає три аргументи, записує іменовані параметри Power у зворотному порядку та повертає "3:8". Усі допоміжні функції наведено повністю.
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

**Пояснення параметрів і виконання:**

TextLength(text) передає UTF-16 до lstrlenW і повертає довжину. Power(value, exponent) викликає pow з двома Double. Describe("ore", 2, 3) приймає три аргументи, записує іменовані параметри Power у зворотному порядку та повертає "3:8". Усі допоміжні функції наведено повністю.

### 3. Відсутній експорт

```vb
# NativeDemo.MissingExport навмисно вказує відсутній експорт. TryRead перехоплює помилку, встановлює status="missing export", а Finally — finished=1. Main повертає "missing export:1". Private приховує оголошення в модулі. Це звичайна обробка помилки; Finally не гарантує виконання скриптового очищення після аварійного скасування.
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

**Пояснення параметрів і виконання:**

NativeDemo.MissingExport навмисно вказує відсутній експорт. TryRead перехоплює помилку, встановлює status="missing export", а Finally — finished=1. Main повертає "missing export:1". Private приховує оголошення в модулі. Це звичайна обробка помилки; Finally не гарантує виконання скриптового очищення після аварійного скасування.


### Внутрішні функції: від виклику до результату

Declare пов’язує ім’я процедури Basic з експортованою функцією нативної DLL Windows x64. Описані можливості працюють у скомпільованому клієнті без генерації коду під час виконання; це не повний механізм взаємодії VB.NET.

#### 1. ExternalDeclaration

Непідтримувані оголошення відхиляються до запуску з SC031. Межі: 256 оголошень, 64 завантажені бібліотеки на кореневий скрипт. Аналіз та підказки не завантажують DLL. Реальна сигнатура експорту невідома движку; неправильне оголошення може аварійно завершити клієнт.

`source -> typed declaration -> SC031 on unsupported ABI`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; функція `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Обов’язкове ім’я або шлях .dll. Просте системне ім’я спочатку шукається в System32; інший відносний шлях — від файла оголошення, зокрема Include. Абсолютний шлях дозволено. Поточний каталог процесу та PATH не переглядаються. Залежності DLL шукаються поряд із нею або в System32.

`first call -> absolute DLL path -> cached library -> exact export`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; функція `LibraryPath / GetCallable`.

#### 3. Invoke

Від нуля до чотирьох параметрів із явними ByVal та As Integer, Double, Boolean або String. Integer — знакові 32 біти; Double — 64 біти; Boolean — 32-бітний Windows BOOL, не C/C++ bool. String — тимчасова вхідна копія із завершальним NUL, до 1048576 одиниць UTF-16, без NUL усередині. DLL не може зберігати вказівник чи писати в буфер. Іменовані аргументи використовують локальні імена. ByRef, Optional, ParamArray, масиви, структури та вказівники не підтримуються.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; функція `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function вимагає As Integer, Double або Boolean. Sub без As повертає Unit. Аргументи Integer/Boolean мають бути Integer; Double також приймає Integer. За потреби явно використайте CInt/CDbl/CStr. Повернення рядка, вказівника чи 64-бітного цілого потребує окремого нативного адаптера з підтримуваною сигнатурою.

`Windows x64 argument slots -> native call -> declared result`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; функція `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Тимчасові рядки звільняються після виклику, включно з помилками перетворення. Бібліотеки звільняються після завершення, помилки чи скасування кореневого скрипта. Закриття IDE саме по собі не зупиняє скрипт і не звільняє його бібліотеки.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; функція `Dispose`.

Integer повертає знакове 32-бітне число зі значенням, визначеним DLL, не обов’язково ознаку успіху. Double — 64-бітне дробове значення. As Boolean перетворює нуль на 0/False, будь-який ненульовий BOOL — на 1/True: для цих нормалізованих прапорців перевірки через 1/0 та True/False рівнозначні. Sub не повертає значення (Unit). Приклади: 1, "3:8", "missing export:1".

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
