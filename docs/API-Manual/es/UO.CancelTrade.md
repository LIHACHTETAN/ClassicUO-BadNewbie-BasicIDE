# UO.CancelTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Cancela el intercambio seleccionado y cierra su ventana.

## Sintaxis exacta

```text
UO.CancelTrade(TradeNum:Any) -> Any
```

## Parámetros

- `TradeNum` — Número entero actual: 1..TradeCount(). Cero/negativos inválidos. No es serial.

## Devuelve

Integer: 1 = TRUE si la ventana se encontró, cerró y envió su cancelación; si no, 0 = FALSE. No espera al servidor. Cerrar otra vez no envía un segundo paquete.

Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0 THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir la acción o leer un estado cambiado.

## Comportamiento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.
- Lee en el hilo del juego las ventanas vivas del World actual, excluyendo las cerradas. Leer no envía paquetes ni espera respuestas. Abrir, cerrar o traer al frente cambia el orden UI; el índice no es un ID permanente.
- ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

### Funciones internas: de la llamada al resultado

Se explica la ruta C# y después se muestran ejemplos Basic ejecutables. Los scripts no reimplementan el protocolo de red.

#### 1. ExecuteStealthCompatibility

El registro selecciona según cantidad de argumentos; NumberConversions convierte números. TradeCheck de dos argumentos valida 1/2 y los transforma en 0/1 del bridge. ToHex formatea serials heredados.

Integer: 1 = TRUE si la ventana se encontró, cerró y envió su cancelación; si no, 0 = FALSE. No espera al servidor. Cerrar otra vez no envía un segundo paquete.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. CancelTrade

Invoke lleva lectura/escritura al hilo del juego con cancelación del script; lee ID1/ID2, LocalSerial, OpponentName o casillas del TradingGump seleccionado.

Cancela el intercambio seleccionado y cierra su ventana.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `CancelTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade comprueba number>0 antes de restar 1; FindTrade rechaza índices negativos y enumera solo TradingGump abiertos de este World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindNumberedTrade`.

#### 4. Dispose

Dispose termina si ya está cerrada, libera la UI y llama una vez a GameActions.CancelTrade(ID1).

Integer: 1 = TRUE si la ventana se encontró, cerró y envió su cancelación; si no, 0 = FALSE. No espera al servidor. Cerrar otra vez no envía un segundo paquete.

Código del proyecto: `src/ClassicUO.Client/Game/UI/Gumps/TradingGump.cs`; función `Dispose`.

La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.


## Ejemplos

### Lectura o acción directa

```vb
# Lectura o acción directa
#
# Cancela el intercambio seleccionado y cierra su ventana.
#
# Integer: 1 = TRUE si la ventana se encontró, cerró y envió su cancelación; si no, 0 = FALSE.
# No espera al servidor. Cerrar otra vez no envía un segundo paquete.
#
# Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE
# THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir
# la acción o leer un estado cambiado.

SUB Main()
    # Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver
    # sintaxis). HEX muestra serials numéricos; CStr números o texto.

    VAR result = UO.CancelTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver sintaxis). HEX muestra serials numéricos; CStr números o texto.

### Otro escenario y parámetros

```vb
# Otro escenario y parámetros
#
# Cancela el intercambio seleccionado y cierra su ventana.
#
# Integer: 1 = TRUE si la ventana se encontró, cerró y envió su cancelación; si no, 0 = FALSE.
# No espera al servidor. Cerrar otra vez no envía un segundo paquete.
#
# Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE
# THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir
# la acción o leer un estado cambiado.

SUB Main()
    # ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor
    # controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento
    # local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.CancelTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**Explicación de los parámetros y la ejecución:**

- ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Cancela el intercambio seleccionado y cierra su ventana.
#
# Integer: 1 = TRUE si la ventana se encontró, cerró y envió su cancelación; si no, 0 = FALSE.
# No espera al servidor. Cerrar otra vez no envía un segundo paquete.
#
# Resultado lógico: 1 = TRUE, 0 = FALSE. Tras VAR result = comando(...), use IF result = TRUE
# THEN o IF result = 1 THEN; para el resultado negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE sin comillas. Llame una vez y guarde el resultado: otra llamada puede repetir
# la acción o leer un estado cambiado.

SUB Main()
    # La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las
    # llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del
    # personaje, no una validación de precio/contenido.

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
    RETURN UO.CancelTrade(tradeNumber)
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.
