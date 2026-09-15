# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->

Сохраняет значение в файл JSON.

## Точный синтаксис

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

Выберите одну из зарегистрированных форм. Параметры передаются позиционно. Any означает значение BASIC с преобразованием внутри команды; Unit — отсутствие возвращаемого значения.

## Параметры

- `fileName` — Обязательный путь к файлу. Относительный путь отсчитывается от папки основного скрипта, даже при вызове из Include. Абсолютный путь допустим.
- `value` — Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка.
- `indented` — Целочисленный флаг: 0 — компактная запись, ненулевое значение — отступы. По умолчанию Stringify=0, Save=1.

## Возвращает

Unit: значения нет. Успех — обычное завершение; ошибку обрабатывает Try/Catch.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Сохраняет значение в файл JSON.

#### 1. Save

Обязательный путь к файлу. Относительный путь отсчитывается от папки основного скрипта, даже при вызове из Include. Абсолютный путь допустим. Значение: число, String, массив, List, Dictionary, JsonBoolean или JsonNull. Ключи Dictionary — строки. Общие ссылки допустимы, циклические — ошибка. Целочисленный флаг: 0 — компактная запись, ненулевое значение — отступы. По умолчанию Stringify=0, Save=1.

Unit: значения нет. Успех — обычное завершение; ошибку обрабатывает Try/Catch.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функция `Save`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### Пример 1. JsonSave · 1

```vb
# JsonSave · 1
#
# Сохраняет значение в файл JSON.
#
# Unit: значения нет. Успех — обычное завершение; ошибку обрабатывает Try/Catch.

Option Explicit On
Sub Main()
    # Запустите Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### Пример 2. JsonSave · 2

```vb
# JsonSave · 2
#
# Сохраняет значение в файл JSON.
#
# Unit: значения нет. Успех — обычное завершение; ошибку обрабатывает Try/Catch.

Option Explicit On
Sub Main()
    # Запустите Main. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### Пример 3. JsonSave · 3

```vb
# JsonSave · 3
#
# Сохраняет значение в файл JSON.
#
# Unit: значения нет. Успех — обычное завершение; ошибку обрабатывает Try/Catch.

Option Explicit On
Sub Main()
    # Запустите Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
