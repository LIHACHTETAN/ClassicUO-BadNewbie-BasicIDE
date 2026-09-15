# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Визначає сумісний із JSON різновид значення.

## Точний синтаксис

```text
JsonKind(value:Any) -> String
```

## Параметри

- `value` — Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку.

## Повертає

String: number, string, array, object, boolean, null або unsupported. Перевіряє лише зовнішній тип.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Визначає сумісний із JSON різновид значення.

#### 1. Kind

Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку.

String: number, string, array, object, boolean, null або unsupported. Перевіряє лише зовнішній тип.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функція `Kind`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonKind · 1

```vb
# JsonKind · 1
#
# Визначає сумісний із JSON різновид значення.
#
# String: number, string, array, object, boolean, null або unsupported. Перевіряє лише зовнішній
# тип.

Option Explicit On
Sub Main()
    # Запустіть Main. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Визначає сумісний із JSON різновид значення.
#
# String: number, string, array, object, boolean, null або unsupported. Перевіряє лише зовнішній
# тип.

Option Explicit On
Sub Main()
    # Запустіть Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Визначає сумісний із JSON різновид значення.
#
# String: number, string, array, object, boolean, null або unsupported. Перевіряє лише зовнішній
# тип.

Option Explicit On
Sub Main()
    # Запустіть Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
