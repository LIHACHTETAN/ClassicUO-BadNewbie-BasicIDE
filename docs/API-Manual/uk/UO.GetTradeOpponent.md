# UO.GetTradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Повертає числовий serial персонажа-партнера.

## Точний синтаксис

```text
UO.GetTradeOpponent(TradeNum:Any) -> Any
```

## Параметри

- `TradeNum` — Цілий поточний номер вікна: 1..TradeCount(). Нуль та від’ємні значення неправильні. Не serial.

## Повертає

Integer: serial персонажа з LocalSerial вікна; 0, якщо вікна немає. Не контейнер і не Boolean; перевіряйте <> 0.

## Поведінка

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумерують вікна з 1; TradeContainer/TradeOpponent/TradeName і всі форми TradeCheck — з 0. Це збережені правила цього клієнта; зовнішні довідники різних рушіїв мають різні початки відліку.
- Читання виконується на ігровому потоці за живими вікнами поточного World. Закриті вікна виключено. Читання не надсилає пакетів і не чекає відповіді. Порядок UI може змінитися після відкриття, закриття або підняття вікна; індекс не є постійним ID.
- ConfirmTrade та запис власного TradeCheck надсилають пакет лише при зміні згоди. Чужий прапорець задає сервер. CancelTrade надсилає скасування один раз. 1/TRUE означає локальний стан/обробку, не завершення передачі. Імена й два прапорці не доводять незмінність предметів.

### Внутрішні функції: від виклику до результату

Нижче наведено шлях виклику C#, а потім виконувані приклади Basic. Скрипти не реалізують мережевий протокол заново.

#### 1. ExecuteStealthCompatibility

Реєстрація вибирає форму за кількістю аргументів; NumberConversions перетворює числа. TradeCheck із двома аргументами перевіряє сторони 1/2 і переводить їх у 0/1 bridge. Legacy-serial форматує ToHex.

Integer: serial персонажа з LocalSerial вікна; 0, якщо вікна немає. Не контейнер і не Boolean; перевіряйте <> 0.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponent

Invoke передає читання/запис на ігровий потік зі скасуванням скрипту; метод читає ID1/ID2, LocalSerial, OpponentName або прапорці вибраного TradingGump.

Повертає числовий serial персонажа-партнера.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `GetTradeOpponent`.

#### 3. FindNumberedTrade

FindNumberedTrade перевіряє number>0 перед відніманням 1; FindTrade відхиляє від’ємний індекс і перебирає лише живі TradingGump поточного World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумерують вікна з 1; TradeContainer/TradeOpponent/TradeName і всі форми TradeCheck — з 0. Це збережені правила цього клієнта; зовнішні довідники різних рушіїв мають різні початки відліку.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindNumberedTrade`.

Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений serial персонажа, не перевірка ціни чи вмісту.


## Приклади

### Пряме читання або дія

```vb
# Пряме читання або дія
#
# Повертає числовий serial персонажа-партнера.
#
# Integer: serial персонажа з LocalSerial вікна; 0, якщо вікна немає. Не контейнер і не Boolean;
# перевіряйте <> 0.

SUB Main()
    # Виклик один, value/result зберігає результат. 0 — перший індекс, 1 — перший номер (див.
    # синтаксис). HEX показує числовий serial; CStr — число чи текст.

    VAR value = UO.GetTradeOpponent(1)
    UO.Print(HEX(value))
END SUB
```

**Пояснення параметрів і виконання:**

- Виклик один, value/result зберігає результат. 0 — перший індекс, 1 — перший номер (див. синтаксис). HEX показує числовий serial; CStr — число чи текст.

### Інший сценарій і параметри

```vb
# Інший сценарій і параметри
#
# Повертає числовий serial персонажа-партнера.
#
# Integer: serial персонажа з LocalSerial вікна; 0, якщо вікна немає. Не контейнер і не Boolean;
# перевіряйте <> 0.

SUB Main()
    # total зберігає кількість вікон; index — поточний індекс/номер. Перебір не підтверджує обмін. У
    # прикладі GetTradeContainer читається свій (1) і чужий (2) контейнер вікна 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponent(index)
        UO.Print(CStr(index) + ": " + HEX(value))
    NEXT
END SUB
```

**Пояснення параметрів і виконання:**

- total зберігає кількість вікон; index — поточний індекс/номер. Перебір не підтверджує обмін. У прикладі GetTradeContainer читається свій (1) і чужий (2) контейнер вікна 1.

### Повний викликаний помічник

```vb
# Повний викликаний помічник
#
# Повертає числовий serial персонажа-партнера.
#
# Integer: serial персонажа з LocalSerial вікна; 0, якщо вікна немає. Не контейнер і не Boolean;
# перевіряйте <> 0.

SUB Main()
    # Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але
    # виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений
    # serial персонажа, не перевірка ціни чи вмісту.

    VAR value = ReadTradeValue(1)
    UO.Print(HEX(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 1 OR index >= total + 1 THEN
        RETURN 0
    END IF
    RETURN UO.GetTradeOpponent(index)
END FUNCTION
```

**Пояснення параметрів і виконання:**

- Помічник повністю визначений і викликається з Main. Перевірки меж/ID зменшують помилки, але виклики не атомарні: вікно може змінитися між ними. Для дії expectedPartner — збережений serial персонажа, не перевірка ціни чи вмісту.
