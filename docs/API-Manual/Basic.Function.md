# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Function объявляет помощника, возвращающего значение: количество, строку или ссылку на List/Dictionary. Это собственный код без UO.; UO.GetType(item) остаётся отдельной игровой командой, даже если объявлена Function GetType(value).

## Точный синтаксис

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

## Параметры

- `name` — Имя без учёта регистра служит одновременно именем вызова и неявной локальной переменной результата внутри тела. name без скобок читает текущий результат; name(arguments) вызывает функцию, в том числе рекурсивно. Не объявляйте результат повторно через Dim, Var, Const или параметр.
- `parameters / arguments` — Позиционные параметры работают как у Sub: ByRef по умолчанию, ByVal, Optional и последний ParamArray. См. Basic.Parameters и отдельные главы о параметрах. Функция модуля вызывается как Tools.Calculate(...); Public/Private соблюдают правила доступа модуля.
- `As type` — Необязательный тип результата. Integer/Long/Short/Byte используют хранилище Integer этого движка; Double/Single/Decimal — Double; String — текст; Boolean/Bool приводит к 1 или 0; Object/Variant сохраняет вид значения. Это не все числовые разрядности VB.NET. Неизвестный тип запрещён. Без As результат Variant; суффикс имени здесь не задаёт тип результата.
- `name = expression` — Сохраняет результат и ПРОДОЛЖАЕТ выполнение следующей инструкции. Результат можно читать и менять снова, включая +=. Это локальная переменная данного вызова, а не глобальная переменная или новый вызов.
- `Return / Exit Function / End Function` — Return expression записывает типизированный результат и начинает выход. Пустой Return, Exit Function и достижение End Function возвращают текущий результат. End Function обязателен. Exit Sub внутри Function вызывает ошибку загрузки.

## Возвращает

Возвращается текущий результат после нормального выполнения Finally. Начальные значения: Integer 0, Double 0.0, Boolean FALSE/0, String пустая строка; без типа, Variant и Object начинают с Unit — отсутствия содержательного значения. Результаты List/Dictionary/Object сохраняют ссылки. Boolean возвращает число 1/0, поэтому подходят сравнения с TRUE/FALSE; произвольное количество или ID автоматически не становится кодом успеха.

## Поведение

- Подготовка сохраняет настоящее объявление Function, проверяет тип результата и выходы, связывает результат с локальной областью и один раз готовит инструкции. Каждый вызов получает аргументы и свежий типизированный результат. Присваивание имени функции использует обычное преобразование типизированной переменной.
- Return фиксирует результат и выполняет покидаемые Finally изнутри наружу. Finally может изменить результат до возврата вызывающему коду. Обратная запись ByRef завершается после успешного вызова. Необработанная ошибка передаётся дальше, а не превращается в успех; ошибка преобразования результата также является исключением.
- Рекурсивный вызов имеет свои параметры, локальные значения и результат: Factorial(n-1) не перезаписывает переменную Factorial вызывающей функции. Нужны базовый случай и ограничение рекурсии. Вызов не добавляет задержку, поток или таймаут; проверки паузы и остановки движка сохраняются.
- Вложенные вызовы процедур ограничены 32 кадрами, включая обратные вызовы и обработчики событий. Превышение даёт перехватываемую ошибку скрипта; для глубокой обработки используйте цикл. Возврат или ошибка освобождают кадр, поэтому следующие вызовы могут выполняться.

## Примеры

### 1. Присвоить, продолжить либо выйти раньше

```vb
# TotalPrice получает count и price через ByVal и возвращает Integer. Отрицательное количество или цена сразу дают -1. Иначе сначала сохраняется count*price, затем следующая инструкция прибавляет фиксированные 2. TotalPrice(3,4) возвращает 14; TotalPrice(-1,4) — -1. Main соединяет их в 14:-1. Число -1 выбрано самим помощником, а не является автоматическим кодом ошибки движка.
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

**Разбор параметров и выполнения:**

TotalPrice получает count и price через ByVal и возвращает Integer. Отрицательное количество или цена сразу дают -1. Иначе сначала сохраняется count*price, затем следующая инструкция прибавляет фиксированные 2. TotalPrice(3,4) возвращает 14; TotalPrice(-1,4) — -1. Main соединяет их в 14:-1. Число -1 выбрано самим помощником, а не является автоматическим кодом ошибки движка.

### 2. Рекурсия с собственным результатом

```vb
# Factorial получает n через ByVal и устанавливает свой результат в 1. При n<=1 Exit Function возвращает эту единицу. Иначе n*Factorial(n-1) использует новый вложенный вызов. Для небольших неотрицательных чисел в примере 5!+3!=120+6=126. Отрицательные числа тоже попадают в базовую ветку; пример не проверяет всю математическую область определения факториала.
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

**Разбор параметров и выполнения:**

Factorial получает n через ByVal и устанавливает свой результат в 1. При n<=1 Exit Function возвращает эту единицу. Иначе n*Factorial(n-1) использует новый вложенный вызов. Для небольших неотрицательных чисел в примере 5!+3!=120+6=126. Отрицательные числа тоже попадают в базовую ветку; пример не проверяет всю математическую область определения факториала.

### 3. Return, два Finally и ByRef

```vb
# Calculate получает trace через ByRef. Return 1 записывает результат и начинает выход. Внутренний Finally меняет результат и trace с 1 на 12, внешний — на 123. Main получает result=123 и trace=123 и возвращает 123:123. Завершение меняет результат даже после Return expression; игровое движение и задержки здесь не имитируются.
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

**Разбор параметров и выполнения:**

Calculate получает trace через ByRef. Return 1 записывает результат и начинает выход. Внутренний Finally меняет результат и trace с 1 на 12, внешний — на 123. Main получает result=123 и trace=123 и возвращает 123:123. Завершение меняет результат даже после Return expression; игровое движение и задержки здесь не имитируются.

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
