# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Шукає одну графіку та колір у контейнері чи на землі й повертає один знайдений ID.

## Точний синтаксис

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## Параметри

- `ObjType` — Graphic/body, не serial предмета. 0..65534 — конкретна графіка; -1 або 0xFFFF — будь-яка. Інші від’ємні Integer теж знімають фільтр.
- `Color` — Hue, не кількість предметів. 0 — без фарбування; -1 або 0xFFFF — будь-який hue. Інші від’ємні Integer також знімають фільтр.
- `Container` — Земля: UO.Ground(), 0, -1, 0xFFFFFFFF або рядок ground. Наплічник: backpack або його serial. Приймаються десяткові/hex serial та імена AddObject. my обирає весь власний інвентар, включно зі спорядженням і вкладеними сумками. Невідоме ім’я спричиняє помилку скрипту. Перевіряйте отриманий serial: явний 0 обирає землю. Краще імена ground/backpack, бо числові позначення різняться між командами.
- `InSub` — Обов’язковий TRUE/FALSE (1/0). FALSE — прямий вміст конкретного контейнера; TRUE — також завантажені вкладені сумки. На землю не впливає. my вже обирає весь власний інвентар.

## Повертає

Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile — один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

## Поведінка

- Потрібні всі чотири позиційні аргументи. Необов’язкових немає.
- Земля використовує FindDistance/FindVertical цього скрипту, виключає self, включає відповідні Item і Mobile. Конкретний контейнер не використовує ці межі відстані/висоти. Ignore та знищені об’єкти виключаються скрізь.
- Перед обходом очищаються FindItem, FindCount, FindFullQuantity і GetFoundItems. Порожній пошук залишає нулі й порожній масив. FindFullQuantity сумує max(1, Amount) предметів і по 1 для Mobile; FindQuantity читає поточну кількість FindItem. Збережіть GetFoundItems до наступного пошуку, якщо попередній список ще потрібний.
- Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.
- Лише отримані клієнтом дані. Контейнери не відкриваються, клітинки не завантажуються, перенесення немає. Порожній результат не доводить порожність скрині на сервері. Для активного з’єднання перевіряйте Connected; пошук читає локальний стан.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). Першоджерело описує останній ID і запасний наплічник за помилкового контейнера. Тут повертається перший локальний ID; невідоме ім’я не перемикає на наплічник. Ground приймає також 0; власний FindDistance має початкове 18 і максимум 255.

### Внутрішні функції: від виклику до результату

Справжні етапи реалізації, не додаткові команди. FindGoldNearSelf та SearchTypesIn нижче наведені повністю як функції скрипту.

#### 1. ExecuteStealthCompatibility

Runtime перетворює числові фільтри й окремо розпізнає імена контейнерів; земля стає внутрішньою областю світу bridge.

Потрібні всі чотири позиційні аргументи. Необов’язкових немає.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

Земля: UO.Ground(), 0, -1, 0xFFFFFFFF або рядок ground. Наплічник: backpack або його serial. Приймаються десяткові/hex serial та імена AddObject. my обирає весь власний інвентар, включно зі спорядженням і вкладеними сумками. Невідоме ім’я спричиняє помилку скрипту. Перевіряйте отриманий serial: явний 0 обирає землю. Краще імена ground/backpack, бо числові позначення різняться між командами.

Runtime перетворює числові фільтри й окремо розпізнає імена контейнерів; земля стає внутрішньою областю світу bridge.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

Перед обходом очищаються FindItem, FindCount, FindFullQuantity і GetFoundItems. Порожній пошук залишає нулі й порожній масив. FindFullQuantity сумує max(1, Amount) предметів і по 1 для Mobile; FindQuantity читає поточну кількість FindItem. Збережіть GetFoundItems до наступного пошуку, якщо попередній список ще потрібний.

Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile — один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `ResetFindResults`.

#### 4. FindType

Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.

Земля використовує FindDistance/FindVertical цього скрипту, виключає self, включає відповідні Item і Mobile. Конкретний контейнер не використовує ці межі відстані/висоти. Ignore та знищені об’єкти виключаються скрізь.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindType`.

#### 5. MatchesFindIdentity

Graphic/body, не serial предмета. 0..65534 — конкретна графіка; -1 або 0xFFFF — будь-яка. Інші від’ємні Integer теж знімають фільтр. Hue, не кількість предметів. 0 — без фарбування; -1 або 0xFFFF — будь-який hue. Інші від’ємні Integer також знімають фільтр.

Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `MatchesFindIdentity`.

#### 6. MatchesFindContainer

Обов’язковий TRUE/FALSE (1/0). FALSE — прямий вміст конкретного контейнера; TRUE — також завантажені вкладені сумки. На землю не впливає. my вже обирає весь власний інвентар.

Земля використовує FindDistance/FindVertical цього скрипту, виключає self, включає відповідні Item і Mobile. Конкретний контейнер не використовує ці межі відстані/висоти. Ignore та знищені об’єкти виключаються скрізь.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `MatchesFindContainer`.

#### 7. RegisterFound

Перед обходом очищаються FindItem, FindCount, FindFullQuantity і GetFoundItems. Порожній пошук залишає нулі й порожній масив. FindFullQuantity сумує max(1, Amount) предметів і по 1 для Mobile; FindQuantity читає поточну кількість FindItem. Збережіть GetFoundItems до наступного пошуку, якщо попередній список ще потрібний.

Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile — один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `RegisterFound`.

Лише отримані клієнтом дані. Контейнери не відкриваються, клітинки не завантажуються, перенесення немає. Порожній результат не доводить порожність скрині на сервері. Для активного з’єднання перевіряйте Connected; пошук читає локальний стан.


## Приклади

### Прямий вміст наплічника

```vb
# Прямий вміст наплічника
#
# Шукає одну графіку та колір у контейнері чи на землі й повертає один знайдений ID.
#
# Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи
# Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile —
# один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

SUB Main()
    # 0x0EED — золото; -1 — будь-який hue; backpack/FALSE виключає вкладені сумки. Виводяться перший
    # hex ID без 0x, число об’єктів і сума одиниць. Стоси 20 і 50 дають 2 об’єкти та 70 одиниць.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Пояснення параметрів і виконання:**

- 0x0EED — золото; -1 — будь-який hue; backpack/FALSE виключає вкладені сумки. Виводяться перший hex ID без 0x, число об’єктів і сума одиниць. Стоси 20 і 50 дають 2 об’єкти та 70 одиниць.

### Повна функція тимчасового пошуку на землі

```vb
# Повна функція тимчасового пошуку на землі
#
# Шукає одну графіку та колір у контейнері чи на землі й повертає один знайдений ID.
#
# Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи
# Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile —
# один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

SUB Main()
    # radius=5, height=10 діють у FindGoldNearSelf. Finally відновлює обидві межі навіть при Return
    # чи помилці. Повертається serial золота або 0; Main перевіряє <> 0.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Пояснення параметрів і виконання:**

- radius=5, height=10 діють у FindGoldNearSelf. Finally відновлює обидві межі навіть при Return чи помилці. Повертається serial золота або 0; Main перевіряє <> 0.

### Ім’я контейнера та вкладені сумки

```vb
# Ім’я контейнера та вкладені сумки
#
# Шукає одну графіку та колір у контейнері чи на землі й повертає один знайдений ID.
#
# Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи
# Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile —
# один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

SUB Main()
    # GetSerial розпізнає backpack; перевірка нуля запобігає випадковому вибору землі. AddObject
    # зберігає ID як search_bag. TRUE включає вкладення. GetFoundItems копіює список; IsObjectExists
    # перевіряє кожен ID.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**Пояснення параметрів і виконання:**

- GetSerial розпізнає backpack; перевірка нуля запобігає випадковому вибору землі. AddObject зберігає ID як search_bag. TRUE включає вкладення. GetFoundItems копіює список; IsObjectExists перевіряє кожен ID.
