# UO.GetTradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ru -->

Возвращает числовой serial персонажа-партнёра.

## Точный синтаксис

```text
UO.GetTradeOpponent(TradeNum:Any) -> Any
```

## Параметры

- `TradeNum` — Целое число: текущий номер окна от 1 до TradeCount(). 0 и отрицательные значения недопустимы. Это не serial.

## Возвращает

Integer: serial персонажа из LocalSerial окна; 0 при отсутствии окна. Не контейнер и не Boolean; проверяйте <> 0.

## Поведение

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумеруют окна с 1; TradeContainer/TradeOpponent/TradeName и все формы TradeCheck — с 0. Это явная совместимость данного клиента: внешние справочники разных движков используют разные начала отсчёта.
- Чтение выполняется на игровом потоке по живым окнам текущего мира. Закрытые окна не считаются. Вызовы чтения не отправляют пакетов и не ждут ответа. Порядок UI может меняться при открытии, закрытии и переносе окна наверх; номер не является постоянным идентификатором.
- ConfirmTrade и запись своего TradeCheck отправляют пакет только при изменении согласия. Чужое согласие задаёт сервер. CancelTrade отправляет отмену один раз. 1/TRUE — локальное состояние/обработка, а не гарантия завершения обмена. Имена и оба согласия не доказывают, что состав предметов не изменился.

### Внутренние функции: от вызова до результата

Ниже — путь вызова в C#. После него приведены исполняемые Basic-примеры; это не попытка заново реализовать сетевой протокол в скрипте.

#### 1. ExecuteStealthCompatibility

Регистрация выбирает форму по числу аргументов; числа преобразуются через NumberConversions. Для TradeCheck с двумя аргументами стороны 1/2 проверяются и переводятся в 0/1 bridge. Legacy-serial форматируется через ToHex.

Integer: serial персонажа из LocalSerial окна; 0 при отсутствии окна. Не контейнер и не Boolean; проверяйте <> 0.

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функция `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponent

Invoke передаёт чтение/изменение на игровой поток с отменой скрипта; метод читает ID1/ID2, LocalSerial, OpponentName или флажки выбранного TradingGump.

Возвращает числовой serial персонажа-партнёра.

Исходник проекта: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функция `GetTradeOpponent`.

#### 3. FindNumberedTrade

FindNumberedTrade проверяет number>0 до вычитания 1; FindTrade отклоняет отрицательный индекс и перечисляет только незакрытые TradingGump текущего World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade нумеруют окна с 1; TradeContainer/TradeOpponent/TradeName и все формы TradeCheck — с 0. Это явная совместимость данного клиента: внешние справочники разных движков используют разные начала отсчёта.

Исходник проекта: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функция `FindNumberedTrade`.

Помощник приведён полностью и действительно вызывается из Main. Проверки диапазона/ID снижают риск ошибки, но несколько вызовов не атомарны: окно может смениться между ними. Для действия expectedPartner — сохранённый serial персонажа; это не проверка цены или содержимого обмена.


## Примеры

### Прямое чтение или действие

```vb
# Прямое чтение или действие
#
# Возвращает числовой serial персонажа-партнёра.
#
# Integer: serial персонажа из LocalSerial окна; 0 при отсутствии окна. Не контейнер и не
# Boolean; проверяйте <> 0.

SUB Main()
    # Вызов сделан один раз, результат сохранён в value/result. 0 — первый индекс, 1 — первый номер
    # (см. синтаксис этой команды). HEX показывает числовой serial; CStr — число или строку.

    VAR value = UO.GetTradeOpponent(1)
    UO.Print(HEX(value))
END SUB
```

**Разбор параметров и выполнения:**

- Вызов сделан один раз, результат сохранён в value/result. 0 — первый индекс, 1 — первый номер (см. синтаксис этой команды). HEX показывает числовой serial; CStr — число или строку.

### Другой сценарий и параметры

```vb
# Другой сценарий и параметры
#
# Возвращает числовой serial персонажа-партнёра.
#
# Integer: serial персонажа из LocalSerial окна; 0 при отсутствии окна. Не контейнер и не
# Boolean; проверяйте <> 0.

SUB Main()
    # total — снимок числа окон; index — текущий индекс/номер. Пример перебора ничего не
    # подтверждает. В GetTradeContainer два вызова читают свой контейнер (1) и чужой (2) первого
    # окна (1).

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponent(index)
        UO.Print(CStr(index) + ": " + HEX(value))
    NEXT
END SUB
```

**Разбор параметров и выполнения:**

- total — снимок числа окон; index — текущий индекс/номер. Пример перебора ничего не подтверждает. В GetTradeContainer два вызова читают свой контейнер (1) и чужой (2) первого окна (1).

### Полный помощник со всеми функциями

```vb
# Полный помощник со всеми функциями
#
# Возвращает числовой serial персонажа-партнёра.
#
# Integer: serial персонажа из LocalSerial окна; 0 при отсутствии окна. Не контейнер и не
# Boolean; проверяйте <> 0.

SUB Main()
    # Помощник приведён полностью и действительно вызывается из Main. Проверки диапазона/ID снижают
    # риск ошибки, но несколько вызовов не атомарны: окно может смениться между ними. Для действия
    # expectedPartner — сохранённый serial персонажа; это не проверка цены или содержимого обмена.

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

**Разбор параметров и выполнения:**

- Помощник приведён полностью и действительно вызывается из Main. Проверки диапазона/ID снижают риск ошибки, но несколько вызовов не атомарны: окно может смениться между ними. Для действия expectedPartner — сохранённый serial персонажа; это не проверка цены или содержимого обмена.
