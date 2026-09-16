# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Читає прапорці згоди; форма з трьома аргументами змінює власний прапорець.

## Точний синтаксис

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## Параметри

- `windowIndex` — Цілий поточний індекс вікна: 0..TradeCount()-1. Від’ємний/відсутній індекс дає порожній результат. Не serial.
- `TradeNum` — Цілий поточний індекс вікна: 0..TradeCount()-1. Від’ємний/відсутній індекс дає порожній результат. Не serial.
- `Num` — Лише форма з двома аргументами: 1 — власний прапорець, 2 — чужий; інші значення дають 0. TradeNum тут починається з 0.
- `checkbox` — Лише форма з трьома аргументами: 0 — свій прапорець, 1 — чужий. Чужий лише читається; інші значення дають 0.
- `stateValue` — Лише для checkbox=0: 0/FALSE знімає згоду, будь-яке ненульове число/TRUE вмикає. Для checkbox=1 ігнорується.

## Повертає

Integer: 1 = TRUE — вибраний прапорець установлений; 0 = FALSE — знятий, вікна немає або сторона неправильна. Запис повертає стан, не успіх обміну: зняття дає 0.

Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат: повторний виклик може повторити дію або прочитати змінений стан.

## Поведінка

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумерують вікна з 1; TradeContainer/TradeOpponent/TradeName і всі форми TradeCheck — з 0. Це збережені правила цього клієнта; зовнішні довідники різних рушіїв мають різні початки відліку.
- Читання виконується на ігровому потоці за живими вікнами поточного World. Закриті вікна виключено. Читання не надсилає пакетів і не чекає відповіді. Порядок UI може змінитися після відкриття, закриття або підняття вікна; індекс не є постійним ID.
- ConfirmTrade та запис власного TradeCheck надсилають пакет лише при зміні згоди. Чужий прапорець задає сервер. CancelTrade надсилає скасування один раз. 1/TRUE означає локальний стан/обробку, не завершення передачі. Імена й два прапорці не доводять незмінність предметів.

### Внутрішні функції: від виклику до результату

Нижче наведено шлях виклику C#, а потім виконувані приклади Basic. Скрипти не реалізують мережевий протокол заново.

#### 1. TradeCheck

Реєстрація вибирає форму за кількістю аргументів; NumberConversions перетворює числа. TradeCheck із двома аргументами перевіряє сторони 1/2 і переводить їх у 0/1 bridge. Legacy-serial форматує ToHex.

Integer: 1 = TRUE — вибраний прапорець установлений; 0 = FALSE — знятий, вікна немає або сторона неправильна. Запис повертає стан, не успіх обміну: зняття дає 0.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `TradeCheck`.

#### 2. TradeCheck

Invoke передає читання/запис на ігровий потік зі скасуванням скрипту; метод читає ID1/ID2, LocalSerial, OpponentName або прапорці вибраного TradingGump.

Читає прапорці згоди; форма з трьома аргументами змінює власний прапорець.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade перевіряє number>0 перед відніманням 1; FindTrade відхиляє від’ємний індекс і перебирає лише живі TradingGump поточного World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумерують вікна з 1; TradeContainer/TradeOpponent/TradeName і всі форми TradeCheck — з 0. Це збережені правила цього клієнта; зовнішні довідники різних рушіїв мають різні початки відліку.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindTrade`.

#### 4. AcceptTrade

Зміна власного прапорця викликає GameActions.AcceptTrade → Send_TradeResponse з кодом 2, ID1 і станом. Читання й повторне встановлення того самого стану пакетів не створюють.

Integer: 1 = TRUE — вибраний прапорець установлений; 0 = FALSE — знятий, вікна немає або сторона неправильна. Запис повертає стан, не успіх обміну: зняття дає 0.

Код проєкту: `src/ClassicUO.Client/Game/GameActions.cs`; функція `AcceptTrade`.

Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений serial персонажа, не перевірка ціни чи вмісту.


## Приклади

### Пряме читання або дія

```vb
# Пряме читання або дія
#
# Читає прапорці згоди; форма з трьома аргументами змінює власний прапорець.
#
# Integer: 1 = TRUE — вибраний прапорець установлений; 0 = FALSE — знятий, вікна немає або
# сторона неправильна. Запис повертає стан, не успіх обміну: зняття дає 0.
#
# Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF
# result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN
# або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат:
# повторний виклик може повторити дію або прочитати змінений стан.

SUB Main()
    # UO.TradeCheck(0) та UO.TradeCheck(0,1) читають власну згоду першого вікна; UO.TradeCheck(0,2)
    # — чужу. Запису й автоматичного підтвердження немає.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**Пояснення параметрів і виконання:**

- UO.TradeCheck(0) та UO.TradeCheck(0,1) читають власну згоду першого вікна; UO.TradeCheck(0,2) — чужу. Запису й автоматичного підтвердження немає.

### Інший сценарій і параметри

```vb
# Інший сценарій і параметри
#
# Читає прапорці згоди; форма з трьома аргументами змінює власний прапорець.
#
# Integer: 1 = TRUE — вибраний прапорець установлений; 0 = FALSE — знятий, вікна немає або
# сторона неправильна. Запис повертає стан, не успіх обміну: зняття дає 0.
#
# Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF
# result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN
# або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат:
# повторний виклик може повторити дію або прочитати змінений стан.

SUB Main()
    # UO.TradeCheck(0,0,FALSE) знімає власну згоду. UO.TradeCheck(0,1,FALSE) лише читає чужу: FALSE
    # не змінює партнера. Повернення 0 після зняття нормальне.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**Пояснення параметрів і виконання:**

- UO.TradeCheck(0,0,FALSE) знімає власну згоду. UO.TradeCheck(0,1,FALSE) лише читає чужу: FALSE не змінює партнера. Повернення 0 після зняття нормальне.

### Повний викликаний помічник

```vb
# Повний викликаний помічник
#
# Читає прапорці згоди; форма з трьома аргументами змінює власний прапорець.
#
# Integer: 1 = TRUE — вибраний прапорець установлений; 0 = FALSE — знятий, вікна немає або
# сторона неправильна. Запис повертає стан, не успіх обміну: зняття дає 0.
#
# Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF
# result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN
# або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат:
# повторний виклик може повторити дію або прочитати змінений стан.

SUB Main()
    # Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але
    # виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений
    # serial персонажа, не перевірка ціни чи вмісту.

    VAR accepted = BothAccepted(0)
    IF accepted = TRUE THEN
        UO.Print("Both boxes are checked; server completion is not known")
    END IF
END SUB

FUNCTION BothAccepted(index)
    IF index < 0 OR index >= UO.TradeCount() THEN
        RETURN FALSE
    END IF
    VAR own = UO.TradeCheck(index, 1)
    VAR other = UO.TradeCheck(index, 2)
    RETURN own = TRUE AND other = TRUE
END FUNCTION
```

**Пояснення параметрів і виконання:**

- Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений serial персонажа, не перевірка ціни чи вмісту.
