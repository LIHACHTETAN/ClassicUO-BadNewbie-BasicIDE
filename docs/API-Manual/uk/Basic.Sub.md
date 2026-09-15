# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Sub об’єднує інструкції в іменовану процедуру для обробки предметів, перевірок або завершення операції. Допоміжна процедура виконується послідовно в поточному скрипті; її виклик не запускає окремий фоновий скрипт.

## Точний синтаксис

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## Параметри

- `name` — Ім’я без урахування регістру. Власні процедури викликають без UO.; член модуля — Tools.Work(...). Public/Private керують доступом у модулях: див. Basic.Module та Basic.Visibility.
- `parameters / arguments` — Параметри оголошують у дужках, аргументи передають за порядком. Типово діє ByRef; ByVal копіює значення, Optional задає значення пропущеного аргументу, останній ParamArray збирає решту. Правила типів, масивів, спільних посилань і зворотного запису наведені у п’яти розділах про параметри.
- `statements / End Sub` — Тіло може бути порожнім; закривається End Sub. Локальні змінні належать окремому виклику, зокрема при рекурсії. Оголошуйте процедури на рівні файла або модуля, не всередині іншої процедури.
- `Call` — У name(arguments) слово Call необов’язкове. Call name arguments дозволяє аргументи без дужок; Call name викликає процедуру без параметрів. Call відкидає повернуте значення. Вирази аргументів мають звичайний зміст; власні виклики не отримують UO.
- `Exit Sub / Return` — Exit Sub або Return без виразу завершує поточний виклик. Return expression усередині Sub — розширення сумісності Basic; звичайний VB.NET Sub такої форми не має. Exit Function усередині Sub спричиняє помилку завантаження.

## Повертає

End Sub, Exit Sub і порожній Return дають Unit: відсутність змістовного результату, а не ознаку успіху чи ID. Return expression у старому Basic Sub повертає вираз. ByRef окремо може змінити змінну викликача. Для помічника, що повертає значення, краще Function.

## Поведінка

- Підготовка нормалізує сумісні заголовки та Call, перевіряє блок і визначає імена викликів. Аргументи обчислюються й прив’язуються перед входом. Повторні виклики використовують готові інструкції, але окремі локальні значення.
- Інтерпретатор створює область виклику, виконує тіло і повертається до наступної інструкції. Звичайний вихід та Exit Sub виконують блоки Finally, які залишають, після чого завершується зворотний запис параметрів. Винятки надходять до чинного обробника; помилковий виклик не означає успіх.
- Перевірки паузи й зупинки залишаються в рушії. Помічник не створює потоку, затримки або таймауту. Рекурсія потребує умови завершення. Присвоєння результату імені Sub не підтримується: для name=expression потрібна Function.
- Вкладені виклики процедур обмежено 32 кадрами, включно зі зворотними викликами та обробниками подій. Перевищення дає перехоплювану помилку скрипту; для глибокої обробки використовуйте цикл. Повернення або помилка звільняють кадр і дозволяють наступні виклики.

## Приклади

### 1. Три форми виклику

```vb
# total починається з 4. AddAmount отримує total через ByRef; пропущений amount дорівнює 1, явні 3 та 2 передаються ByVal. Call із дужками, без дужок і звичайний виклик виконують одного помічника. Виходить 4+1+3+2=10; Main явно повертає 10.
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**Пояснення параметрів і виконання:**

total починається з 4. AddAmount отримує total через ByRef; пропущений amount дорівнює 1, явні 3 та 2 передаються ByVal. Call із дужками, без дужок і звичайний виклик виконують одного помічника. Виходить 4+1+3+2=10; Main явно повертає 10.

### 2. Відкрита процедура та внутрішній помічник

```vb
# Batches.SumInto отримує total через ByRef і збирає 3,-9,4 у values. For Each викликає приватну AppendAmount. Перевірка від’ємного числа виходить лише з помічника: -9 пропускається, цикл триває. Від початкового 2 виходить 2+3+4=9. Помічник доступний у Batches, зовнішній виклик використовує відкрите ім’я модуля.
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**Пояснення параметрів і виконання:**

Batches.SumInto отримує total через ByRef і збирає 3,-9,4 у values. For Each викликає приватну AppendAmount. Перевірка від’ємного числа виходить лише з помічника: -9 пропускається, цикл триває. Від початкового 2 виходить 2+3+4=9. Помічник доступний у Batches, зовнішній виклик використовує відкрите ім’я модуля.

### 3. Достроковий вихід і завершення

```vb
# Finish задає trace=1 та виходить; trace=99 пропускається. Finally дописує 2, тому ByRef повертає в Main trace=12. LegacyValue показує розширення Basic: Return 7 усередині Sub. Main отримує 12*10+7=127. trace — значення прикладу, не ігровий код.
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**Пояснення параметрів і виконання:**

Finish задає trace=1 та виходить; trace=99 пропускається. Finally дописує 2, тому ByRef повертає в Main trace=12. LegacyValue показує розширення Basic: Return 7 усередині Sub. Main отримує 12*10+7=127. trace — значення прикладу, не ігровий код.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
