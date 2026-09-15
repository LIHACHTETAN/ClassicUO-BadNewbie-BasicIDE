# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Windows.bas — редактируемый модуль Basic с шестью публичными функциями: информация о процессе, измерение коротких интервалов и размеры рабочего стола. Ниже приведены весь код и приватные Declare. Для запуска нужен не только Main, но и подключаемый файл.

## Точный синтаксис

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Параметры

- `Include / Windows.bas` — Include "Windows.bas" подключает Scripts/Include/Windows.bas. Для отдельной папки скриптов скопируйте библиотеку в её подпапку Include. Пакет примера содержит Main.bas и Include/Windows.bas. Вызовы идут через Windows., без UO.; это модуль скрипта, а не встроенное пространство API.
- `ProcessId()` — ProcessId() без параметров возвращает Integer: Windows ID текущего процесса клиента. Это не ID чара, предмета или соединения с сервером.
- `Milliseconds()` — Milliseconds() без параметров возвращает Double в диапазоне 0..4294967295: беззнаковое 32-битное значение GetTickCount. К отрицательному нативному результату добавляется 4294967296.0. Счётчик переполняется примерно раз в 49,7 дня; это не календарное время и не высокоточный таймер для бенчмарка.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) принимает ранее сохранённое Milliseconds() как Double и возвращает прошедшие миллисекунды Double. Вне диапазона 0..4294967295 — ошибка скрипта. При отрицательной разнице добавляется 4294967296.0, учитывая одно переполнение. Интервал должен быть меньше полного оборота счётчика. Функция сама не ждёт.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth() и ScreenHeight() без параметров возвращают Integer: размеры основного монитора по метрикам 0 и 1. Это координаты рабочего стола Windows с учётом DPI-контекста процесса, а не тайлы карты UO и не размер игрового окна.
- `DesktopBounds()` — DesktopBounds() без параметров возвращает новый Dictionary с ключами-строками X, Y, Width, Height и значениями Integer. Читайте через Item("X") и аналогично. Метрики 76–79 описывают прямоугольник всех мониторов; X/Y могут быть отрицательными. Изменение словаря не перемещает и не изменяет размеры окон.

## Возвращает

ProcessId/ScreenWidth/ScreenHeight возвращают числовые Integer. Milliseconds/ElapsedMilliseconds возвращают Double — количество миллисекунд, не флаги Boolean. DesktopBounds возвращает Object (Dictionary), а X/Y/Width/Height содержат Integer. Include и объявления ничего не возвращают. Main каждого примера возвращает 1/True после проверки данных; 0/False означает провал этой проверки, а не автоматическую логическую трактовку всех нативных результатов.

## Поведение

- Нужен клиент Windows x64. Приватные NativeTicks, NativeProcessId и NativeMetric реализованы тремя показанными Declare. Загрузка, ошибки и освобождение DLL описаны в Basic.Declare. Модуль не отправляет игровые пакеты, не меняет настройки и не передвигает персонажа.
- Функции читают текущие системные значения. У Milliseconds невысокая точность системного счётчика, обычно обновляемого раз в 10–16 мс. ElapsedMilliseconds не различает несколько оборотов и значения из другой сессии Windows. Используйте для коротких операций скрипта; точная длительность Wait не гарантируется.
- Копируйте Main.bas вместе с Include/Windows.bas. Исходник можно редактировать в IDE. Каждый DesktopBounds создаёт отдельный снимок Dictionary; изменения расположения мониторов или DPI могут повлиять на последующие результаты.

## Примеры

### 1. Процесс и счётчик

```vb
# Main подключает Windows.bas, вызывает ProcessId() без аргументов и сохраняет Milliseconds() в startedAt. ID должен быть положительным, значение счётчика — в 0..4294967295. AndAlso выполняет проверки с сокращённым вычислением; при корректных данных Main возвращает 1/True. Конкретные ID и время зависят от компьютера.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Разбор параметров и выполнения:**

Main подключает Windows.bas, вызывает ProcessId() без аргументов и сохраняет Milliseconds() в startedAt. ID должен быть положительным, значение счётчика — в 0..4294967295. AndAlso выполняет проверки с сокращённым вычислением; при корректных данных Main возвращает 1/True. Конкретные ID и время зависят от компьютера.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 2. Измерение ожидания

```vb
# MeasureWait(delayMilliseconds) отклоняет отрицательную задержку, сохраняет счётчик, выполняет Basic Wait(delayMilliseconds) и возвращает Windows.ElapsedMilliseconds(startMilliseconds:=startedAt). Main передаёт 15 и проверяет elapsed >= 0. Фактическое время зависит от системы и может превышать 15 мс. Ниже показаны все функции, включая обработку одного переполнения.
Option Explicit On
Include "Windows.bas"

Function MeasureWait(ByVal delayMilliseconds As Integer) As Double
    If delayMilliseconds < 0 Then
        Throw "delayMilliseconds must be non-negative"
    End If
    Dim startedAt = Windows.Milliseconds()
    Wait(delayMilliseconds)
    Return Windows.ElapsedMilliseconds(startMilliseconds:=startedAt)
End Function

Sub Main()
    Dim elapsed = MeasureWait(15)
    Return elapsed >= 0
End Sub
```

**Разбор параметров и выполнения:**

MeasureWait(delayMilliseconds) отклоняет отрицательную задержку, сохраняет счётчик, выполняет Basic Wait(delayMilliseconds) и возвращает Windows.ElapsedMilliseconds(startMilliseconds:=startedAt). Main передаёт 15 и проверяет elapsed >= 0. Фактическое время зависит от системы и может превышать 15 мс. Ниже показаны все функции, включая обработку одного переполнения.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 3. Геометрия рабочего стола

```vb
# Main получает независимый словарь desktop, читает X, Y, Width и Height через Item с точными строками ключей, затем размеры основного монитора. Проверяет положительные размеры и то, что весь рабочий стол не меньше основного экрана. left/top могут быть отрицательными; эти координаты не передаются командам перемещения UO.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim desktop = Windows.DesktopBounds()
    Dim left = desktop.Item("X")
    Dim top = desktop.Item("Y")
    Dim width = desktop.Item("Width")
    Dim height = desktop.Item("Height")
    Dim primaryWidth = Windows.ScreenWidth()
    Dim primaryHeight = Windows.ScreenHeight()
    Return width >= primaryWidth AndAlso height >= primaryHeight AndAlso primaryWidth > 0 AndAlso primaryHeight > 0
End Sub
```

**Разбор параметров и выполнения:**

Main получает независимый словарь desktop, читает X, Y, Width и Height через Item с точными строками ключей, затем размеры основного монитора. Проверяет положительные размеры и то, что весь рабочий стол не меньше основного экрана. left/top могут быть отрицательными; эти координаты не передаются командам перемещения UO.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```


### Внутренние функции: от вызова до результата

Windows.bas — редактируемый модуль Basic с шестью публичными функциями: информация о процессе, измерение коротких интервалов и размеры рабочего стола. Ниже приведены весь код и приватные Declare. Для запуска нужен не только Main, но и подключаемый файл.

#### 1. ProcessId / Milliseconds

Milliseconds() без параметров возвращает Double в диапазоне 0..4294967295: беззнаковое 32-битное значение GetTickCount. К отрицательному нативному результату добавляется 4294967296.0. Счётчик переполняется примерно раз в 49,7 дня; это не календарное время и не высокоточный таймер для бенчмарка.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Исходник проекта: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; функция `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) принимает ранее сохранённое Milliseconds() как Double и возвращает прошедшие миллисекунды Double. Вне диапазона 0..4294967295 — ошибка скрипта. При отрицательной разнице добавляется 4294967296.0, учитывая одно переполнение. Интервал должен быть меньше полного оборота счётчика. Функция сама не ждёт.

`validate start -> now - start -> if negative add one wrap -> Double`

Исходник проекта: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; функция `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() без параметров возвращает новый Dictionary с ключами-строками X, Y, Width, Height и значениями Integer. Читайте через Item("X") и аналогично. Метрики 76–79 описывают прямоугольник всех мониторов; X/Y могут быть отрицательными. Изменение словаря не перемещает и не изменяет размеры окон.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Исходник проекта: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; функция `ScreenWidth / ScreenHeight / DesktopBounds`.

ProcessId/ScreenWidth/ScreenHeight возвращают числовые Integer. Milliseconds/ElapsedMilliseconds возвращают Double — количество миллисекунд, не флаги Boolean. DesktopBounds возвращает Object (Dictionary), а X/Y/Width/Height содержат Integer. Include и объявления ничего не возвращают. Main каждого примера возвращает 1/True после проверки данных; 0/False означает провал этой проверки, а не автоматическую логическую трактовку всех нативных результатов.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
