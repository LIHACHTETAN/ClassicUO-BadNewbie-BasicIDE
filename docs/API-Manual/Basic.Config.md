# JSON / Config.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Config.bas — готовый модуль настроек из Scripts/Include. Положите Include/Config.bas рядом с основным скриптом и напишите Include "Config.bas". Модуль объединяет JSON-файл с независимыми настройками по умолчанию.

## Точный синтаксис

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

## Параметры

- `fileName` — Обязательный путь к файлу. Относительный путь отсчитывается от папки основного скрипта, даже при вызове из Include. Абсолютный путь допустим.
- `defaults (Config.Load)` — Обязательный Dictionary настроек по умолчанию для Config.Load. Его глубокая JSON-копия объединяется с сохранёнными верхними ключами. Исходник не меняется. Пропускать defaults нельзя.
- `defaultValue (JsonLoad)` — Необязательный резерв: используется только при отсутствии файла или его папки. Возвращается независимая копия через JSON. Ошибки содержимого, кодировки и доступа не скрываются.
- `settings / value` — Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка.
- `indented` — Целочисленный флаг: 0 — компактная запись, ненулевое значение — отступы. По умолчанию Stringify=0, Save=1.
- `key / fallback` — Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.

## Возвращает

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

## Примеры

### 1. Независимые значения по умолчанию

```vb
# fileName — missing-settings.json; defaults содержит delay=350. При отсутствии файла используются defaults. Изменение возвращённого delay на 125 оставляет исходное 350. Итог — "125:350". Для проверки отсутствующего файла удалите или переименуйте файл прежнего примера.
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

**Разбор параметров и выполнения:**

fileName — missing-settings.json; defaults содержит delay=350. При отсутствии файла используются defaults. Изменение возвращённого delay на 125 оставляет исходное 350. Итог — "125:350". Для проверки отсутствующего файла удалите или переименуйте файл прежнего примера.

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

### 2. Сохранение и повторное чтение

```vb
# fileName — demo-settings.json. SetFlag создаёт JSON Boolean; Save создаёт или заменяет этот учебный файл. Load читает его снова. GetFlag получает Integer1, delay=350; Main возвращает "1:350".
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

**Разбор параметров и выполнения:**

fileName — demo-settings.json. SetFlag создаёт JSON Boolean; Save создаёт или заменяет этот учебный файл. Load читает его снова. GetFlag получает Integer1, delay=350; Main возвращает "1:350".

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

### 3. Проверка типа флага

```vb
# Значение enabled=1 в памяти — число, не JSON true. GetFlag отклоняет его; Catch возвращает "invalid flag". Config.SetFlag(settings,"enabled",True) установил бы правильный тип. Файл не изменяется.
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

**Разбор параметров и выполнения:**

Значение enabled=1 в памяти — число, не JSON true. GetFlag отклоняет его; Catch возвращает "invalid flag". Config.SetFlag(settings,"enabled",True) установил бы правильный тип. Файл не изменяется.

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
