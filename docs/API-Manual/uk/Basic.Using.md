# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Using закриває нативний ресурс під час виходу з блока. Підтримано раніше оголошену змінну або вираз, що повертає ресурс.

## Точний синтаксис

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Параметри

- `resourceExpression` — Обчислюється один раз. Підходять File(path), MemoryStream() і CreateTimer(...). Звільнення остаточно зупиняє таймер; див. Basic.Timers. Рядок, число, List або Dictionary спричиняють помилку з номером рядка до виконання тіла. Оголосіть змінну заздалегідь: оголошення в заголовку, As New, список через кому й власні Dispose не підтримано.
- `statements / End Using` — Тіло використовує збережений об’єкт, End Using закриває його. Змінна залишається доступною, ресурс — закритим. Для кількох ресурсів вкладайте блоки. Нове присвоєння змінній не замінює об’єкт, який буде звільнено.

## Повертає

Оператор не повертає значення. Return усередині спочатку звільняє ресурс. IsClosed — власна функція прикладу з результатом 1/True або 0/False; Main повертає рядки, а не логічний успіх.

## Поведінка

- File(path) створює оболонку; викличте Create() для запису або Open() для читання в блоці. Dispose викликає Close(), скидає буфер і звільняє дескриптор. Після закриття MemoryStream виклик Length() помилковий. Приклади працюють у пам’яті й не створюють файлів.
- Компілятор створює захищену ділянку з нативним очищенням; інтерпретатор зберігає об’єкт у поточному виклику. End Using, Return, Exit, Continue та перехід назовні звільняють ресурси від внутрішнього до зовнішнього. Перехід усередину забороняється до запуску.
- Звичайна помилка закриває ресурси до зовнішнього Catch. Помилковий Dispose не повторюється, зовнішні ресурси теж закриваються. Аварійний стоп минає скриптові Catch/Finally, але звільняє нативні ресурси; помилка закриття не замінює скасування. Пауза утримує ресурс до продовження чи стопа. Нових потоків немає; заблоковане закриття ОС примусово не переривається.
- Щоб обробити помилку й залишити ресурс відкритим, розмістіть Try/Catch усередині Using. Необроблена помилка тіла з On Error Resume Next закриває ресурс і продовжує після всього блока. On Error GoTo не може посилатися на мітку всередині Using, бо це повторний вхід у закриту захищену ділянку.
- Після виходу з Using через помилку Resume у зовнішньому обробнику On Error GoTo повторює весь блок із заголовка та знову обчислює вираз ресурсу. Resume Next продовжує одразу після End Using. Змінна із закритим об’єктом не відкриває його повторно: для повторної спроби використовуйте вираз, що створює новий ресурс. Уже виконані дії тіла можуть повторитися.

## Приклади

### 1. Закриття потоку пам’яті

```vb
# stream — ресурс, size читає Length()=0 до закриття. Після End Using IsClosed(stream) перехоплює помилку та повертає True=1. Main повертає "0:1". ByVal копіює посилання, а не потік. Навчальна IsClosed трактує будь-яку помилку Length як закриття лише для цих потоків.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**Пояснення параметрів і виконання:**

stream — ресурс, size читає Length()=0 до закриття. Після End Using IsClosed(stream) перехоплює помилку та повертає True=1. Main повертає "0:1". ByVal копіює посилання, а не потік. Навчальна IsClosed трактує будь-яку помилку Length як закриття лише для цих потоків.

### 2. Повернення з допоміжної функції

```vb
# ReadLength(stream) обчислює Integer 0, а її Return закриває потік до повернення в Main. Наступний Length помилковий; closed=True, результат Main — "0:1". Не передавайте сюди ресурс, який ще має залишатися відкритим.
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**Пояснення параметрів і виконання:**

ReadLength(stream) обчислює Integer 0, а її Return закриває потік до повернення в Main. Наступний Length помилковий; closed=True, результат Main — "0:1". Не передавайте сюди ресурс, який ще має залишатися відкритим.

### 3. Вкладене очищення після помилки

```vb
# outer та inner — окремі потоки. Throw "demo" спочатку закриває inner, потім outer. Catch зберігає повідомлення; IsClosed дає по 1 для кожного. Main повертає "demo:2". Два — кількість закритих об’єктів, а не Boolean.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**Пояснення параметрів і виконання:**

outer та inner — окремі потоки. Throw "demo" спочатку закриває inner, потім outer. Catch зберігає повідомлення; IsClosed дає по 1 для кожного. Main повертає "demo:2". Два — кількість закритих об’єктів, а не Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
