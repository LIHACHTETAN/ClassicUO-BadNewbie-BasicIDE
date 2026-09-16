# UO.TradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Devuelve el serial del contenedor ajeno en hexadecimal, no el ID del personaje.

## Sintaxis exacta

```text
UO.TradeOpponent(windowIndex:Any) -> String
```

## Parámetros

- `windowIndex` — Índice entero actual: 0..TradeCount()-1. Negativo/ausente da resultado vacío. No es serial.

## Devuelve

String: ID2 hexadecimal del contenedor ajeno, o "0x00000000". Para el personaje usar GetTradeOpponent(index + 1).

## Comportamiento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.
- Lee en el hilo del juego las ventanas vivas del World actual, excluyendo las cerradas. Leer no envía paquetes ni espera respuestas. Abrir, cerrar o traer al frente cambia el orden UI; el índice no es un ID permanente.
- ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

### Funciones internas: de la llamada al resultado

Se explica la ruta C# y después se muestran ejemplos Basic ejecutables. Los scripts no reimplementan el protocolo de red.

#### 1. TradeOpponent

El registro selecciona según cantidad de argumentos; NumberConversions convierte números. TradeCheck de dos argumentos valida 1/2 y los transforma en 0/1 del bridge. ToHex formatea serials heredados.

String: ID2 hexadecimal del contenedor ajeno, o "0x00000000". Para el personaje usar GetTradeOpponent(index + 1).

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `TradeOpponent`.

#### 2. TradeOpponent

Invoke lleva lectura/escritura al hilo del juego con cancelación del script; lee ID1/ID2, LocalSerial, OpponentName o casillas del TradingGump seleccionado.

Devuelve el serial del contenedor ajeno en hexadecimal, no el ID del personaje.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `TradeOpponent`.

#### 3. FindTrade

FindNumberedTrade comprueba number>0 antes de restar 1; FindTrade rechaza índices negativos y enumera solo TradingGump abiertos de este World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindTrade`.

La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.


## Ejemplos

### Lectura o acción directa

```vb
# Lectura o acción directa
#
# Devuelve el serial del contenedor ajeno en hexadecimal, no el ID del personaje.
#
# String: ID2 hexadecimal del contenedor ajeno, o "0x00000000". Para el personaje usar
# GetTradeOpponent(index + 1).

SUB Main()
    # Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver
    # sintaxis). HEX muestra serials numéricos; CStr números o texto.

    VAR value = UO.TradeOpponent(0)
    UO.Print(CStr(value))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver sintaxis). HEX muestra serials numéricos; CStr números o texto.

### Otro escenario y parámetros

```vb
# Otro escenario y parámetros
#
# Devuelve el serial del contenedor ajeno en hexadecimal, no el ID del personaje.
#
# String: ID2 hexadecimal del contenedor ajeno, o "0x00000000". Para el personaje usar
# GetTradeOpponent(index + 1).

SUB Main()
    # total guarda la cantidad de ventanas; index es el índice/número actual. Enumerar no confirma
    # nada. GetTradeContainer lee los contenedores propio (1) y ajeno (2) de la ventana 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 0 TO total - 1
        VAR value = UO.TradeOpponent(index)
        UO.Print(CStr(index) + ": " + CStr(value))
    NEXT
END SUB
```

**Explicación de los parámetros y la ejecución:**

- total guarda la cantidad de ventanas; index es el índice/número actual. Enumerar no confirma nada. GetTradeContainer lee los contenedores propio (1) y ajeno (2) de la ventana 1.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Devuelve el serial del contenedor ajeno en hexadecimal, no el ID del personaje.
#
# String: ID2 hexadecimal del contenedor ajeno, o "0x00000000". Para el personaje usar
# GetTradeOpponent(index + 1).

SUB Main()
    # La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las
    # llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del
    # personaje, no una validación de precio/contenido.

    VAR value = ReadTradeValue(0)
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 0 OR index >= total + 0 THEN
        RETURN "0x00000000"
    END IF
    RETURN UO.TradeOpponent(index)
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.
