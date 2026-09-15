# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Declare связывает имя процедуры Basic с экспортируемой функцией нативной DLL Windows x64. Описанный набор работает в скомпилированном клиенте без генерации кода во время исполнения. Это ограниченный интерфейс DLL, а не вся совместимость VB.NET.

## Точный синтаксис

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Параметры

- `name / Public / Private` — Локальное имя без учёта регистра; вызывается без UO. Объявление размещается на уровне файла или Module, без тела и без End Function/End Sub. По умолчанию Public; Private разрешён внутри Module. Перекрывать встроенные Basic/UO-команды нельзя: выберите другое имя и укажите Alias.
- `Lib / library.dll` — Обязательное имя или путь к .dll. Простое системное имя сначала ищется в System32; прочий относительный путь отсчитывается от файла с объявлением, в том числе подключённого через Include. Допустим абсолютный путь. Текущая папка процесса и PATH не просматриваются. Зависимости DLL могут находиться рядом с ней либо в System32.
- `Alias / export` — Необязательное точное имя экспорта с учётом регистра; без Alias используется простое локальное имя. Экспорт по номеру не поддерживается. Нужна нативная DLL Windows x64 с точно соответствующей сигнатурой, а не управляемый метод .NET.
- `Ansi / Unicode / Auto` — По умолчанию Ansi: копия строки в ANSI-кодировке Windows; отсутствующие в ней символы могут теряться. Unicode передаёт UTF-16. Оба ищут точное имя экспорта. Auto передаёт UTF-16, сначала проверяет точное имя, затем добавляет W. Auto не определяет реальную кодировку функции: для Unicode API предпочтительны Unicode и явный экспорт с W.
- `ByVal arg As Type` — От нуля до четырёх параметров. Для каждого обязательны ByVal и As Integer, Double, Boolean либо String. Integer — 32 бита со знаком; Double — 64 бита; Boolean — 32-битный Windows BOOL, не C/C++ bool. String — временная строка только для чтения с завершающим NUL, до 1048576 единиц UTF-16 и без NUL внутри. DLL не должна сохранять указатель или писать в буфер. Именованные аргументы используют локальные имена параметров. ByRef, Optional, ParamArray, массивы, структуры и указатели не поддерживаются.
- `As ResultType / Sub` — Function требует As Integer, Double либо Boolean. У Sub нет As и результат Unit. Для Integer/Boolean аргумент должен уже быть Integer; Double принимает также Integer. При необходимости явно примените CInt/CDbl/CStr. Возврат строки, указателя и 64-битного целого не поддерживается; для таких API нужен нативный адаптер с поддерживаемой сигнатурой.

## Возвращает

Integer возвращает 32-битное число со знаком; его смысл задаёт нативная функция, это не обязательно успех/ошибка. Double возвращает дробное 64-битное значение. As Boolean преобразует нативный ноль в 0/False, любой ненулевой BOOL — в 1/True; сравнение с 1/0 и True/False равнозначно именно для таких нормализованных флагов. Sub ничего не возвращает (Unit). Результаты примеров: 1, "3:8", "missing export:1".

## Поведение

- Неподдерживаемое объявление отклоняется до выполнения с SC031. На корневой скрипт допускаются 256 объявлений и 64 загруженные библиотеки. Разбор, проверка и подсказки IDE не загружают DLL. Движок не может вывести реальную сигнатуру экспорта из Declare: неверное объявление способно аварийно завершить клиент.
- Первый вызов находит и загружает DLL; последующие вызовы этого скрипта используют сохранённые библиотеку и адрес экспорта. Выражения аргументов вычисляются один раз в порядке записи, затем именованные параметры переставляются. Ошибки загрузки, архитектуры, отсутствующего экспорта и преобразования аргументов перехватываются Try/Catch. Нарушение памяти внутри нативного кода не является обычной восстанавливаемой ошибкой скрипта.
- Временные строки освобождаются после каждого вызова, в том числе при ошибке преобразования. Все дескрипторы библиотек освобождаются при завершении корневого скрипта, ошибке или отмене. Простое закрытие IDE сохраняет работающий скрипт и его библиотеки.
- Вызов синхронный, в рабочем потоке скрипта. Пауза и остановка проверяются до и после нативного вызова; функцию DLL, которая не возвращает управление, движок прервать не может. Используйте короткие операции, а для ожидания — Basic Wait. Управляемые DLL, обратные вызовы в Basic, экспорты с переменным числом аргументов и произвольные API с указателями не поддерживаются.

## Примеры

### 1. Идентификатор процесса клиента

```vb
# ClientProcessId связан с GetCurrentProcessId из kernel32.dll и не принимает параметров. Main сохраняет числовой Windows ID процесса в processId. Сравнение processId > 0 возвращает 1/True; сам ID не является Boolean и не является серийным номером UO.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Разбор параметров и выполнения:**

ClientProcessId связан с GetCurrentProcessId из kernel32.dll и не принимает параметров. Main сохраняет числовой Windows ID процесса в processId. Сравнение processId > 0 возвращает 1/True; сам ID не является Boolean и не является серийным номером UO.

### 2. Строка, степень и именованные аргументы

```vb
# TextLength(text) передаёт текст в UTF-16 функции lstrlenW и возвращает его длину. Power(value, exponent) вызывает pow с двумя Double-параметрами. Describe("ore", 2, 3) получает все три аргумента, вызывает Power с именами параметров в обратном порядке записи и возвращает строку "3:8". Все вспомогательные функции показаны полностью.
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

**Разбор параметров и выполнения:**

TextLength(text) передаёт текст в UTF-16 функции lstrlenW и возвращает его длину. Power(value, exponent) вызывает pow с двумя Double-параметрами. Describe("ore", 2, 3) получает все три аргумента, вызывает Power с именами параметров в обратном порядке записи и возвращает строку "3:8". Все вспомогательные функции показаны полностью.

### 3. Отсутствующий экспорт и завершение блока

```vb
# NativeDemo.MissingExport специально указывает несуществующий экспорт. TryRead перехватывает ошибку поиска, записывает "missing export", а Finally устанавливает finished=1. Main возвращает "missing export:1". Private оставляет объявление DLL внутри модуля; публичная функция предоставляет понятный результат. Здесь Finally относится к обычной обработке ошибки, а не гарантирует выполнение скриптовой очистки после аварийной отмены.
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

**Разбор параметров и выполнения:**

NativeDemo.MissingExport специально указывает несуществующий экспорт. TryRead перехватывает ошибку поиска, записывает "missing export", а Finally устанавливает finished=1. Main возвращает "missing export:1". Private оставляет объявление DLL внутри модуля; публичная функция предоставляет понятный результат. Здесь Finally относится к обычной обработке ошибки, а не гарантирует выполнение скриптовой очистки после аварийной отмены.


### Внутренние функции: от вызова до результата

Declare связывает имя процедуры Basic с экспортируемой функцией нативной DLL Windows x64. Описанный набор работает в скомпилированном клиенте без генерации кода во время исполнения. Это ограниченный интерфейс DLL, а не вся совместимость VB.NET.

#### 1. ExternalDeclaration

Неподдерживаемое объявление отклоняется до выполнения с SC031. На корневой скрипт допускаются 256 объявлений и 64 загруженные библиотеки. Разбор, проверка и подсказки IDE не загружают DLL. Движок не может вывести реальную сигнатуру экспорта из Declare: неверное объявление способно аварийно завершить клиент.

`source -> typed declaration -> SC031 on unsupported ABI`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; функция `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Обязательное имя или путь к .dll. Простое системное имя сначала ищется в System32; прочий относительный путь отсчитывается от файла с объявлением, в том числе подключённого через Include. Допустим абсолютный путь. Текущая папка процесса и PATH не просматриваются. Зависимости DLL могут находиться рядом с ней либо в System32.

`first call -> absolute DLL path -> cached library -> exact export`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; функция `LibraryPath / GetCallable`.

#### 3. Invoke

От нуля до четырёх параметров. Для каждого обязательны ByVal и As Integer, Double, Boolean либо String. Integer — 32 бита со знаком; Double — 64 бита; Boolean — 32-битный Windows BOOL, не C/C++ bool. String — временная строка только для чтения с завершающим NUL, до 1048576 единиц UTF-16 и без NUL внутри. DLL не должна сохранять указатель или писать в буфер. Именованные аргументы используют локальные имена параметров. ByRef, Optional, ParamArray, массивы, структуры и указатели не поддерживаются.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; функция `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function требует As Integer, Double либо Boolean. У Sub нет As и результат Unit. Для Integer/Boolean аргумент должен уже быть Integer; Double принимает также Integer. При необходимости явно примените CInt/CDbl/CStr. Возврат строки, указателя и 64-битного целого не поддерживается; для таких API нужен нативный адаптер с поддерживаемой сигнатурой.

`Windows x64 argument slots -> native call -> declared result`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; функция `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Временные строки освобождаются после каждого вызова, в том числе при ошибке преобразования. Все дескрипторы библиотек освобождаются при завершении корневого скрипта, ошибке или отмене. Простое закрытие IDE сохраняет работающий скрипт и его библиотеки.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; функция `Dispose`.

Integer возвращает 32-битное число со знаком; его смысл задаёт нативная функция, это не обязательно успех/ошибка. Double возвращает дробное 64-битное значение. As Boolean преобразует нативный ноль в 0/False, любой ненулевой BOOL — в 1/True; сравнение с 1/0 и True/False равнозначно именно для таких нормализованных флагов. Sub ничего не возвращает (Unit). Результаты примеров: 1, "3:8", "missing export:1".

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
