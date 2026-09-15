# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Sub объединяет инструкции в именованную процедуру. Подходит для общей обработки предметов, проверок и завершения операции. Вызов помощника выполняется последовательно в текущем скрипте и не запускает отдельный фоновый скрипт.

## Точный синтаксис

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

## Параметры

- `name` — Имя процедуры, без учёта регистра. Собственные процедуры вызываются без UO.; член модуля — Tools.Work(...). Public/Private управляют доступом внутри модулей: см. Basic.Module и Basic.Visibility.
- `parameters / arguments` — Параметры объявляют в скобках, аргументы передают по порядку. По умолчанию действует ByRef; ByVal копирует значение аргумента, Optional задаёт значение при пропуске, последний ParamArray собирает дополнительные аргументы. Точные правила типов, массивов, совместных ссылок и обратной записи описаны в пяти разделах о параметрах.
- `statements / End Sub` — Тело может быть пустым; завершается End Sub. Локальные переменные принадлежат конкретному вызову, включая отдельные вызовы при рекурсии. Процедуры объявляют на уровне файла или модуля, а не внутри другой процедуры.
- `Call` — Для name(arguments) слово Call необязательно. Call name arguments допускает аргументы без скобок, Call name вызывает процедуру без параметров. Call отбрасывает возвращённое значение. Имена и выражения аргументов сохраняют обычный смысл; UO. перед собственной процедурой не ставится.
- `Exit Sub / Return` — Exit Sub либо Return без выражения завершает текущий вызов. Return expression внутри Sub — расширение совместимости Basic, возвращающее значение; в обычном VB.NET такой формы у Sub нет. Exit Function внутри Sub вызывает ошибку загрузки.

## Возвращает

End Sub, Exit Sub и пустой Return дают Unit — отсутствие содержательного результата, а не признак успеха или ID. Return expression в старом Basic Sub возвращает значение выражения. ByRef отдельно может изменить переменную вызывающего кода. Если задача помощника — вернуть значение, лучше объявлять Function.

## Поведение

- При подготовке нормализуются совместимые заголовки и формы Call, проверяется блок, разрешаются имена вызовов. Перед входом вычисляются и связываются аргументы. Повторные вызовы используют готовые инструкции, но получают собственные локальные значения.
- Интерпретатор создаёт область вызова, выполняет тело и возвращается к следующей инструкции после вызова. Обычный выход и Exit Sub выполняют покидаемые блоки Finally, затем завершается обратная запись параметров. Исключение передаётся действующему обработчику ошибок; ошибочный вызов нельзя считать успешным результатом.
- Проверки паузы и остановки остаются в движке. Помощник не создаёт поток, автоматическую задержку или таймаут. Рекурсии нужно условие завершения. Присваивание результата имени Sub не поддерживается: для name=expression используется Function.
- Вложенные вызовы процедур ограничены 32 кадрами, включая обратные вызовы и обработчики событий. Превышение даёт перехватываемую ошибку скрипта; для глубокой обработки используйте цикл. Возврат или ошибка освобождают кадр, поэтому следующие вызовы могут выполняться.

## Примеры

### 1. Три формы вызова

```vb
# total начинается с 4. AddAmount получает total через ByRef; пропущенный amount равен 1, явные 3 и 2 передаются ByVal. Call со скобками, Call без скобок и обычный вызов выполняют одного помощника. В вызывающем коде получается 4+1+3+2=10; Main явно возвращает 10.
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

**Разбор параметров и выполнения:**

total начинается с 4. AddAmount получает total через ByRef; пропущенный amount равен 1, явные 3 и 2 передаются ByVal. Call со скобками, Call без скобок и обычный вызов выполняют одного помощника. В вызывающем коде получается 4+1+3+2=10; Main явно возвращает 10.

### 2. Открытая процедура и внутренний помощник

```vb
# Batches.SumInto получает total через ByRef, а значения 3,-9,4 собираются в values. For Each вызывает закрытую AppendAmount для каждого значения. Проверка отрицательного числа выходит только из помощника: -9 пропускается, цикл продолжается. При начальном 2 итог равен 2+3+4=9. Помощник доступен внутри Batches, внешний вызов использует открытое имя модуля.
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

**Разбор параметров и выполнения:**

Batches.SumInto получает total через ByRef, а значения 3,-9,4 собираются в values. For Each вызывает закрытую AppendAmount для каждого значения. Проверка отрицательного числа выходит только из помощника: -9 пропускается, цикл продолжается. При начальном 2 итог равен 2+3+4=9. Помощник доступен внутри Batches, внешний вызов использует открытое имя модуля.

### 3. Досрочный выход, завершение и старый возврат

```vb
# Finish записывает trace=1 и выходит; trace=99 не выполняется. Finally дописывает 2, поэтому через ByRef в Main приходит trace=12. LegacyValue показывает расширение Basic: Return 7 внутри Sub. Main получает 12*10+7=127. Числа trace заданы примером и не являются игровыми кодами результата.
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

**Разбор параметров и выполнения:**

Finish записывает trace=1 и выходит; trace=99 не выполняется. Finally дописывает 2, поэтому через ByRef в Main приходит trace=12. LegacyValue показывает расширение Basic: Return 7 внутри Sub. Main получает 12*10+7=127. Числа trace заданы примером и не являются игровыми кодами результата.

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
