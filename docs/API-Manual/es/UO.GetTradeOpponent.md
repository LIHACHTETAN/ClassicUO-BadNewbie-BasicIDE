# UO.GetTradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee el serial numérico del personaje con quien intercambia.

## Sintaxis exacta

```text
UO.GetTradeOpponent(TradeNum:Any) -> Any
```

## Parámetros

- `TradeNum` — Número entero actual: 1..TradeCount(). Cero/negativos inválidos. No es serial.

## Devuelve

Integer: serial del personaje desde LocalSerial; 0 sin ventana. No es contenedor ni Boolean; comprobar <> 0.

## Comportamiento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.
- Lee en el hilo del juego las ventanas vivas del World actual, excluyendo las cerradas. Leer no envía paquetes ni espera respuestas. Abrir, cerrar o traer al frente cambia el orden UI; el índice no es un ID permanente.
- ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

### Funciones internas: de la llamada al resultado

Se explica la ruta C# y después se muestran ejemplos Basic ejecutables. Los scripts no reimplementan el protocolo de red.

#### 1. ExecuteStealthCompatibility

El registro selecciona según cantidad de argumentos; NumberConversions convierte números. TradeCheck de dos argumentos valida 1/2 y los transforma en 0/1 del bridge. ToHex formatea serials heredados.

Integer: serial del personaje desde LocalSerial; 0 sin ventana. No es contenedor ni Boolean; comprobar <> 0.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponent

Invoke lleva lectura/escritura al hilo del juego con cancelación del script; lee ID1/ID2, LocalSerial, OpponentName o casillas del TradingGump seleccionado.

Lee el serial numérico del personaje con quien intercambia.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetTradeOpponent`.

#### 3. FindNumberedTrade

FindNumberedTrade comprueba number>0 antes de restar 1; FindTrade rechaza índices negativos y enumera solo TradingGump abiertos de este World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindNumberedTrade`.

La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.


## Ejemplos

### Lectura o acción directa

```vb
# Lectura o acción directa
#
# Lee el serial numérico del personaje con quien intercambia.
#
# Integer: serial del personaje desde LocalSerial; 0 sin ventana. No es contenedor ni Boolean;
# comprobar <> 0.

SUB Main()
    # Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver
    # sintaxis). HEX muestra serials numéricos; CStr números o texto.

    VAR value = UO.GetTradeOpponent(1)
    UO.Print(HEX(value))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver sintaxis). HEX muestra serials numéricos; CStr números o texto.

### Otro escenario y parámetros

```vb
# Otro escenario y parámetros
#
# Lee el serial numérico del personaje con quien intercambia.
#
# Integer: serial del personaje desde LocalSerial; 0 sin ventana. No es contenedor ni Boolean;
# comprobar <> 0.

SUB Main()
    # total guarda la cantidad de ventanas; index es el índice/número actual. Enumerar no confirma
    # nada. GetTradeContainer lee los contenedores propio (1) y ajeno (2) de la ventana 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponent(index)
        UO.Print(CStr(index) + ": " + HEX(value))
    NEXT
END SUB
```

**Explicación de los parámetros y la ejecución:**

- total guarda la cantidad de ventanas; index es el índice/número actual. Enumerar no confirma nada. GetTradeContainer lee los contenedores propio (1) y ajeno (2) de la ventana 1.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Lee el serial numérico del personaje con quien intercambia.
#
# Integer: serial del personaje desde LocalSerial; 0 sin ventana. No es contenedor ni Boolean;
# comprobar <> 0.

SUB Main()
    # La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las
    # llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del
    # personaje, no una validación de precio/contenido.

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

**Explicación de los parámetros y la ejecución:**

- La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.
