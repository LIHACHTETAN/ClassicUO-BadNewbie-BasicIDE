# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee el estado de ejecución asociado a un índice.

## Sintaxis exacta

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## Parámetros

- `ScriptIndex` — ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

## Devuelve

Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean: comparar expresamente con 1 o 2.

## Comportamiento

- Se cuentan ejecuciones en curso y pausadas; se excluyen las terminadas o con cancelación solicitada. El script que llama suele contarse a sí mismo. Una pestaña solamente cargada no es una ejecución.
- Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.
- Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.
- GetScriptsList proporciona índices, GetScriptsCount una cantidad y GetScriptState un código de tres estados. No intercambiarlos ni interpretar todo valor distinto de cero como true.
- Incluye pausa manual/del depurador y la configurada al desconectarse. El estado 1 no garantiza trabajo instantáneo de CPU ni recepción de datos del servidor.

### Funciones internas: de la llamada al resultado

Estos son métodos reales del cliente. Los ejemplos Basic incluyen auxiliares completos; los nombres internos C# no son comandos de script adicionales.

#### 1. ExecuteStealthCompatibility

El runtime llama al comando UO registrado y envuelve la respuesta del puente como Integer, String o Array.

Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean: comparar expresamente con 1 o 2.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetScriptState

El puente utiliza el gestor de ejecuciones de este cliente.

Incluye pausa manual/del depurador y la configurada al desconectarse. El estado 1 no garantiza trabajo instantáneo de CPU ni recepción de datos del servidor.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; función `GetScriptState`.

Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.


## Ejemplos

### Primera llamada y resultado

```vb
# Primera llamada y resultado
#
# Lee el estado de ejecución asociado a un índice.
#
# Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean:
# comparar expresamente con 1 o 2.

SUB Main()
    # Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento.
    # Los textos Print son mensajes de ejemplo.
    # Incluye pausa manual/del depurador y la configurada al desconectarse. El estado 1 no garantiza
    # trabajo instantáneo de CPU ni recepción de datos del servidor.
    # Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean:
    # comparar expresamente con 1 o 2.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento. Los textos Print son mensajes de ejemplo.
- Incluye pausa manual/del depurador y la configurada al desconectarse. El estado 1 no garantiza trabajo instantáneo de CPU ni recepción de datos del servidor.
- Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean: comparar expresamente con 1 o 2.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

### Uso en un bucle o condición

```vb
# Uso en un bucle o condición
#
# Lee el estado de ejecución asociado a un índice.
#
# Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean:
# comparar expresamente con 1 o 2.

SUB Main()
    # Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la
    # longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
    # Incluye pausa manual/del depurador y la configurada al desconectarse. El estado 1 no garantiza
    # trabajo instantáneo de CPU ni recepción de datos del servidor.
    # Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean:
    # comparar expresamente con 1 o 2.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
- Incluye pausa manual/del depurador y la configurada al desconectarse. El estado 1 no garantiza trabajo instantáneo de CPU ni recepción de datos del servidor.
- Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean: comparar expresamente con 1 o 2.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Lee el estado de ejecución asociado a un índice.
#
# Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean:
# comparar expresamente con 1 o 2.

SUB Main()
    # La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del
    # comando API que usa.
    # IsScriptActive transforma 1 y 2 en true, y 0 en false. GetScriptState mantiene su código
    # numérico.
    # Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean:
    # comparar expresamente con 1 o 2.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**Explicación de los parámetros y la ejecución:**

- La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del comando API que usa.
- IsScriptActive transforma 1 y 2 en true, y 0 en false. GetScriptState mantiene su código numérico.
- Código Integer: 0 = ausente/desconocido, 1 = ejecutándose, 2 = pausado. No es Boolean: comparar expresamente con 1 o 2.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.
