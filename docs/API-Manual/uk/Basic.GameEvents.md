# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

AddHandler підключає обробник нових записів журналу, зміни ресурсів персонажа та підключення. Імена UO. тут є подіями, а не функціями: їх не можна викликати через дужки чи RaiseEvent.

## Точний синтаксис

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

## Параметри

- `Handler / AddressOf` — Передайте AddressOf процедури Sub цього завантаженого скрипту. Усі параметри явно ByVal; типи й порядок точно відповідають сигнатурі. Function, Optional, ParamArray та чужі обробники не підтримуються.
- `text / serial / name / hue` — JournalEntry: text String — текст, serial Integer — ID джерела (0 за відсутності), name String — ім’я, hue Integer — індекс відтінку UO, не RGB. Serial не є графікою/type. Текст та ім’я можуть бути порожніми. Дані копіюються до повторного використання запису. Надходять лише нові записи після підписки, зокрема локальні.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged: current і previous Integer — нова й попередня кількість очок, не відсотки чи Boolean. Знімки порівнюються під час оновлення клієнта; проміжні зміни можуть об’єднуватися. Початковий стан та інший персонаж задають нову базу без повідомлення про зміну ресурсів.
- `online` — ConnectionChanged: online Boolean, True/1 — світ містить персонажа й карту, False/0 — ні. Це стан світу клієнта, не перевірка мережевого сокета. Початкової події немає.
- `RemoveHandler` — RemoveHandler видаляє останню відповідну підписку. Дублікати викликаються повторно, за порядком. Поточне повідомлення використовує знімок обробників, зміни впливають на наступні. Видалення останнього обробника звільняє чергу.

## Повертає

AddHandler/RemoveHandler та Sub не повертають значення: Unit. Результат зберігайте в полях Module. Тільки online та логічні перевірки використовують 1/0 = True/False; serial, hue, очки й State.changes — ID або кількості.

## Поведінка

- Клієнт ставить копії даних у чергу, обробник працює у потоці скрипту, без паралельного виконання: між операторами та всередині Wait, Sleep, UO.Wait, Wait Until. Перевірка не частіше разу на 25 мс, до 16 повідомлень події за прохід. Тривалий зовнішній виклик затримує доставку.
- Пауза накопичує повідомлення без виклику обробників. Stop скасовує виконання та звільняє підписки; Catch не поглинає аварійне скасування. Завершення чи помилка головної процедури очищує підписки; новий запуск починається без них. Закриття IDE не зупиняє скрипт. Автопауза при відключенні затримує подію до продовження.
- Ліміт — 256 повідомлень на подію. Переповнення дає перехоплювану помилку та відключає підписку. Помилка обробника теж відключає подію й пропускає решту обробників цього повідомлення. Після Catch/Finally можна підписатися знову. Не друкуйте кожен запис назад у той самий журнал.
- Ці п’ять подій доступні у Full з увімкненою Basic IDE. Інші події, пакети, Handles та WithEvents не додаються. Події самого скрипту описано в Basic.Events.

## Приклади

### 1. Знайти новий запис

```vb
# OnJournal отримує чотири параметри. Повна функція IsReadyMessage перевіряє InStr > 0. Локальне повідомлення запускає обробник, State зберігає рядок. Wait Until має ліміт 5000 мс та помилку таймауту. Finally знімає підписку. Main повертає "ready: ore".
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

**Пояснення параметрів і виконання:**

OnJournal отримує чотири параметри. Повна функція IsReadyMessage перевіряє InStr > 0. Локальне повідомлення запускає обробник, State зберігає рядок. Wait Until має ліміт 5000 мс та помилку таймауту. Finally знімає підписку. Main повертає "ready: ore".

### 2. Спостерігати за ресурсами

```vb
# Три обробники передають current/previous у повну Remember. State.changes рахує повідомлення, State.last зберігає останнє, наприклад SP:58:60. Після Wait(250) Wait Until чекає до 5000 мс; без змін буде таймаут. Finally знімає всі підписки. Результат String, не Boolean.
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

**Пояснення параметрів і виконання:**

Три обробники передають current/previous у повну Remember. State.changes рахує повідомлення, State.last зберігає останнє, наприклад SP:58:60. Після Wait(250) Wait Until чекає до 5000 мс; без змін буде таймаут. Finally знімає всі підписки. Результат String, не Boolean.

### 3. Спостерігати за підключенням

```vb
# OnConnection приймає Boolean online та рахує переходи протягом Wait(1000). Finally відключає його. Main повертає кількість: 0 — змін немає, 1 — один перехід, не True. State.online — останнє отримане значення, не початковий запит.
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

**Пояснення параметрів і виконання:**

OnConnection приймає Boolean online та рахує переходи протягом Wait(1000). Finally відключає його. Main повертає кількість: 0 — змін немає, 1 — один перехід, не True. State.online — останнє отримане значення, не початковий запит.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
