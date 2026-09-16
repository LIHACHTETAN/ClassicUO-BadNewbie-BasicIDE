# UO.TradeCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Cuenta las ventanas de intercambio abiertas.

## Sintaxis exacta

```text
UO.TradeCount() -> Integer
```

## Parámetros

Sin parámetros.

## Devuelve

Integer: cantidad de ventanas desde 0. No es Boolean; comprobar > 0.

## Comportamiento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade empiezan en 1; TradeContainer/TradeOpponent/TradeName y todas las formas TradeCheck en 0. Este cliente conserva esas convenciones; las referencias de distintos motores difieren.
- Lee en el hilo del juego las ventanas vivas del World actual, excluyendo las cerradas. Leer no envía paquetes ni espera respuestas. Abrir, cerrar o traer al frente cambia el orden UI; el índice no es un ID permanente.
- ConfirmTrade y escribir su TradeCheck envían solo si cambia la aceptación. El servidor controla la casilla ajena. CancelTrade envía una vez. 1/TRUE indica estado/procesamiento local, no transferencia completa. Nombres y casillas no prueban que los objetos sigan iguales.

### Funciones internas: de la llamada al resultado

Se explica la ruta C# y después se muestran ejemplos Basic ejecutables. Los scripts no reimplementan el protocolo de red.

#### 1. TradeCount

El registro selecciona según cantidad de argumentos; NumberConversions convierte números. TradeCheck de dos argumentos valida 1/2 y los transforma en 0/1 del bridge. ToHex formatea serials heredados.

Integer: cantidad de ventanas desde 0. No es Boolean; comprobar > 0.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `TradeCount`.

#### 2. TradeCount

Invoke lleva lectura/escritura al hilo del juego con cancelación del script; lee ID1/ID2, LocalSerial, OpponentName o casillas del TradingGump seleccionado.

Cuenta las ventanas de intercambio abiertas.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `TradeCount`.

La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.


## Ejemplos

### Lectura o acción directa

```vb
# Lectura o acción directa
#
# Cuenta las ventanas de intercambio abiertas.
#
# Integer: cantidad de ventanas desde 0. No es Boolean; comprobar > 0.

SUB Main()
    # Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver
    # sintaxis). HEX muestra serials numéricos; CStr números o texto.

    VAR value = UO.TradeCount()
    UO.Print(CStr(value))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Una llamada guardada en value/result. 0 es el primer índice, 1 el primer número (ver sintaxis). HEX muestra serials numéricos; CStr números o texto.

### Otro escenario y parámetros

```vb
# Otro escenario y parámetros
#
# Cuenta las ventanas de intercambio abiertas.
#
# Integer: cantidad de ventanas desde 0. No es Boolean; comprobar > 0.

SUB Main()
    # before/after son instantáneas separadas por 500 milisegundos. La pausa no espera un
    # intercambio específico y puede omitir cambios intermedios.

    VAR before = UO.TradeCount()
    WAIT(500)
    VAR after = UO.TradeCount()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- before/after son instantáneas separadas por 500 milisegundos. La pausa no espera un intercambio específico y puede omitir cambios intermedios.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Cuenta las ventanas de intercambio abiertas.
#
# Integer: cantidad de ventanas desde 0. No es Boolean; comprobar > 0.

SUB Main()
    # La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las
    # llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del
    # personaje, no una validación de precio/contenido.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.TradeCount()
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- La función está completa y Main la llama. Comprobar límites/ID reduce errores pero las llamadas no son atómicas: puede cambiar la ventana. expectedPartner es el serial guardado del personaje, no una validación de precio/contenido.
