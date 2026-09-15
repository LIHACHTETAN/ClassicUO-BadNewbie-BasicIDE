# JSON / Config.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Config.bas — готовий модуль із Scripts/Include. Помістіть Include/Config.bas поруч з основним скриптом та додайте Include "Config.bas". Налаштування JSON поєднуються з незалежними типовими значеннями.

## Точний синтаксис

```text
Include "Config.bas"
settings = Config.Load(fileName, defaults)
Config.Save(fileName, settings)
enabled = Config.GetFlag(settings, key, fallback=False)
Config.SetFlag(settings, key, value)
JsonParse(text) / JsonStringify(value[, indented=0])
JsonLoad(fileName[, defaultValue]) / JsonSave(fileName, value[, indented=1])
JsonKind(value) / JsonBoolean(value) / JsonNull() / flag.Value()
```

## Параметри

- `fileName` — Обов’язковий шлях. Відносні шляхи — від папки основного скрипту, також усередині Include. Абсолютні дозволені.
- `defaults (Config.Load)` — Обов’язковий Dictionary типових налаштувань для Config.Load. Його глибока JSON-копія поєднується зі збереженими верхніми ключами. Оригінал не змінюється. defaults не можна пропускати.
- `defaultValue (JsonLoad)` — Необов’язковий резерв лише за відсутності файлу чи папки. Повертається незалежна копія через JSON. Помилки даних, кодування й доступу не приховуються.
- `settings / value` — Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку.
- `indented` — Цілий прапорець: 0 — компактно, ненульове — з відступами. Типово Stringify=0, Save=1.
- `key / fallback` — Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.

## Повертає

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

## Приклади

### 1. Незалежні типові значення

```vb
# fileName=missing-settings.json, defaults має delay=350. За відсутності файлу Load копіює defaults. Зміна отриманого delay на 125 не змінює початкове 350. Результат "125:350". Приберіть попередній файл прикладу для перевірки відсутності.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim defaults=Dictionary()
    defaults["delay"]=350
    Dim settings=Config.Load("missing-settings.json", defaults)
    settings["delay"]=125
    Return CStr(settings["delay"]) & ":" & CStr(defaults["delay"])
End Sub
```

**Пояснення параметрів і виконання:**

fileName=missing-settings.json, defaults має delay=350. За відсутності файлу Load копіює defaults. Зміна отриманого delay на 125 не змінює початкове 350. Результат "125:350". Приберіть попередній файл прикладу для перевірки відсутності.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 2. Запис і повторне читання

```vb
# SetFlag зберігає JSON Boolean. Save створює/замінює demo-settings.json; Load читає його. GetFlag повертає Integer1, delay=350. Результат "1:350".
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["delay"]=350
    Config.SetFlag(settings, "enabled", True)
    Config.Save("demo-settings.json", settings)
    Dim loaded=Config.Load("demo-settings.json", Dictionary())
    Return CStr(Config.GetFlag(loaded, "enabled")) & ":" & CStr(loaded["delay"])
End Sub
```

**Пояснення параметрів і виконання:**

SetFlag зберігає JSON Boolean. Save створює/замінює demo-settings.json; Load читає його. GetFlag повертає Integer1, delay=350. Результат "1:350".

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 3. Перевірка прапорця

```vb
# enabled=1 — число, не JSON true. GetFlag відхиляє його; Catch повертає "invalid flag". SetFlag(settings,"enabled",True) встановив би правильний тип. Файл не змінюється.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["enabled"]=1
    Try
        Dim enabled=Config.GetFlag(settings, "enabled")
    Catch problem
        Return "invalid flag"
    End Try
    Return "unexpected"
End Sub
```

**Пояснення параметрів і виконання:**

enabled=1 — число, не JSON true. GetFlag відхиляє його; Catch повертає "invalid flag". SetFlag(settings,"enabled",True) встановив би правильний тип. Файл не змінюється.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

<!-- implementation references (not callable script procedures):
Runtime/BasicJson.cs: Parse / Read / Stringify / Write / LoadCore / Save / Resolve / Budget
Runtime/ObjectTypes/JsonPrimitiveObjects.cs: Value
src/ClassicUO.Client/Scripts/Include/Config.bas: RequireObject / Load / Save / GetFlag / SetFlag
https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-dom
-->
