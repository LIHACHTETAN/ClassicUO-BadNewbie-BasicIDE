# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->

Создаёт явное логическое значение JSON.

## Точный синтаксис

```text
JsonBoolean(value:Any) -> Object
```

Выберите одну из зарегистрированных форм. Параметры передаются позиционно. Any означает значение BASIC с преобразованием внутри команды; Unit — отсутствие возвращаемого значения.

## Параметры

- `value` — Число или числовая строка: ноль — false, ненулевое — true. Basic True/False — это 1/0; прочитанный JSON Boolean извлекайте через flag.Value().

## Возвращает

Объект JsonBoolean: записывается как true/false. Метод Value() возвращает Integer 1/True или 0/False для If. Сам объект не подставляйте вместо числового флага.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Создаёт явное логическое значение JSON.

#### 1. BasicJsonBoolean

Число или числовая строка: ноль — false, ненулевое — true. Basic True/False — это 1/0; прочитанный JSON Boolean извлекайте через flag.Value().

Объект JsonBoolean: записывается как true/false. Метод Value() возвращает Integer 1/True или 0/False для If. Сам объект не подставляйте вместо числового флага.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; функция `BasicJsonBoolean`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### Пример 1. JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Создаёт явное логическое значение JSON.
#
# Объект JsonBoolean: записывается как true/false. Метод Value() возвращает Integer 1/True или
# 0/False для If. Сам объект не подставляйте вместо числового флага.

Option Explicit On
Sub Main()
    # Запустите Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### Пример 2. JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Создаёт явное логическое значение JSON.
#
# Объект JsonBoolean: записывается как true/false. Метод Value() возвращает Integer 1/True или
# 0/False для If. Сам объект не подставляйте вместо числового флага.

Option Explicit On
Sub Main()
    # Запустите Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### Пример 3. JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Создаёт явное логическое значение JSON.
#
# Объект JsonBoolean: записывается как true/false. Метод Value() возвращает Integer 1/True или
# 0/False для If. Сам объект не подставляйте вместо числового флага.

Option Explicit On
Sub Main()
    # Запустите Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
