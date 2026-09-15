# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Windows.bas — редагований модуль Basic із шістьма публічними функціями для процесу, коротких інтервалів і розмірів робочого стола. Нижче наведено весь код та приватні Declare. Потрібен і Main, і підключений файл.

## Точний синтаксис

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Параметри

- `Include / Windows.bas` — Include "Windows.bas" підключає Scripts/Include/Windows.bas. Для окремої папки скриптів скопіюйте файл у підпапку Include. Приклад містить Main.bas та Include/Windows.bas. Виклики через Windows., без UO.; це модуль скрипта.
- `ProcessId()` — ProcessId() без аргументів повертає Integer — Windows ID процесу клієнта, не ID персонажа, предмета чи серверного з’єднання.
- `Milliseconds()` — Milliseconds() без аргументів повертає Double 0..4294967295, тобто беззнакове 32-бітне GetTickCount. До від’ємного результату додається 4294967296.0. Оберт приблизно кожні 49,7 дня; це не календарний час або високоточний таймер.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) приймає збережене Milliseconds() як Double та повертає минулі мілісекунди Double. За межами 0..4294967295 виникає помилка. Від’ємна різниця коригується додаванням 4294967296.0, враховуючи один оберт. Інтервал має бути коротшим за оберт; функція не очікує.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight() без аргументів повертають Integer — розміри основного монітора за метриками 0/1. Це координати Windows у DPI-контексті процесу, не тайли UO та не розмір ігрового вікна.
- `DesktopBounds()` — DesktopBounds() повертає новий Dictionary зі строковими ключами X, Y, Width, Height і значеннями Integer. Читання через Item("X") тощо. Метрики 76–79 охоплюють усі монітори; X/Y можуть бути від’ємними. Зміна словника не змінює вікна.

## Повертає

ProcessId та розміри — Integer. Milliseconds/ElapsedMilliseconds — кількість мілісекунд Double, не Boolean. DesktopBounds — Object (Dictionary) з Integer-значеннями. Include й оголошення без результату. Main прикладів повертає 1/True після перевірки даних; 0/False означає невдалу перевірку, а не логічний зміст кожного нативного результату.

## Поведінка

- Потрібен Windows x64. NativeTicks, NativeProcessId, NativeMetric оголошені приватними Declare нижче. Правила DLL — у Basic.Declare. Модуль не надсилає ігрові пакети, не змінює налаштування й не рухає персонажа.
- Читаються поточні значення. Milliseconds зазвичай оновлюється раз на 10–16 мс. ElapsedMilliseconds не визначає кілька обертів або значення з іншої сесії Windows. Використовуйте для коротких операцій; точний час Wait не гарантується.
- Переносьте Main.bas разом із Include/Windows.bas; код доступний для редагування в IDE. DesktopBounds щоразу створює окремий знімок; зміни моніторів чи DPI впливають на наступні результати.

## Приклади

### 1. Процес і лічильник

```vb
# Main підключає Windows.bas, читає ProcessId() та Milliseconds() у startedAt. AndAlso перевіряє додатний ID і діапазон 0..4294967295, повертаючи 1/True. Конкретні числа залежать від комп’ютера.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Пояснення параметрів і виконання:**

Main підключає Windows.bas, читає ProcessId() та Milliseconds() у startedAt. AndAlso перевіряє додатний ID і діапазон 0..4294967295, повертаючи 1/True. Конкретні числа залежать від комп’ютера.

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

### 2. Виміряти очікування

```vb
# MeasureWait(delayMilliseconds) відхиляє від’ємну затримку, зберігає лічильник, виконує Wait(delayMilliseconds) та повертає ElapsedMilliseconds(startMilliseconds:=startedAt). Main передає 15 і перевіряє elapsed >= 0. Час може перевищувати 15 мс. Усі функції та обробку переповнення показано нижче.
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

**Пояснення параметрів і виконання:**

MeasureWait(delayMilliseconds) відхиляє від’ємну затримку, зберігає лічильник, виконує Wait(delayMilliseconds) та повертає ElapsedMilliseconds(startMilliseconds:=startedAt). Main передає 15 і перевіряє elapsed >= 0. Час може перевищувати 15 мс. Усі функції та обробку переповнення показано нижче.

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

### 3. Робочий стіл

```vb
# Main отримує незалежний Dictionary, читає X/Y/Width/Height через Item і порівнює розміри з основним монітором. Розміри основного мають бути додатними, а всього стола — не меншими. left/top можуть бути від’ємними; це не координати руху UO.
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

**Пояснення параметрів і виконання:**

Main отримує незалежний Dictionary, читає X/Y/Width/Height через Item і порівнює розміри з основним монітором. Розміри основного мають бути додатними, а всього стола — не меншими. left/top можуть бути від’ємними; це не координати руху UO.

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


### Внутрішні функції: від виклику до результату

Windows.bas — редагований модуль Basic із шістьма публічними функціями для процесу, коротких інтервалів і розмірів робочого стола. Нижче наведено весь код та приватні Declare. Потрібен і Main, і підключений файл.

#### 1. ProcessId / Milliseconds

Milliseconds() без аргументів повертає Double 0..4294967295, тобто беззнакове 32-бітне GetTickCount. До від’ємного результату додається 4294967296.0. Оберт приблизно кожні 49,7 дня; це не календарний час або високоточний таймер.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Код проєкту: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; функція `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) приймає збережене Milliseconds() як Double та повертає минулі мілісекунди Double. За межами 0..4294967295 виникає помилка. Від’ємна різниця коригується додаванням 4294967296.0, враховуючи один оберт. Інтервал має бути коротшим за оберт; функція не очікує.

`validate start -> now - start -> if negative add one wrap -> Double`

Код проєкту: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; функція `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() повертає новий Dictionary зі строковими ключами X, Y, Width, Height і значеннями Integer. Читання через Item("X") тощо. Метрики 76–79 охоплюють усі монітори; X/Y можуть бути від’ємними. Зміна словника не змінює вікна.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Код проєкту: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; функція `ScreenWidth / ScreenHeight / DesktopBounds`.

ProcessId та розміри — Integer. Milliseconds/ElapsedMilliseconds — кількість мілісекунд Double, не Boolean. DesktopBounds — Object (Dictionary) з Integer-значеннями. Include й оголошення без результату. Main прикладів повертає 1/True після перевірки даних; 0/False означає невдалу перевірку, а не логічний зміст кожного нативного результату.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
