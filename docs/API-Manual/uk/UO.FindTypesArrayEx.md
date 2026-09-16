# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

За один обхід шукає різні графіки, кольори й контейнери та повертає один ID. Повний список читається через GetFoundItems.

## Точний синтаксис

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## Параметри

- `ObjTypes` — Graphic/body, не serial предмета. 0..65534 — конкретна графіка; -1 або 0xFFFF — будь-яка. Інші від’ємні Integer теж знімають фільтр.
- `Colors` — Hue, не кількість предметів. 0 — без фарбування; -1 або 0xFFFF — будь-який hue. Інші від’ємні Integer також знімають фільтр.
- `Containers` — Земля: UO.Ground(), 0, -1, 0xFFFFFFFF або рядок ground. Наплічник: backpack або його serial. Приймаються десяткові/hex serial та імена AddObject. my обирає весь власний інвентар, включно зі спорядженням і вкладеними сумками. Невідоме ім’я спричиняє помилку скрипту. Перевіряйте отриманий serial: явний 0 обирає землю. Краще імена ground/backpack, бо числові позначення різняться між командами.
- `InSub` — Обов’язковий TRUE/FALSE (1/0). FALSE — прямий вміст конкретного контейнера; TRUE — також завантажені вкладені сумки. На землю не впливає. my вже обирає весь власний інвентар.

## Повертає

Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile — один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

## Поведінка

- Передайте Array; окреме значення теж приймається як один елемент. DIM values[1] створює індекси 0 і 1: заповніть кожен. Типи й кольори — незалежні варіанти, не пари за індексом. Будь-який wildcard або порожній масив типів/кольорів знімає відповідний фільтр. Порожній масив контейнерів обирає власний інвентар. Повтори й перетини контейнерів не дублюють ID.
- Потрібні всі чотири позиційні аргументи. Необов’язкових немає.
- Земля використовує FindDistance/FindVertical цього скрипту, виключає self, включає відповідні Item і Mobile. Конкретний контейнер не використовує ці межі відстані/висоти. Ignore та знищені об’єкти виключаються скрізь.
- Перед обходом очищаються FindItem, FindCount, FindFullQuantity і GetFoundItems. Порожній пошук залишає нулі й порожній масив. FindFullQuantity сумує max(1, Amount) предметів і по 1 для Mobile; FindQuantity читає поточну кількість FindItem. Збережіть GetFoundItems до наступного пошуку, якщо попередній список ще потрібний.
- Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.
- Лише отримані клієнтом дані. Контейнери не відкриваються, клітинки не завантажуються, перенесення немає. Порожній результат не доводить порожність скрині на сервері. Для активного з’єднання перевіряйте Connected; пошук читає локальний стан.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). Першоджерело описує останній ID і запасний наплічник за помилкового контейнера. Тут повертається перший локальний ID; невідоме ім’я не перемикає на наплічник. Ground приймає також 0; власний FindDistance має початкове 18 і максимум 255.

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

#### 4. BuildFindIdentityMask

Передайте Array; окреме значення теж приймається як один елемент. DIM values[1] створює індекси 0 і 1: заповніть кожен. Типи й кольори — незалежні варіанти, не пари за індексом. Будь-який wildcard або порожній масив типів/кольорів знімає відповідний фільтр. Порожній масив контейнерів обирає власний інвентар. Повтори й перетини контейнерів не дублюють ID.

Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `BuildFindIdentityMask`.

#### 5. FindTypes

Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.

Земля використовує FindDistance/FindVertical цього скрипту, виключає self, включає відповідні Item і Mobile. Конкретний контейнер не використовує ці межі відстані/висоти. Ignore та знищені об’єкти виключаються скрізь.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body, не serial предмета. 0..65534 — конкретна графіка; -1 або 0xFFFF — будь-яка. Інші від’ємні Integer теж знімають фільтр. Hue, не кількість предметів. 0 — без фарбування; -1 або 0xFFFF — будь-який hue. Інші від’ємні Integer також знімають фільтр.

Bridge раз обходить завантажені предмети, потім Mobile, якщо обрано землю. Мають збігтися тип, колір і хоча б один контейнер. Об’єкт реєструється один раз навіть за кількох збігів; повторного повного обходу для кожної комбінації немає.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `MatchesFindIdentity`.

#### 7. MatchesFindContainer

Обов’язковий TRUE/FALSE (1/0). FALSE — прямий вміст конкретного контейнера; TRUE — також завантажені вкладені сумки. На землю не впливає. my вже обирає весь власний інвентар.

Земля використовує FindDistance/FindVertical цього скрипту, виключає self, включає відповідні Item і Mobile. Конкретний контейнер не використовує ці межі відстані/висоти. Ignore та знищені об’єкти виключаються скрізь.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `MatchesFindContainer`.

#### 8. RegisterFound

Перед обходом очищаються FindItem, FindCount, FindFullQuantity і GetFoundItems. Порожній пошук залишає нулі й порожній масив. FindFullQuantity сумує max(1, Amount) предметів і по 1 для Mobile; FindQuantity читає поточну кількість FindItem. Збережіть GetFoundItems до наступного пошуку, якщо попередній список ще потрібний.

Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile — один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `RegisterFound`.

Лише отримані клієнтом дані. Контейнери не відкриваються, клітинки не завантажуються, перенесення немає. Порожній результат не доводить порожність скрині на сервері. Для активного з’єднання перевіряйте Connected; пошук читає локальний стан.


## Приклади

### Дві графіки на землі

```vb
# Дві графіки на землі
#
# За один обхід шукає різні графіки, кольори й контейнери та повертає один ID. Повний список
# читається через GetFoundItems.
#
# Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи
# Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile —
# один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

SUB Main()
    # types — золото 0x0EED і чорні перли 0x0F7A; color=-1 — будь-який hue; Ground — земля. FALSE її
    # не змінює. Діють поточні межі. Виводяться ID, об’єкти та одиниці.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Пояснення параметрів і виконання:**

- types — золото 0x0EED і чорні перли 0x0F7A; color=-1 — будь-який hue; Ground — земля. FALSE її не змінює. Діють поточні межі. Виводяться ID, об’єкти та одиниці.

### Золото в наплічнику й на землі

```vb
# Золото в наплічнику й на землі
#
# За один обхід шукає різні графіки, кольори й контейнери та повертає один ID. Повний список
# читається через GetFoundItems.
#
# Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи
# Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile —
# один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

SUB Main()
    # types — золото, colors — усі hue. Containers — backpack і земля; TRUE включає вкладені сумки.
    # Виводяться об’єкти/стоси та одиниці з обох областей без дублювання.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Пояснення параметрів і виконання:**

- types — золото, colors — усі hue. Containers — backpack і земля; TRUE включає вкладені сумки. Виводяться об’єкти/стоси та одиниці з обох областей без дублювання.

### Повна функція зі збереженим списком

```vb
# Повна функція зі збереженим списком
#
# За один обхід шукає різні графіки, кольори й контейнери та повертає один ID. Повний список
# читається через GetFoundItems.
#
# Integer: serial першого локального збігу або 0 без збігів. Не graphic, кількість, масив чи
# Boolean. Перевіряйте result <> 0, не result = TRUE чи result = 1. Стос — один об’єкт; Mobile —
# один об’єкт і одна одиниця. Порядок не означає близькість і не гарантується між пошуками.

SUB Main()
    # SearchTypesIn(container,firstType,secondType) повертає Array<Integer>, на відміну від одного
    # Integer ID вбудованої команди. Повний код заповнює масиви, шукає рекурсивно й копіює
    # GetFoundItems. Main перевіряє та виводить кожен ID.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**Пояснення параметрів і виконання:**

- SearchTypesIn(container,firstType,secondType) повертає Array<Integer>, на відміну від одного Integer ID вбудованої команди. Повний код заповнює масиви, шукає рекурсивно й копіює GetFoundItems. Main перевіряє та виводить кожен ID.
