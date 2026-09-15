# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Function оголошує помічника, що повертає кількість, текст або посилання на List/Dictionary. Це власний код без UO.; UO.GetType(item) лишається окремою ігровою командою, навіть за наявності Function GetType(value).

## Точний синтаксис

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## Параметри

- `name` — Ім’я без урахування регістру є назвою виклику та неявною локальною змінною результату всередині тіла. name без дужок читає результат; name(arguments) викликає функцію, зокрема рекурсивно. Не оголошуйте результат повторно через Dim, Var, Const чи параметр.
- `parameters / arguments` — Позиційні параметри працюють як у Sub: типовий ByRef, ByVal, Optional та останній ParamArray. Див. Basic.Parameters й окремі розділи. Функцію модуля викликають як Tools.Calculate(...); Public/Private дотримуються правил доступу.
- `As type` — Необов’язковий тип результату. Integer/Long/Short/Byte зберігаються як Integer рушія; Double/Single/Decimal — Double; String — текст; Boolean/Bool нормалізує до 1 чи 0; Object/Variant зберігає вид значення. Це не всі розрядності VB.NET. Невідомий тип заборонено. Без As результат Variant; суфікс імені тут не визначає тип.
- `name = expression` — Зберігає результат і ПРОДОВЖУЄ наступну інструкцію. Результат можна знову читати й змінювати, включно з +=. Це локальна змінна цього виклику, не глобальна змінна чи новий виклик.
- `Return / Exit Function / End Function` — Return expression записує типізований результат і починає вихід. Порожній Return, Exit Function і досягнення End Function повертають поточний результат. End Function обов’язковий. Exit Sub усередині Function спричиняє помилку завантаження.

## Повертає

Повертається поточний результат після нормального виконання Finally. Початково Integer — 0, Double — 0.0, Boolean — FALSE/0, String — порожній текст; без типу, Variant та Object починаються з Unit — відсутності змістовного значення. List/Dictionary/Object зберігають посилання. Boolean дає числові 1/0 для порівнянь із TRUE/FALSE; довільна кількість чи ID не є автоматичним кодом успіху.

## Поведінка

- Підготовка зберігає справжню Function, перевіряє тип і виходи, прив’язує результат до локальної області та готує інструкції один раз. Кожен виклик отримує аргументи й свіжий типізований результат. Присвоєння імені використовує звичайне перетворення типізованої змінної.
- Return записує результат і виконує покидані Finally зсередини назовні. Finally може змінити результат до повернення. Зворотний запис ByRef завершується після успішного виклику. Необроблена помилка поширюється далі, не означаючи успіху; неправильне перетворення результату теж є помилкою.
- Рекурсивний виклик має власні параметри, локальні значення та результат. Factorial(n-1) не перезаписує змінну Factorial викликача. Потрібні базовий випадок і обмеження рекурсії. Виклик не додає затримки, потоку чи таймауту; перевірки паузи й зупинки залишаються.
- Вкладені виклики процедур обмежено 32 кадрами, включно зі зворотними викликами та обробниками подій. Перевищення дає перехоплювану помилку скрипту; для глибокої обробки використовуйте цикл. Повернення або помилка звільняють кадр і дозволяють наступні виклики.

## Приклади

### 1. Присвоїти, продовжити чи вийти раніше

```vb
# TotalPrice отримує count і price через ByVal та повертає Integer. Від’ємне число одразу дає -1. Інакше записується count*price, потім наступна інструкція додає фіксовані 2. TotalPrice(3,4) дає 14, TotalPrice(-1,4) — -1; Main поєднує їх у 14:-1. Число -1 обране помічником, не є автоматичним кодом рушія.
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**Пояснення параметрів і виконання:**

TotalPrice отримує count і price через ByVal та повертає Integer. Від’ємне число одразу дає -1. Інакше записується count*price, потім наступна інструкція додає фіксовані 2. TotalPrice(3,4) дає 14, TotalPrice(-1,4) — -1; Main поєднує їх у 14:-1. Число -1 обране помічником, не є автоматичним кодом рушія.

### 2. Рекурсія з окремим результатом

```vb
# Factorial отримує n через ByVal та задає свій результат 1. За n<=1 Exit Function повертає одиницю. Інакше n*Factorial(n-1) використовує новий вкладений виклик. Для малих невід’ємних чисел прикладу 5!+3!=120+6=126. Від’ємні числа також потрапляють у базову гілку; приклад не перевіряє всю математичну область факторіала.
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**Пояснення параметрів і виконання:**

Factorial отримує n через ByVal та задає свій результат 1. За n<=1 Exit Function повертає одиницю. Інакше n*Factorial(n-1) використовує новий вкладений виклик. Для малих невід’ємних чисел прикладу 5!+3!=120+6=126. Від’ємні числа також потрапляють у базову гілку; приклад не перевіряє всю математичну область факторіала.

### 3. Return, два Finally та ByRef

```vb
# Calculate отримує trace через ByRef. Return 1 записує результат і починає вихід. Внутрішній Finally змінює результат і trace з 1 на 12, зовнішній — на 123. Main отримує result=123 і trace=123 та повертає 123:123. Завершення змінює результат навіть після Return expression; рух і часові затримки гри не імітуються.
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**Пояснення параметрів і виконання:**

Calculate отримує trace через ByRef. Return 1 записує результат і починає вихід. Внутрішній Finally змінює результат і trace з 1 на 12, зовнішній — на 123. Main отримує result=123 і trace=123 та повертає 123:123. Завершення змінює результат навіть після Return expression; рух і часові затримки гри не імітуються.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
