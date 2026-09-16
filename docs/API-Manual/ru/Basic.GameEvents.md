# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

AddHandler автоматически подключает обработчик новых сообщений журнала, изменения ресурсов персонажа и подключения. Имена UO. здесь обозначают события, а не функции: вызывать их со скобками или через RaiseEvent нельзя.

## Точный синтаксис

```text
AddHandler UO.JournalEntry, AddressOf OnJournal
Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
AddHandler UO.HitPointsChanged, AddressOf OnHits
AddHandler UO.ManaChanged, AddressOf OnMana
AddHandler UO.StaminaChanged, AddressOf OnStamina
Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
AddHandler UO.ConnectionChanged, AddressOf OnConnection
Sub OnConnection(ByVal online As Boolean)
RemoveHandler UO.JournalEntry, AddressOf OnJournal
```

## Параметры

- `Handler / AddressOf` — Передайте AddressOf процедуры Sub этого загруженного скрипта. Все параметры явно ByVal, с точными типами и порядком из сигнатуры. Function, Optional, ParamArray и обработчик другого скрипта не подходят.
- `text / serial / name / hue` — JournalEntry передаёт text String — текст, serial Integer — ID источника, name String — имя, hue Integer — индекс оттенка UO. Serial не является графикой/type предмета; неизвестный источник — 0. Hue не RGB. Текст и имя могут быть пустыми. Значения копируются до повторного использования записи журнала. Передаются только новые записи после подписки, включая локальные сообщения.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged передают current и previous Integer — новое и предыдущее количество очков, не проценты и не Boolean. Сравниваются снимки игрока при обновлении клиента; несколько изменений между обновлениями могут объединиться. Начальное состояние и другой персонаж становятся исходной точкой без уведомления о потере ресурсов.
- `online` — ConnectionChanged передаёт online Boolean: True/1 — в игровом мире есть персонаж и карта, False/0 — нет. Это состояние мира клиента, а не проверка исправности сетевого соединения. Начальное состояние событием не повторяется.
- `RemoveHandler` — RemoveHandler удаляет последнее подключение этой процедуры. Повторные подключения вызываются повторно, по порядку. Для текущего сообщения используется снимок обработчиков; изменения подписки действуют на следующие сообщения. Удаление последнего обработчика освобождает очередь события.

## Возвращает

AddHandler и RemoveHandler возвращают Unit: значения нет. Обработчик Sub также ничего не возвращает. Результаты сохраняйте в общих полях Module. Только online и логический IsReadyMessage используют 1/0 = True/False. Serial, hue, очки ресурсов и State.changes — идентификаторы или количества.

## Поведение

- Клиент только ставит копии данных в очередь. Обработчик выполняется в потоке своего скрипта, без параллельного исполнения с ним: между операторами и внутри Wait, Sleep, UO.Wait, Wait Until. Проверка очередей — не чаще раза в 25 мс, до 16 сообщений каждого события за проход. Долгая внешняя функция может задержать доставку.
- На паузе сообщения накапливаются, обработчики не вызываются. Stop отменяет выполнение и освобождает подписки; Catch не перехватывает аварийную отмену. Возврат или ошибка главной процедуры удаляют игровые подписки, новый запуск начинается без них. Закрытие IDE не останавливает работающий скрипт. Автопауза при отключении задержит событие отключения до продолжения.
- Очередь каждого события ограничена 256 сообщениями. Переполнение вызывает перехватываемую ошибку и отключает эту подписку, без молчаливой потери сообщений. Ошибка обработчика тоже отключает событие и пропускает оставшиеся обработчики текущего сообщения. В Catch/Finally можно убрать подписку и подключиться заново. Не печатайте каждое сообщение журнала обратно в этот же журнал.
- Поддерживаются именно эти пять событий в Full с включённой Basic IDE. Другие события, подписка на пакеты, Handles и WithEvents этим не добавляются. События, которые объявляет сам скрипт, описаны отдельно в Basic.Events.

## Примеры

### 1. Найти новое сообщение журнала

```vb
# OnJournal получает все четыре параметра. Полностью показанный IsReadyMessage использует InStr: позиция больше 0 означает наличие фразы. Локальное сообщение запускает обработчик, State сохраняет String. Wait Until ожидает до 5000 мс, затем выдаёт ошибку таймаута. Finally отключает обработчик при успехе и ошибке. Main возвращает "ready: ore".
Option Explicit On
Module State
    Public Dim matched As Boolean = False
    Public Dim message As String = ""
End Module

Function IsReadyMessage(ByVal text As String) As Boolean
    Return InStr(text, "ready: ore") > 0
End Function

Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
    If IsReadyMessage(text) Then
        State.message = text
        State.matched = True
    End If
End Sub

Sub Main()
    AddHandler UO.JournalEntry, AddressOf OnJournal
    Try
        UO.AddToJournal("ready: ore")
        Wait Until State.matched Timeout 5000
    Finally
        RemoveHandler UO.JournalEntry, AddressOf OnJournal
    End Try
    Return State.message
End Sub
```

**Разбор параметров и выполнения:**

OnJournal получает все четыре параметра. Полностью показанный IsReadyMessage использует InStr: позиция больше 0 означает наличие фразы. Локальное сообщение запускает обработчик, State сохраняет String. Wait Until ожидает до 5000 мс, затем выдаёт ошибку таймаута. Finally отключает обработчик при успехе и ошибке. Main возвращает "ready: ore".

### 2. Следить за ресурсами

```vb
# Три обработчика передают current/previous в полностью показанную Remember. State.changes считает уведомления; State.last хранит последнее, например SP:58:60. Wait(250) отдаёт время обработчикам, затем Wait Until ждёт изменение до 5000 мс. Если изменений нет — таймаут. Finally снимает три подписки. Возвращается String, а не логический признак успеха.
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim last As String = ""
End Module

Sub Remember(ByVal label As String, ByVal current As Integer, ByVal previous As Integer)
    State.changes += 1
    State.last = label & ":" & CStr(current) & ":" & CStr(previous)
End Sub

Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
    Remember("HP", current, previous)
End Sub

Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
    Remember("MP", current, previous)
End Sub

Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
    Remember("SP", current, previous)
End Sub

Sub Main()
    AddHandler UO.HitPointsChanged, AddressOf OnHits
    AddHandler UO.ManaChanged, AddressOf OnMana
    AddHandler UO.StaminaChanged, AddressOf OnStamina
    Try
        Wait(250)
        Wait Until State.changes > 0 Timeout 5000
    Finally
        RemoveHandler UO.HitPointsChanged, AddressOf OnHits
        RemoveHandler UO.ManaChanged, AddressOf OnMana
        RemoveHandler UO.StaminaChanged, AddressOf OnStamina
    End Try
    Return State.last
End Sub
```

**Разбор параметров и выполнения:**

Три обработчика передают current/previous в полностью показанную Remember. State.changes считает уведомления; State.last хранит последнее, например SP:58:60. Wait(250) отдаёт время обработчикам, затем Wait Until ждёт изменение до 5000 мс. Если изменений нет — таймаут. Finally снимает три подписки. Возвращается String, а не логический признак успеха.

### 3. Следить за подключением и отключить обработчик

```vb
# OnConnection принимает Boolean online и считает переходы за Wait(1000). Finally отключает подписку. Main возвращает количество: 0 — изменений не было, 1 — один переход и так далее. Здесь 1 — количество, не True. State.online хранит последнее полученное состояние, а не начальный запрос.
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim online As Boolean = False
End Module

Sub OnConnection(ByVal online As Boolean)
    State.online = online
    State.changes += 1
End Sub

Sub Main()
    AddHandler UO.ConnectionChanged, AddressOf OnConnection
    Try
        Wait(1000)
    Finally
        RemoveHandler UO.ConnectionChanged, AddressOf OnConnection
    End Try
    Return State.changes
End Sub
```

**Разбор параметров и выполнения:**

OnConnection принимает Boolean online и считает переходы за Wait(1000). Finally отключает подписку. Main возвращает количество: 0 — изменений не было, 1 — один переход и так далее. Здесь 1 — количество, не True. State.online хранит последнее полученное состояние, а не начальный запрос.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
