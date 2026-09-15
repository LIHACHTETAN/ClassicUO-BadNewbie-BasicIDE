# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Розбирає текст JSON у значення Basic.

## Точний синтаксис

```text
JsonParse(text:String) -> Any
```

## Параметри

- `text` — Обов’язковий рядок JSON: одне повне значення. Ключі унікальні з урахуванням регістру. Коментарі й кінцева кома заборонені.

## Повертає

Any: об’єкт→Dictionary, масив→List, рядок→String, число→Integer або Decimal (Double), true/false→JsonBoolean, null→JsonNull. Не ознака успіху.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Розбирає текст JSON у значення Basic.

#### 1. Parse

Обов’язковий рядок JSON: одне повне значення. Ключі унікальні з урахуванням регістру. Коментарі й кінцева кома заборонені.

Any: об’єкт→Dictionary, масив→List, рядок→String, число→Integer або Decimal (Double), true/false→JsonBoolean, null→JsonNull. Не ознака успіху.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функція `Parse`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonParse · 1

```vb
# JsonParse · 1
#
# Розбирає текст JSON у значення Basic.
#
# Any: об’єкт→Dictionary, масив→List, рядок→String, число→Integer або Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. Не ознака успіху.

Option Explicit On
Sub Main()
    # Запустіть Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Розбирає текст JSON у значення Basic.
#
# Any: об’єкт→Dictionary, масив→List, рядок→String, число→Integer або Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. Не ознака успіху.

Option Explicit On
Sub Main()
    # Запустіть Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null;
    # index2 → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Розбирає текст JSON у значення Basic.
#
# Any: об’єкт→Dictionary, масив→List, рядок→String, число→Integer або Decimal (Double),
# true/false→JsonBoolean, null→JsonNull. Не ознака успіху.

Option Explicit On
Sub Main()
    # Запустіть Main. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. text={"x":1,"x":2} → Catch → "duplicate key".
