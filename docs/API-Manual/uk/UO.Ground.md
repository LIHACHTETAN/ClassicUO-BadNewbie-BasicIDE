# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Повертає спеціальне позначення землі для параметра контейнера пошуку або місця призначення перенесення.

## Точний синтаксис

```text
UO.Ground() -> Integer
```

## Параметри

Параметрів немає.

## Повертає

Integer, завжди 0. Це коректне позначення землі, не FALSE, не помилка пошуку, не ID, graphic, номер карти чи координата. Перевіряйте успіх пошуку або перенесення, а не Ground().

## Поведінка

- Параметрів немає. Ground() сам нічого не шукає, не рухає, не відкриває target, не надсилає пакетів і не змінює попередніх результатів. До входу в гру теж повертає 0.
- Передавайте в container/destination команд FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx або MoveItem. Пошук бачить завантажені об’єкти, а не завантажує далекі клітинки. X/Y/Z перенесення на землю — світові координати, не пікселі контейнера.
- FindType(type, color) шукає в інвентарі: другий параметр — колір. Для землі: FindType(type, color, UO.Ground()). Старі компактні FindType/MoveItem використовують -1 для інвентаря; сумісні FindTypeEx/FindTypesArrayEx/CountEx також приймають -1 як землю. Краще UO.Ground() або явне ground, ніж переносити числові позначення між різними командами.
- Першоджерело: [Stealth Ground](https://stealth.od.ua/api/Ground/). Наведені домовленості й приклади стосуються цього клієнта.

### Внутрішні функції: від виклику до результату

Справжні внутрішні етапи. FindGroundTypes — повна функція скрипту, не додаткова вбудована команда.

#### 1. ExecuteStealthCompatibility

Виклик runtime без аргументів повертає Integer 0 без ігрового bridge.

Integer, завжди 0. Це коректне позначення землі, не FALSE, не помилка пошуку, не ID, graphic, номер карти чи координата. Перевіряйте успіх пошуку або перенесення, а не Ground().

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

Компактний пошук перетворює явний 0 на внутрішнє позначення землі, залишаючи -1 інвентарем. Сумісний пошук приймає 0 та історичний -1 для землі; імена контейнерів визначаються окремо.

FindType(type, color) шукає в інвентарі: другий параметр — колір. Для землі: FindType(type, color, UO.Ground()). Старі компактні FindType/MoveItem використовують -1 для інвентаря; сумісні FindTypeEx/FindTypesArrayEx/CountEx також приймають -1 як землю. Краще UO.Ground() або явне ground, ніж переносити числові позначення між різними командами.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

Компактний пошук перетворює явний 0 на внутрішнє позначення землі, залишаючи -1 інвентарем. Сумісний пошук приймає 0 та історичний -1 для землі; імена контейнерів визначаються окремо.

FindType(type, color) шукає в інвентарі: другий параметр — колір. Для землі: FindType(type, color, UO.Ground()). Старі компактні FindType/MoveItem використовують -1 для інвентаря; сумісні FindTypeEx/FindTypesArrayEx/CountEx також приймають -1 як землю. Краще UO.Ground() або явне ground, ніж переносити числові позначення між різними командами.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

Обробник перенесення залишає землю як 0. Bridge використовує світові координати; поле контейнера у пакеті викидання — 0xFFFFFFFF. API й пакет мають різні представлення.

Замініть 0x40001001 на serial доступного предмета. IsObjectExists перевіряє завантажений об’єкт. MoveItem(item, amount, destination, X, Y, Z): amount=0 — цілий стос; Ground() — земля; GetX/GetY/GetZ — світова клітинка персонажа. result=1 означає прийняття запиту клієнтом, 0 — відмову; це не результат Ground() і не підтвердження сервера.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ResolveTransferDestination`.

#### 5. MoveItem

Обробник перенесення залишає землю як 0. Bridge використовує світові координати; поле контейнера у пакеті викидання — 0xFFFFFFFF. API й пакет мають різні представлення.

Замініть 0x40001001 на serial доступного предмета. IsObjectExists перевіряє завантажений об’єкт. MoveItem(item, amount, destination, X, Y, Z): amount=0 — цілий стос; Ground() — земля; GetX/GetY/GetZ — світова клітинка персонажа. result=1 означає прийняття запиту клієнтом, 0 — відмову; це не результат Ground() і не підтвердження сервера.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `MoveItem`.

Параметрів немає. Ground() сам нічого не шукає, не рухає, не відкриває target, не надсилає пакетів і не змінює попередніх результатів. До входу в гру теж повертає 0.


## Приклади

### Прочитати позначення

```vb
# Прочитати позначення
#
# Повертає спеціальне позначення землі для параметра контейнера пошуку або місця призначення
# перенесення.
#
# Integer, завжди 0. Це коректне позначення землі, не FALSE, не помилка пошуку, не ID, graphic,
# номер карти чи координата. Перевіряйте успіх пошуку або перенесення, а не Ground().

SUB Main()
    # destination отримує Integer 0, Print показує число. Нічого не викидається.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**Пояснення параметрів і виконання:**

- destination отримує Integer 0, Print показує число. Нічого не викидається.

### Знайти стос золота на землі

```vb
# Знайти стос золота на землі
#
# Повертає спеціальне позначення землі для параметра контейнера пошуку або місця призначення
# перенесення.
#
# Integer, завжди 0. Це коректне позначення землі, не FALSE, не помилка пошуку, не ID, graphic,
# номер карти чи координата. Перевіряйте успіх пошуку або перенесення, а не Ground().

SUB Main()
    # 0x0EED — графіка золота; другий -1 — будь-який hue. Ground() обирає світ, FALSE вимикає
    # рекурсію. FindTypeEx повертає serial або 0; <> 0 перевіряє цей serial. Діють
    # FindDistance/FindVertical та Ignore.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**Пояснення параметрів і виконання:**

- 0x0EED — графіка золота; другий -1 — будь-який hue. Ground() обирає світ, FALSE вимикає рекурсію. FindTypeEx повертає serial або 0; <> 0 перевіряє цей serial. Діють FindDistance/FindVertical та Ignore.

### Повна функція пошуку двох графік

```vb
# Повна функція пошуку двох графік
#
# Повертає спеціальне позначення землі для параметра контейнера пошуку або місця призначення
# перенесення.
#
# Integer, завжди 0. Це коректне позначення землі, не FALSE, не помилка пошуку, не ID, graphic,
# номер карти чи координата. Перевіряйте успіх пошуку або перенесення, а не Ground().

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) шукає золото 0x0EED та чорні перли
    # 0x0F7A з radius=5 і height=10. DIM types[1] створює дві комірки, colors[0] і containers[0] —
    # по одній. Цілий стос — один результат; типи/кольори є альтернативами, перетини контейнерів не
    # дублюють ID. Повертається збережений масив serial; Finally відновлює обидві межі. Main показує
    # кожен ID. Функцію наведено повністю.

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Пояснення параметрів і виконання:**

- FindGroundTypes(firstType, secondType, radius, height) шукає золото 0x0EED та чорні перли 0x0F7A з radius=5 і height=10. DIM types[1] створює дві комірки, colors[0] і containers[0] — по одній. Цілий стос — один результат; типи/кольори є альтернативами, перетини контейнерів не дублюють ID. Повертається збережений масив serial; Finally відновлює обидві межі. Main показує кожен ID. Функцію наведено повністю.

### Перенести предмет на клітинку персонажа

```vb
# Перенести предмет на клітинку персонажа
#
# Повертає спеціальне позначення землі для параметра контейнера пошуку або місця призначення
# перенесення.
#
# Integer, завжди 0. Це коректне позначення землі, не FALSE, не помилка пошуку, не ID, graphic,
# номер карти чи координата. Перевіряйте успіх пошуку або перенесення, а не Ground().

SUB Main()
    # Замініть 0x40001001 на serial доступного предмета. IsObjectExists перевіряє завантажений
    # об’єкт. MoveItem(item, amount, destination, X, Y, Z): amount=0 — цілий стос; Ground() — земля;
    # GetX/GetY/GetZ — світова клітинка персонажа. result=1 означає прийняття запиту клієнтом, 0 —
    # відмову; це не результат Ground() і не підтвердження сервера.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**Пояснення параметрів і виконання:**

- Замініть 0x40001001 на serial доступного предмета. IsObjectExists перевіряє завантажений об’єкт. MoveItem(item, amount, destination, X, Y, Z): amount=0 — цілий стос; Ground() — земля; GetX/GetY/GetZ — світова клітинка персонажа. result=1 означає прийняття запиту клієнтом, 0 — відмову; це не результат Ground() і не підтвердження сервера.
