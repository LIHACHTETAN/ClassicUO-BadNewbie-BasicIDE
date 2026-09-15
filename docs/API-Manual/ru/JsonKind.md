# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ru -->

Определяет совместимый с JSON вид значения.

## Точный синтаксис

```text
JsonKind(value:Any) -> String
```

## Параметры

- `value` — Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка.

## Возвращает

String: number, string, array, object, boolean, null или unsupported. Проверяет внешний вид значения, а не всё вложенное содержимое.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Определяет совместимый с JSON вид значения.

#### 1. Kind

Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка.

String: number, string, array, object, boolean, null или unsupported. Проверяет внешний вид значения, а не всё вложенное содержимое.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функция `Kind`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### JsonKind · 1

```vb
# JsonKind · 1
#
# Определяет совместимый с JSON вид значения.
#
# String: number, string, array, object, boolean, null или unsupported. Проверяет внешний вид
# значения, а не всё вложенное содержимое.

Option Explicit On
Sub Main()
    # Запустите Main. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Определяет совместимый с JSON вид значения.
#
# String: number, string, array, object, boolean, null или unsupported. Проверяет внешний вид
# значения, а не всё вложенное содержимое.

Option Explicit On
Sub Main()
    # Запустите Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Определяет совместимый с JSON вид значения.
#
# String: number, string, array, object, boolean, null или unsupported. Проверяет внешний вид
# значения, а не всё вложенное содержимое.

Option Explicit On
Sub Main()
    # Запустите Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
