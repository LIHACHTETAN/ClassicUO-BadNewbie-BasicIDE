# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->

Читает файл JSON.

## Точный синтаксис

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

Выберите одну из зарегистрированных форм. Параметры передаются позиционно. Any означает значение BASIC с преобразованием внутри команды; Unit — отсутствие возвращаемого значения.

## Параметры

- `fileName` — Обязательный путь к файлу. Относительный путь отсчитывается от папки основного скрипта, даже при вызове из Include. Абсолютный путь допустим.
- `defaultValue` — Необязательный резерв: используется только при отсутствии файла или его папки. Возвращается независимая копия через JSON. Ошибки содержимого, кодировки и доступа не скрываются.

## Возвращает

Any: соответствие типов как у JsonParse. Без defaultValue отсутствие файла вызывает ошибку.

## Поведение

- Это локальные функции Basic без UO.; игровых пакетов не отправляют. JsonParse/JsonStringify работают в памяти. Basic True сохраняется как число 1; для JSON true нужен JsonBoolean(True). JsonNull() отличает null от 0.
- Числа должны быть конечными. Целые значения за пределами ±9007199254740991 отклоняются: большие ID храните строками. Остальные числа имеют точность Double. Кодировка строго UTF-8: входной BOM допустим, выходной отсутствует. Некорректный Unicode вызывает ошибку.
- Лимиты: 1048576 кодовых единиц UTF-16, 4 МиБ файла/выходных байтов, 64 вложенных контейнера и 100000 узлов значений. Превышение — ошибка. Разбор и загрузка создают новые коллекции; сохранение не клонирует объекты в памяти.
- Save проверяет всё содержимое, создаёт родительские папки, пишет уникальный временный файл рядом с назначением, сбрасывает буфер и перемещает/заменяет файл. Ошибка или отмена до замены сохраняет старый файл. Временный файл удаляется; ошибка очистки ОС может оставить его. Завершённая замена не откатывается.
- Пауза/стоп проверяются через 256 значений, между блоками чтения/записи по 4096 байт/символов и перед заменой. Отдельный поток записи не создаётся. Вызов ОС нельзя принудительно прервать. При одновременном сохранении остаётся последняя успешная замена; это не транзакция базы данных.

### Внутренние функции: от вызова до результата

Читает файл JSON.

#### 1. LoadCore

Обязательный путь к файлу. Относительный путь отсчитывается от папки основного скрипта, даже при вызове из Include. Абсолютный путь допустим. Необязательный резерв: используется только при отсутствии файла или его папки. Возвращается независимая копия через JSON. Ошибки содержимого, кодировки и доступа не скрываются.

Any: соответствие типов как у JsonParse. Без defaultValue отсутствие файла вызывает ошибку.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функция `LoadCore`.

Config.Load(fileName, defaults) возвращает новый Dictionary: сохранённые ключи верхнего уровня заменяют глубокую копию defaults. Вложенный объект заменяется целиком, рекурсивного слияния нет. Config.Save(fileName, settings) явно сохраняет и ничего не возвращает. Config.GetFlag(settings, key, fallback=False) возвращает 1/True или 0/False; существующее нелогическое значение вызывает ошибку. Config.SetFlag(settings, key, value) меняет только память и ничего не возвращает. Load/Save требуют Dictionary со строковыми ключами. Внутренняя RequireObject проверяет внешний тип; JSON-преобразование проверяет всё содержимое.


## Примеры

### Пример 1. JsonLoad · 1

```vb
# JsonLoad · 1
#
# Читает файл JSON.
#
# Any: соответствие типов как у JsonParse. Без defaultValue отсутствие файла вызывает ошибку.

Option Explicit On
Sub Main()
    # Запустите Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### Пример 2. JsonLoad · 2

```vb
# JsonLoad · 2
#
# Читает файл JSON.
#
# Any: соответствие типов как у JsonParse. Без defaultValue отсутствие файла вызывает ошибку.

Option Explicit On
Sub Main()
    # Запустите Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### Пример 3. JsonLoad · 3

```vb
# JsonLoad · 3
#
# Читает файл JSON.
#
# Any: соответствие типов как у JsonParse. Без defaultValue отсутствие файла вызывает ошибку.

Option Explicit On
Sub Main()
    # Запустите Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Разбор параметров и выполнения:**

- Запустите Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
