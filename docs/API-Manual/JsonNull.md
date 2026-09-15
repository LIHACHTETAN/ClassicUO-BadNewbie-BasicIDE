# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->

Создаёт явное значение JSON null.

## Точный синтаксис

```text
JsonNull() -> Object
```

Выберите одну из зарегистрированных форм. Параметры передаются позиционно. Any означает значение BASIC с преобразованием внутри команды; Unit — отсутствие возвращаемого значения.

## Параметры

Параметров нет.

## Возвращает

Объект JsonNull: записывается как null. Это не ноль и не пустая строка. Проверка: JsonKind(value)="null".

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Создаёт явное значение JSON null.

#### 1. JsonNullObject



Объект JsonNull: записывается как null. Это не ноль и не пустая строка. Проверка: JsonKind(value)="null".

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; функция `JsonNullObject`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### Пример 1. JsonNull · 1

```vb
# JsonNull · 1
#
# Создаёт явное значение JSON null.
#
# Объект JsonNull: записывается как null. Это не ноль и не пустая строка. Проверка:
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Запустите Main. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. JsonNull() → Object; JsonStringify → String "null".

### Пример 2. JsonNull · 2

```vb
# JsonNull · 2
#
# Создаёт явное значение JSON null.
#
# Объект JsonNull: записывается как null. Это не ноль и не пустая строка. Проверка:
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Запустите Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### Пример 3. JsonNull · 3

```vb
# JsonNull · 3
#
# Создаёт явное значение JSON null.
#
# Объект JsonNull: записывается как null. Это не ноль и не пустая строка. Проверка:
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Запустите Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .
