# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ru -->

Разбирает текст JSON в значения Basic.

## Точный синтаксис

```text
JsonParse(text:String) -> Any
```

## Параметры

- `text` — Обязательная строка JSON. Одно полное значение; ключи объекта уникальны и учитывают регистр. Комментарии и завершающая запятая вызывают ошибку.

## Возвращает

Any: объект→Dictionary, массив→List, строка→String, число→Integer или Decimal (Double), true/false→JsonBoolean, null→JsonNull. Это не признак успеха.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Разбирает текст JSON в значения Basic.

#### 1. Parse

Обязательная строка JSON. Одно полное значение; ключи объекта уникальны и учитывают регистр. Комментарии и завершающая запятая вызывают ошибку.

Any: объект→Dictionary, массив→List, строка→String, число→Integer или Decimal (Double), true/false→JsonBoolean, null→JsonNull. Это не признак успеха.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функция `Parse`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### JsonParse · 1

```vb
# JsonParse · 1
#
# Разбирает текст JSON в значения Basic.
#
# Any: объект→Dictionary, массив→List, строка→String, число→Integer или Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. Это не признак успеха.

Option Explicit On
Sub Main()
    # Запустите Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Разбирает текст JSON в значения Basic.
#
# Any: объект→Dictionary, массив→List, строка→String, число→Integer или Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. Это не признак успеха.

Option Explicit On
Sub Main()
    # Запустите Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null;
    # index2 → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Разбирает текст JSON в значения Basic.
#
# Any: объект→Dictionary, массив→List, строка→String, число→Integer или Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. Это не признак успеха.

Option Explicit On
Sub Main()
    # Запустите Main. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. text={"x":1,"x":2} → Catch → "duplicate key".
