# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Створює явне значення JSON null.

## Точний синтаксис

```text
JsonNull() -> Object
```

## Параметри

Параметрів немає.

## Повертає

Об’єкт JsonNull, який записується як null, не 0 чи порожній рядок. Перевірка: JsonKind(value)="null".

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Створює явне значення JSON null.

#### 1. JsonNullObject



Об’єкт JsonNull, який записується як null, не 0 чи порожній рядок. Перевірка: JsonKind(value)="null".

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; функція `JsonNullObject`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonNull · 1

```vb
# JsonNull · 1
#
# Створює явне значення JSON null.
#
# Об’єкт JsonNull, який записується як null, не 0 чи порожній рядок. Перевірка:
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Запустіть Main. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# Створює явне значення JSON null.
#
# Об’єкт JsonNull, який записується як null, не 0 чи порожній рядок. Перевірка:
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Запустіть Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# Створює явне значення JSON null.
#
# Об’єкт JsonNull, який записується як null, не 0 чи порожній рядок. Перевірка:
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Запустіть Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .
