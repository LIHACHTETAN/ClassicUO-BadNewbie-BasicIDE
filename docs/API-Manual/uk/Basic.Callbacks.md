# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

AddressOf зберігає посилання на Sub або Function скрипту без виклику. Передавайте його іншій процедурі, повертайте з функції чи зберігайте в колекції, щоб задавати власне правило обробки.

## Точний синтаксис

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Параметри

- `ProcedureName` — Ім’я оголошеної процедури, за потреби з назвою Module. Потрібне рівно одне оголошення. Невідомі імена, недоступні Private та перевантаження відхиляються до запуску. Для вбудованої функції Basic або команди UO напишіть скриптову обгортку з унікальним ім’ям і використайте її AddressOf. Дужок після імені немає.
- `callback / arguments` — callback має тип Object. callback(...) та callback.Invoke(...) синхронно викликають процедуру в потоці скрипту. Іменовані аргументи використовують справжні імена параметрів. Елемент колекції спершу збережіть у змінну. Посилання фіксується до обчислення аргументів, навіть якщо вони змінюють callback.
- `ByRef / ByVal / Optional / ParamArray` — ByVal копіює значення або посилання; ByRef записує зміни назад; Optional обчислює пропущені значення; ParamArray збирає позиційні аргументи. Іменовані аргументи йдуть після позиційних; значення ParamArray передаються лише позиційно. Хибна кількість чи ім’я параметра спричиняє помилку до побічних дій аргументів.

## Повертає

AddressOf повертає посилання Object, а не ID, адресу пам’яті, Boolean чи результат функції. Виклик Function повертає її результат; Sub без виразу Return не повертає значення (Unit). IsPositive повертає 1/True або 0/False. Main повертає String у прикладах 1 і 3 та Integer 15 у прикладі 2.

## Поведінка

- Посилання зберігає процедуру, а не локальні змінні функції, що його створила. Це не лямбда й не замикання. Інший рушій або повторно завантажений скрипт не може викликати старе посилання. Public-фабрика може навмисно повернути посилання на власну Private-функцію.
- Підготовка перевіряє ім’я та доступ. Інтерпретатор кешує незмінне посилання для кожної позиції AddressOf. Кожен виклик читає поточну змінну, перевіряє параметри, один раз обчислює аргументи в порядку запису та створює звичайний кадр процедури. ByRef і помилки працюють як за прямого виклику.
- Новий потік або таймер не створюється. Пауза й скасування діють через звичайні контрольні точки, зокрема в циклах функції. Помилки переходять до Catch/Finally викликача; аварійна зупинка не поглинається Catch. Блокувальні системні виклики мають власні обмеження скасування.
- Оголошення Delegate, лямбди, вказівники DLL та посилання на перевантаження тут не підтримуються. AddressOf пишеться без UO.; ігрові команди всередині обгортки — з UO.

## Приклади

### 1. Фільтрація власним правилом

```vb
# values — вхідний List; predicate — AddressOf IsPositive. FilterValues викликає predicate(number) один раз для кожного числа. IsPositive повертає True лише для додатних значень: залишаються 4 і 7. selected.Count()=2 та selected[0]=4; Main повертає "2:4". Обидві допоміжні функції повністю наведені в скрипті й не є командами API.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**Пояснення параметрів і виконання:**

values — вхідний List; predicate — AddressOf IsPositive. FilterValues викликає predicate(number) один раз для кожного числа. IsPositive повертає True лише для додатних значень: залишаються 4 і 7. selected.Count()=2 та selected[0]=4; Main повертає "2:4". Обидві допоміжні функції повністю наведені в скрипті й не є командами API.

### 2. Зміна змінної викликача

```vb
# total передається до AddAmount через ByRef; amount — через ByVal, типове значення 1. update(total) змінює 10 на 11; update.Invoke(amount:=4, total:=total) зіставляє імена й змінює 11 на 15. ByRef записує зміни назад. Sub не має результату; Main повертає Integer 15, не Boolean.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**Пояснення параметрів і виконання:**

total передається до AddAmount через ByRef; amount — через ByVal, типове значення 1. update(total) змінює 10 на 11; update.Invoke(amount:=4, total:=total) зіставляє імена й змінює 11 на 15. ByRef записує зміни назад. Sub не має результату; Main повертає Integer 15, не Boolean.

### 3. Закрите правило та помилка

```vb
# Rules.Create повертає посилання на Private CheckedDouble. Безпосередній AddressOf Rules.CheckedDouble ззовні заборонений. operation(6) повертає 12; operation(-1) викликає "negative" до присвоєння, тому result лишається 12. Catch отримує текст; Finally додає ":done". Main повертає "12:negative:done". Закриття IDE саме по собі не зупиняє скрипт.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**Пояснення параметрів і виконання:**

Rules.Create повертає посилання на Private CheckedDouble. Безпосередній AddressOf Rules.CheckedDouble ззовні заборонений. operation(6) повертає 12; operation(-1) викликає "negative" до присвоєння, тому result лишається 12. Catch отримує текст; Finally додає ":done". Main повертає "12:negative:done". Закриття IDE саме по собі не зупиняє скрипт.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
