# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ru -->

Преобразует значения Basic в текст JSON.

## Точный синтаксис

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Параметры

- `value` — Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка.
- `indented` — Целочисленный флаг: 0 — компактная запись, ненулевое значение — отступы. По умолчанию Stringify=0, Save=1.

## Возвращает

String с текстом JSON. Файл не создаётся.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Преобразует значения Basic в текст JSON.

#### 1. Stringify

Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка. Целочисленный флаг: 0 — компактная запись, ненулевое значение — отступы. По умолчанию Stringify=0, Save=1.

String с текстом JSON. Файл не создаётся.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функция `Stringify`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Преобразует значения Basic в текст JSON.
#
# String с текстом JSON. Файл не создаётся.

Option Explicit On
Sub Main()
    # Запустите Main. value=Dictionary(name="ore",count=3), indented=0 → String
    # {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Преобразует значения Basic в текст JSON.
#
# String с текстом JSON. Файл не создаётся.

Option Explicit On
Sub Main()
    # Запустите Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Преобразует значения Basic в текст JSON.
#
# String с текстом JSON. Файл не создаётся.

Option Explicit On
Sub Main()
    # Запустите Main. value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=List → value[0]=value → Catch → "cycle".
