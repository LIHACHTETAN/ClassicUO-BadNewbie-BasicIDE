# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee las casillas de aceptación; con tres argumentos también cambia la propia.

## Sintaxis exacta

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## Parámetros

- `windowIndex` — Índice entero actual: 0..TradeCount()-1. Negativo/ausente da resultado vacío. No es serial.
- `TradeNum` — Índice entero actual: 0..TradeCount()-1. Negativo/ausente da resultado vacío. No es serial.
- `Num` — Solo dos argumentos: 1 casilla propia, 2 ajena; otros valores devuelven 0. TradeNum aquí comienza en 0.
- `checkbox` — Solo tres argumentos: 0 casilla propia, 1 ajena de solo lectura; otros valores devuelven 0.
- `stateValue` — Solo con checkbox=0: 0/FALSE desmarca; cualquier número distinto de cero/TRUE marca. Ignorado con checkbox=1.

## Devuelve

Integer: 1 = TRUE si la casilla elegida está marcada; 0 = FALSE si no, o si ventana/lado inválido. Escribir devuelve el estado, no el éxito del intercambio: desmarcar devuelve 0.

Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0 THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir la acción o leer un estado cambiado.

## Comportamiento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.
- Lee en el hilo del juego las ventanas vivas del World actual, excluyendo las cerradas. Leer no envía paquetes ni espera respuestas. Abrir, cerrar o traer al frente cambia el orden UI; el índice no es un ID permanente.
- ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

### Funciones internas: de la llamada al resultado

Se explica la ruta C# y después se muestran ejemplos Basic ejecutables. Los scripts no reimplementan el protocolo de red.

#### 1. TradeCheck

El registro selecciona según cantidad de argumentos; NumberConversions convierte números. TradeCheck de dos argumentos valida 1/2 y los transforma en 0/1 del bridge. ToHex formatea serials heredados.

Integer: 1 = TRUE si la casilla elegida está marcada; 0 = FALSE si no, o si ventana/lado inválido. Escribir devuelve el estado, no el éxito del intercambio: desmarcar devuelve 0.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `TradeCheck`.

#### 2. TradeCheck

Invoke lleva lectura/escritura al hilo del juego con cancelación del script; lee ID1/ID2, LocalSerial, OpponentName o casillas del TradingGump seleccionado.

Lee las casillas de aceptación; con tres argumentos también cambia la propia.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade comprueba number>0 antes de restar 1; FindTrade rechaza índices negativos y enumera solo TradingGump abiertos de este World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindTrade`.

#### 4. AcceptTrade

Al cambiar su casilla, GameActions.AcceptTrade llama a Send_TradeResponse con código 2, ID1 y estado. Lecturas y valores sin cambios no envían paquetes.

Integer: 1 = TRUE si la casilla elegida está marcada; 0 = FALSE si no, o si ventana/lado inválido. Escribir devuelve el estado, no el éxito del intercambio: desmarcar devuelve 0.

Código del proyecto: `src/ClassicUO.Client/Game/GameActions.cs`; función `AcceptTrade`.

La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.


## Ejemplos

### Lectura o acción directa

```vb
# Lectura o acción directa
#
# Lee las casillas de aceptación; con tres argumentos también cambia la propia.
#
# Integer: 1 = TRUE si la casilla elegida está marcada; 0 = FALSE si no, o si ventana/lado
# inválido. Escribir devuelve el estado, no el éxito del intercambio: desmarcar devuelve 0.
#
# Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE
# THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir
# la acción o leer un estado cambiado.

SUB Main()
    # TradeCheck(0) y TradeCheck(0,1) leen su casilla de la primera ventana; TradeCheck(0,2) lee la
    # ajena. No escribe ni confirma automáticamente.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- TradeCheck(0) y TradeCheck(0,1) leen su casilla de la primera ventana; TradeCheck(0,2) lee la ajena. No escribe ni confirma automáticamente.

### Otro escenario y parámetros

```vb
# Otro escenario y parámetros
#
# Lee las casillas de aceptación; con tres argumentos también cambia la propia.
#
# Integer: 1 = TRUE si la casilla elegida está marcada; 0 = FALSE si no, o si ventana/lado
# inválido. Escribir devuelve el estado, no el éxito del intercambio: desmarcar devuelve 0.
#
# Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE
# THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir
# la acción o leer un estado cambiado.

SUB Main()
    # TradeCheck(0,0,FALSE) retira su aceptación. TradeCheck(0,1,FALSE) solo lee la ajena: FALSE no
    # la cambia. Devolver 0 al desmarcar es normal.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- TradeCheck(0,0,FALSE) retira su aceptación. TradeCheck(0,1,FALSE) solo lee la ajena: FALSE no la cambia. Devolver 0 al desmarcar es normal.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Lee las casillas de aceptación; con tres argumentos también cambia la propia.
#
# Integer: 1 = TRUE si la casilla elegida está marcada; 0 = FALSE si no, o si ventana/lado
# inválido. Escribir devuelve el estado, no el éxito del intercambio: desmarcar devuelve 0.
#
# Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE
# THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir
# la acción o leer un estado cambiado.

SUB Main()
    # La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las
    # llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del
    # personaje, no una validación de precio/contenido.

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

**Explicación de los parámetros y la ejecución:**

- La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.
