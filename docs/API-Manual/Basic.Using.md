# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Using закрывает нативный ресурс при выходе из блока. Поддерживается форма с уже объявленной переменной или выражением, возвращающим ресурс.

## Точный синтаксис

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Параметры

- `resourceExpression` — Вычисляется один раз при входе. Подходят объекты File(path), MemoryStream() и CreateTimer(...). Освобождение таймера окончательно останавливает его; см. Basic.Timers. Строка, число, List и Dictionary вызывают ошибку с номером строки до выполнения тела. Переменную объявляйте заранее: объявления в заголовке, As New, список через запятую и пользовательские методы Dispose не поддержаны.
- `statements / End Using` — Тело использует сохранённый объект; End Using закрывает его. Переменная остаётся доступной, но ресурс уже закрыт. Для нескольких ресурсов вкладывайте блоки. Переприсваивание переменной не меняет исходный объект, который будет закрыт.

## Возвращает

Оператор ничего не возвращает и не является логической проверкой. Return внутри тела сохраняет обычный смысл, но сначала освобождается ресурс. IsClosed в примерах — пользовательская функция с результатом 1/True или 0/False. Итоговые результаты Main — строки, а не признаки успеха.

## Поведение

- File(path) создаёт оболочку: внутри блока вызовите Create() для записи либо Open() для чтения. Освобождение вызывает Close(), сбрасывает буфер и закрывает дескриптор. MemoryStream() создаёт пустой поток; после освобождения Length() вызывает ошибку. Примеры работают в памяти и не создают файлов.
- Компилятор создаёт защищённый блок с нативным освобождением. Интерпретатор один раз сохраняет объект в текущем вызове. End Using, Return, Exit, Continue и переход наружу закрывают ресурсы от внутреннего к внешнему. Переход внутрь тела запрещается до запуска.
- При обычной ошибке ресурсы закрываются до внешнего Catch. Неудачный Dispose повторно не вызывается; внешние ресурсы тоже освобождаются. Аварийный стоп пропускает скриптовые Catch/Finally, но закрывает нативные ресурсы; ошибка закрытия не подменяет отмену. Пауза удерживает ресурс до продолжения либо стопа. Новые потоки не создаются; принудительно прервать зависшую операцию закрытия ОС этот оператор не может.
- Чтобы обработать ошибку, сохранив ресурс открытым, поместите Try/Catch внутрь Using. Необработанная ошибка тела при On Error Resume Next закрывает ресурс и продолжает выполнение после всего блока Using. On Error GoTo не может ссылаться на метку внутри тела Using: это означало бы повторный вход в уже закрытую защищённую область.
- После выхода из Using с ошибкой Resume во внешнем обработчике On Error GoTo повторяет весь блок с заголовка и заново вычисляет выражение ресурса. Resume Next продолжает сразу после End Using. Если переменная по-прежнему содержит закрытый объект, повторный вход не открывает его: для повторной попытки используйте выражение, создающее новый ресурс. Уже выполненные действия тела могут повториться.

## Примеры

### 1. Закрыть поток памяти

```vb
# stream — ресурс; size получает Length()=0, пока поток открыт. После End Using функция IsClosed(stream) ловит ошибку закрытого потока и возвращает True=1. Main возвращает "0:1". ByVal копирует ссылку, а не содержимое потока. Учебный IsClosed считает любую ошибку Length признаком закрытия и предназначен для этих потоков.
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

**Разбор параметров и выполнения:**

stream — ресурс; size получает Length()=0, пока поток открыт. После End Using функция IsClosed(stream) ловит ошибку закрытого потока и возвращает True=1. Main возвращает "0:1". ByVal копирует ссылку, а не содержимое потока. Учебный IsClosed считает любую ошибку Length признаком закрытия и предназначен для этих потоков.

### 2. Вернуться из вспомогательной функции

```vb
# ReadLength(stream) принимает ресурс под управление своего Using и вычисляет Integer 0. Return закрывает поток до передачи size в Main. Следующий Length вызывает ошибку; closed становится True, а Main возвращает "0:1". Не передавайте сюда ресурс, который вызывающему коду ещё нужен открытым.
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

**Разбор параметров и выполнения:**

ReadLength(stream) принимает ресурс под управление своего Using и вычисляет Integer 0. Return закрывает поток до передачи size в Main. Следующий Length вызывает ошибку; closed становится True, а Main возвращает "0:1". Не передавайте сюда ресурс, который вызывающему коду ещё нужен открытым.

### 3. Освободить вложенные ресурсы при ошибке

```vb
# outer и inner — отдельные потоки. Throw "demo" выводит из обоих блоков: сначала закрывается inner, затем outer. Catch сохраняет исходное сообщение. IsClosed возвращает по 1 для каждого, поэтому Main возвращает "demo:2". Число 2 — количество закрытых объектов, а не Boolean.
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

**Разбор параметров и выполнения:**

outer и inner — отдельные потоки. Throw "demo" выводит из обоих блоков: сначала закрывается inner, затем outer. Catch сохраняет исходное сообщение. IsClosed возвращает по 1 для каждого, поэтому Main возвращает "demo:2". Число 2 — количество закрытых объектов, а не Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
