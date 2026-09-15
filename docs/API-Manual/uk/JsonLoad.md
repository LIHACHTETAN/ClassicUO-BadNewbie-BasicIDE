# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Читає файл JSON.

## Точний синтаксис

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## Параметри

- `fileName` — Обов’язковий шлях. Відносні шляхи — від папки основного скрипту, також усередині Include. Абсолютні дозволені.
- `defaultValue` — Необов’язковий резерв лише за відсутності файлу чи папки. Повертається незалежна копія через JSON. Помилки даних, кодування й доступу не приховуються.

## Повертає

Any за правилами JsonParse. Відсутній файл без defaultValue — помилка.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Читає файл JSON.

#### 1. LoadCore

Обов’язковий шлях. Відносні шляхи — від папки основного скрипту, також усередині Include. Абсолютні дозволені. Необов’язковий резерв лише за відсутності файлу чи папки. Повертається незалежна копія через JSON. Помилки даних, кодування й доступу не приховуються.

Any за правилами JsonParse. Відсутній файл без defaultValue — помилка.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функція `LoadCore`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# Читає файл JSON.
#
# Any за правилами JsonParse. Відсутній файл без defaultValue — помилка.

Option Explicit On
Sub Main()
    # Запустіть Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# Читає файл JSON.
#
# Any за правилами JsonParse. Відсутній файл без defaultValue — помилка.

Option Explicit On
Sub Main()
    # Запустіть Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# Читає файл JSON.
#
# Any за правилами JsonParse. Відсутній файл без defaultValue — помилка.

Option Explicit On
Sub Main()
    # Запустіть Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
