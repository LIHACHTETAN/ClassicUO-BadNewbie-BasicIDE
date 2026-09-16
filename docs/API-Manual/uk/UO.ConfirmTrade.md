# UO.ConfirmTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Установлює власну згоду у вибраному обміні.

## Точний синтаксис

```text
UO.ConfirmTrade(TradeNum:Any) -> Any
```

## Параметри

- `TradeNum` — Цілий поточний номер вікна: 1..TradeCount(). Нуль та від’ємні значення неправильні. Не serial.

## Повертає

Integer: 1 = TRUE — вікно є, власну згоду встановлено або вже було встановлено; 0 = FALSE — вікна немає. Не підтверджує завершення сервером. Повторення не знімає згоду.

Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат: повторний виклик може повторити дію або прочитати змінений стан.

## Поведінка

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумерують вікна з 1; TradeContainer/TradeOpponent/TradeName і всі форми TradeCheck — з 0. Це збережені правила цього клієнта; зовнішні довідники різних рушіїв мають різні початки відліку.
- Читання виконується на ігровому потоці за живими вікнами поточного World. Закриті вікна виключено. Читання не надсилає пакетів і не чекає відповіді. Порядок UI може змінитися після відкриття, закриття або підняття вікна; індекс не є постійним ID.
- ConfirmTrade та запис власного TradeCheck надсилають пакет лише при зміні згоди. Чужий прапорець задає сервер. CancelTrade надсилає скасування один раз. 1/TRUE означає локальний стан/обробку, не завершення передачі. Імена й два прапорці не доводять незмінність предметів.

### Внутрішні функції: від виклику до результату

Нижче наведено шлях виклику C#, а потім виконувані приклади Basic. Скрипти не реалізують мережевий протокол заново.

#### 1. ExecuteStealthCompatibility

Реєстрація вибирає форму за кількістю аргументів; NumberConversions перетворює числа. TradeCheck із двома аргументами перевіряє сторони 1/2 і переводить їх у 0/1 bridge. Legacy-serial форматує ToHex.

Integer: 1 = TRUE — вікно є, власну згоду встановлено або вже було встановлено; 0 = FALSE — вікна немає. Не підтверджує завершення сервером. Повторення не знімає згоду.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ExecuteStealthCompatibility`.

#### 2. ConfirmTrade

Invoke передає читання/запис на ігровий потік зі скасуванням скрипту; метод читає ID1/ID2, LocalSerial, OpponentName або прапорці вибраного TradingGump.

Установлює власну згоду у вибраному обміні.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `ConfirmTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade перевіряє number>0 перед відніманням 1; FindTrade відхиляє від’ємний індекс і перебирає лише живі TradingGump поточного World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумерують вікна з 1; TradeContainer/TradeOpponent/TradeName і всі форми TradeCheck — з 0. Це збережені правила цього клієнта; зовнішні довідники різних рушіїв мають різні початки відліку.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindNumberedTrade`.

#### 4. AcceptTrade

Зміна власного прапорця викликає GameActions.AcceptTrade → Send_TradeResponse з кодом 2, ID1 і станом. Читання й повторне встановлення того самого стану пакетів не створюють.

Integer: 1 = TRUE — вікно є, власну згоду встановлено або вже було встановлено; 0 = FALSE — вікна немає. Не підтверджує завершення сервером. Повторення не знімає згоду.

Код проєкту: `src/ClassicUO.Client/Game/GameActions.cs`; функція `AcceptTrade`.

Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений serial персонажа, не перевірка ціни чи вмісту.


## Приклади

### Пряме читання або дія

```vb
# Пряме читання або дія
#
# Установлює власну згоду у вибраному обміні.
#
# Integer: 1 = TRUE — вікно є, власну згоду встановлено або вже було встановлено; 0 = FALSE —
# вікна немає. Не підтверджує завершення сервером. Повторення не знімає згоду.
#
# Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF
# result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN
# або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат:
# повторний виклик може повторити дію або прочитати змінений стан.

SUB Main()
    # Виклик один, value/result зберігає результат. 0 — перший індекс, 1 — перший номер (див.
    # синтаксис). HEX показує числовий serial; CStr — число чи текст.

    VAR result = UO.ConfirmTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**Пояснення параметрів і виконання:**

- Виклик один, value/result зберігає результат. 0 — перший індекс, 1 — перший номер (див. синтаксис). HEX показує числовий serial; CStr — число чи текст.

### Інший сценарій і параметри

```vb
# Інший сценарій і параметри
#
# Установлює власну згоду у вибраному обміні.
#
# Integer: 1 = TRUE — вікно є, власну згоду встановлено або вже було встановлено; 0 = FALSE —
# вікна немає. Не підтверджує завершення сервером. Повторення не знімає згоду.
#
# Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF
# result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN
# або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат:
# повторний виклик може повторити дію або прочитати змінений стан.

SUB Main()
    # ConfirmTrade та запис власного TradeCheck надсилають пакет лише при зміні згоди. Чужий
    # прапорець задає сервер. CancelTrade надсилає скасування один раз. 1/TRUE означає локальний
    # стан/обробку, не завершення передачі. Імена й два прапорці не доводять незмінність предметів.

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.ConfirmTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**Пояснення параметрів і виконання:**

- ConfirmTrade та запис власного TradeCheck надсилають пакет лише при зміні згоди. Чужий прапорець задає сервер. CancelTrade надсилає скасування один раз. 1/TRUE означає локальний стан/обробку, не завершення передачі. Імена й два прапорці не доводять незмінність предметів.

### Повний викликаний помічник

```vb
# Повний викликаний помічник
#
# Установлює власну згоду у вибраному обміні.
#
# Integer: 1 = TRUE — вікно є, власну згоду встановлено або вже було встановлено; 0 = FALSE —
# вікна немає. Не підтверджує завершення сервером. Повторення не знімає згоду.
#
# Це логічний результат: 1 = TRUE, 0 = FALSE. Після VAR result = команда(...) можна писати IF
# result = TRUE THEN або IF result = 1 THEN; для негативного результату — IF result = FALSE THEN
# або IF result = 0 THEN. TRUE/FALSE без лапок. Викличте команду один раз і збережіть результат:
# повторний виклик може повторити дію або прочитати змінений стан.

SUB Main()
    # Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але
    # виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений
    # serial персонажа, не перевірка ціни чи вмісту.

    VAR expectedPartner = UO.GetTradeOpponent(1)
    VAR result = ApplyToPartner(1, expectedPartner)
    UO.Print(CStr(result))
END SUB

FUNCTION ApplyToPartner(tradeNumber, expectedPartner)
    IF expectedPartner = 0 THEN
        RETURN FALSE
    END IF
    IF UO.GetTradeOpponent(tradeNumber) <> expectedPartner THEN
        RETURN FALSE
    END IF
    RETURN UO.ConfirmTrade(tradeNumber)
END FUNCTION
```

**Пояснення параметрів і виконання:**

- Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений serial персонажа, не перевірка ціни чи вмісту.
