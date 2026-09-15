# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Перетворює значення Basic на текст JSON.

## Точний синтаксис

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Параметри

- `value` — Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку.
- `indented` — Цілий прапорець: 0 — компактно, ненульове — з відступами. Типово Stringify=0, Save=1.

## Повертає

String із JSON, без створення файлу.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Перетворює значення Basic на текст JSON.

#### 1. Stringify

Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку. Цілий прапорець: 0 — компактно, ненульове — з відступами. Типово Stringify=0, Save=1.

String із JSON, без створення файлу.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функція `Stringify`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Перетворює значення Basic на текст JSON.
#
# String із JSON, без створення файлу.

Option Explicit On
Sub Main()
    # Запустіть Main. value=Dictionary(name="ore",count=3), indented=0 → String
    # {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Перетворює значення Basic на текст JSON.
#
# String із JSON, без створення файлу.

Option Explicit On
Sub Main()
    # Запустіть Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Перетворює значення Basic на текст JSON.
#
# String із JSON, без створення файлу.

Option Explicit On
Sub Main()
    # Запустіть Main. value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. value=List → value[0]=value → Catch → "cycle".
