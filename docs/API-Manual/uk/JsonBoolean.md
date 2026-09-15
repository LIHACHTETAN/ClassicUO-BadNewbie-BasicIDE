# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Створює явне логічне значення JSON.

## Точний синтаксис

```text
JsonBoolean(value:Any) -> Object
```

## Параметри

- `value` — Число або числовий рядок: нуль — false, ненульове — true. Basic True/False — 1/0; JSON Boolean читайте через flag.Value().

## Повертає

Об’єкт JsonBoolean записується як true/false. Value() повертає Integer1/True або 0/False для If; сам об’єкт не є числовим прапорцем.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Створює явне логічне значення JSON.

#### 1. BasicJsonBoolean

Число або числовий рядок: нуль — false, ненульове — true. Basic True/False — 1/0; JSON Boolean читайте через flag.Value().

Об’єкт JsonBoolean записується як true/false. Value() повертає Integer1/True або 0/False для If; сам об’єкт не є числовим прапорцем.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; функція `BasicJsonBoolean`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Створює явне логічне значення JSON.
#
# Об’єкт JsonBoolean записується як true/false. Value() повертає Integer1/True або 0/False для
# If; сам об’єкт не є числовим прапорцем.

Option Explicit On
Sub Main()
    # Запустіть Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Створює явне логічне значення JSON.
#
# Об’єкт JsonBoolean записується як true/false. Value() повертає Integer1/True або 0/False для
# If; сам об’єкт не є числовим прапорцем.

Option Explicit On
Sub Main()
    # Запустіть Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Створює явне логічне значення JSON.
#
# Об’єкт JsonBoolean записується як true/false. Value() повертає Integer1/True або 0/False для
# If; сам об’єкт не є числовим прапорцем.

Option Explicit On
Sub Main()
    # Запустіть Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
