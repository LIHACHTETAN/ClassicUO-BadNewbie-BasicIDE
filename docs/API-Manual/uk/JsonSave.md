# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Зберігає значення у файлі JSON.

## Точний синтаксис

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## Параметри

- `fileName` — Обов’язковий шлях. Відносні шляхи — від папки основного скрипту, також усередині Include. Абсолютні дозволені.
- `value` — Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку.
- `indented` — Цілий прапорець: 0 — компактно, ненульове — з відступами. Типово Stringify=0, Save=1.

## Повертає

Unit: значення немає. Звичайне завершення означає успіх; помилки — через Try/Catch.

## Поведінка

- Локальні функції Basic без UO., без ігрових пакетів. JsonParse/JsonStringify працюють у пам’яті. Basic True записується числом 1; JSON true потребує JsonBoolean(True). JsonNull() відокремлює null від 0.
- Лише скінченні числа. Цілі поза ±9007199254740991 — помилка; великі ID зберігайте рядками. Інші числа мають точність Double. Суворий UTF-8: вхідний BOM дозволено, вихідного немає. Некоректний Unicode — помилка.
- Ліміти:1048576 одиниць UTF-16, 4 МіБ байтів, 64 вкладені контейнери,100000 вузлів. Перевищення — помилка. Розбір/читання створює нові колекції; запис не клонує об’єкти пам’яті.
- Save перевіряє дані, створює папки, пише тимчасовий файл поруч, скидає буфер і переміщує/замінює його. Помилка/скасування до заміни залишає старий файл. Тимчасовий файл прибирається, якщо ОС дозволяє. Здійснену заміну не скасовує.
- Пауза/стоп перевіряються через 256 значень, між блоками 4096 байтів/символів та перед заміною. Нового потоку немає; виклик ОС не переривається примусово. Одночасні записи: остання успішна заміна перемагає; це не транзакція БД.

### Внутрішні функції: від виклику до результату

Зберігає значення у файлі JSON.

#### 1. Save

Обов’язковий шлях. Відносні шляхи — від папки основного скрипту, також усередині Include. Абсолютні дозволені. Число, String, масив, List, Dictionary, JsonBoolean або JsonNull. Ключі Dictionary — рядки. Спільні посилання дозволені, цикли спричиняють помилку. Цілий прапорець: 0 — компактно, ненульове — з відступами. Типово Stringify=0, Save=1.

Unit: значення немає. Звичайне завершення означає успіх; помилки — через Try/Catch.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; функція `Save`.

Config.Load(fileName, defaults) повертає новий Dictionary: збережені верхні ключі замінюють глибоку копію defaults. Вкладені об’єкти замінюються цілком. Config.Save(fileName, settings) явно зберігає, нічого не повертає. Config.GetFlag(settings, key, fallback=False) повертає 1/True чи 0/False; наявне нелогічне значення — помилка. Config.SetFlag(settings, key, value) змінює лише пам’ять, без результату. Load/Save потребують Dictionary із рядковими ключами. Private RequireObject перевіряє зовнішній тип, JSON — увесь вміст.


## Приклади

### JsonSave · 1

```vb
# JsonSave · 1
#
# Зберігає значення у файлі JSON.
#
# Unit: значення немає. Звичайне завершення означає успіх; помилки — через Try/Catch.

Option Explicit On
Sub Main()
    # Запустіть Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# Зберігає значення у файлі JSON.
#
# Unit: значення немає. Звичайне завершення означає успіх; помилки — через Try/Catch.

Option Explicit On
Sub Main()
    # Запустіть Main. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Пояснення параметрів і виконання:**

- Запустіть Main. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# Зберігає значення у файлі JSON.
#
# Unit: значення немає. Звичайне завершення означає успіх; помилки — через Try/Catch.

Option Explicit On
Sub Main()
    # Запустіть Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
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

**Пояснення параметрів і виконання:**

- Запустіть Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
