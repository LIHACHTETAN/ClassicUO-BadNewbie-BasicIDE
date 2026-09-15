# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

AddressOf сохраняет ссылку на Sub или Function скрипта, не вызывая её. Ссылку можно передать другой процедуре, вернуть из функции или сохранить в коллекции, чтобы задавать своё правило обработки.

## Точный синтаксис

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Параметры

- `ProcedureName` — Имя объявленной процедуры, при необходимости с именем Module. Должно соответствовать ровно одному объявлению. Неизвестное имя, чужой Private и перегрузки отклоняются до запуска. Для встроенной функции Basic или команды UO создайте скриптовую функцию-обёртку с уникальным именем и возьмите её AddressOf. После имени скобки не ставятся.
- `callback / arguments` — callback — значение Object. callback(...) и callback.Invoke(...) синхронно вызывают выбранную процедуру в потоке скрипта. Для именованных аргументов используйте настоящие имена её параметров. Элемент коллекции сначала сохраните в переменную. Ссылка фиксируется до вычисления аргументов, даже если они меняют переменную callback.
- `ByRef / ByVal / Optional / ParamArray` — Действуют обычные правила: ByVal копирует значение или ссылку, ByRef записывает изменения обратно, Optional вычисляет пропущенные значения, ParamArray собирает позиционные аргументы. Именованные аргументы идут после позиционных; значения ParamArray передаются только позиционно. Неверное количество или имя параметра вызывает ошибку до побочных действий аргументов.

## Возвращает

AddressOf возвращает ссылку Object, а не ID, адрес памяти, Boolean или результат функции. Вызов Function возвращает её результат. Sub без выражения Return не возвращает значения (Unit). IsPositive ниже возвращает 1/True либо 0/False; Main возвращает String в примерах 1 и 3, Integer 15 в примере 2.

## Поведение

- Ссылка хранит процедуру, а не локальные переменные функции, которая её создала: это не лямбда и не замыкание. Она принадлежит загрузившему её скрипту. Другой движок или повторно загруженный скрипт не может вызвать старую ссылку. Public-функция может намеренно вернуть ссылку на свой Private-помощник.
- При подготовке проверяются имя и доступ. Для каждой позиции AddressOf движок сохраняет неизменяемую ссылку. При вызове читает актуальную переменную, проверяет параметры, однократно вычисляет аргументы в порядке записи и создаёт обычный кадр процедуры. Обратная запись ByRef и обработка ошибок совпадают с прямым вызовом.
- Ссылка не создаёт поток или таймер и сама ничего не запускает. Пауза и отмена работают через обычные контрольные точки, включая циклы внутри функции. Ошибки попадают в Catch/Finally вызывающей процедуры; аварийная остановка не поглощается Catch. Для блокирующих системных вызовов остаются ограничения их отмены.
- Эта возможность не добавляет объявления типов Delegate, лямбды, указатели на функции DLL и ссылки на перегруженные процедуры. AddressOf пишется без UO.; игровые команды внутри обёртки сохраняют UO.

## Примеры

### 1. Отбор списка своей функцией

```vb
# values — входной List, predicate — ссылка AddressOf IsPositive. FilterValues вызывает predicate(number) по одному разу на число. IsPositive возвращает True только для положительных чисел; остаются 4 и 7. selected.Count() равно 2, selected[0] равно 4, поэтому Main возвращает "2:4". FilterValues и IsPositive полностью приведены в примере: это скриптовые помощники, а не отдельные команды API.
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

**Разбор параметров и выполнения:**

values — входной List, predicate — ссылка AddressOf IsPositive. FilterValues вызывает predicate(number) по одному разу на число. IsPositive возвращает True только для положительных чисел; остаются 4 и 7. selected.Count() равно 2, selected[0] равно 4, поэтому Main возвращает "2:4". FilterValues и IsPositive полностью приведены в примере: это скриптовые помощники, а не отдельные команды API.

### 2. Изменение переменной вызывающего кода

```vb
# AddAmount получает total по ByRef, amount по ByVal со значением по умолчанию 1. update(total) меняет 10 на 11. update.Invoke(amount:=4, total:=total) сопоставляет имена параметров и меняет 11 на 15. ByRef записывает результат в исходную переменную. Sub AddAmount значения не возвращает; Main возвращает Integer 15, а не Boolean.
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

**Разбор параметров и выполнения:**

AddAmount получает total по ByRef, amount по ByVal со значением по умолчанию 1. update(total) меняет 10 на 11. update.Invoke(amount:=4, total:=total) сопоставляет имена параметров и меняет 11 на 15. ByRef записывает результат в исходную переменную. Sub AddAmount значения не возвращает; Main возвращает Integer 15, а не Boolean.

### 3. Закрытая функция и обработка ошибки

```vb
# Rules.Create возвращает ссылку на Private CheckedDouble; снаружи напрямую взять AddressOf Rules.CheckedDouble нельзя. operation(6) возвращает 12. operation(-1) выбрасывает "negative" до присваивания, поэтому result остаётся 12. Catch получает сообщение, Finally добавляет ":done", Main возвращает "12:negative:done". Закрытие IDE само по себе не останавливает запущенный скрипт.
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

**Разбор параметров и выполнения:**

Rules.Create возвращает ссылку на Private CheckedDouble; снаружи напрямую взять AddressOf Rules.CheckedDouble нельзя. operation(6) возвращает 12. operation(-1) выбрасывает "negative" до присваивания, поэтому result остаётся 12. Catch получает сообщение, Finally добавляет ":done", Main возвращает "12:negative:done". Закрытие IDE само по себе не останавливает запущенный скрипт.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
