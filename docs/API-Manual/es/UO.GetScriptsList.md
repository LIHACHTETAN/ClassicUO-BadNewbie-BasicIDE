# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Devuelve los índices numéricos actuales de los scripts.

## Sintaxis exacta

```text
UO.GetScriptsList() -> Array
```

## Parámetros

Sin parámetros.

## Devuelve

Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni registros de texto.

## Comportamiento

- Se cuentan ejecuciones en curso y pausadas; se excluyen las terminadas o con cancelación solicitada. El script que llama suele contarse a sí mismo. Una pestaña solamente cargada no es una ejecución.
- Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.
- Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.
- GetScriptsList proporciona índices, GetScriptsCount una cantidad y GetScriptState un código de tres estados. No intercambiarlos ni interpretar todo valor distinto de cero como true.
- Sin argumentos. Pasar cada número al getter de nombre, ruta o estado. Modificar la matriz devuelta no controla scripts.

### Funciones internas: de la llamada al resultado

Estos son métodos reales del cliente. Los ejemplos Basic incluyen auxiliares completos; los nombres internos C# no son comandos de script adicionales.

#### 1. ExecuteStealthCompatibility

El runtime llama al comando UO registrado y envuelve la respuesta del puente como Integer, String o Array.

Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni registros de texto.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

El puente utiliza el gestor de ejecuciones de este cliente.

Sin argumentos. Pasar cada número al getter de nombre, ruta o estado. Modificar la matriz devuelta no controla scripts.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; función `GetScriptsList`.

Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.


## Ejemplos

### Primera llamada y resultado

```vb
# Primera llamada y resultado
#
# Devuelve los índices numéricos actuales de los scripts.
#
# Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni
# registros de texto.

SUB Main()
    # Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento.
    # Los textos Print son mensajes de ejemplo.
    # Sin argumentos. Pasar cada número al getter de nombre, ruta o estado. Modificar la matriz
    # devuelta no controla scripts.
    # Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni
    # registros de texto.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento. Los textos Print son mensajes de ejemplo.
- Sin argumentos. Pasar cada número al getter de nombre, ruta o estado. Modificar la matriz devuelta no controla scripts.
- Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni registros de texto.

### Uso en un bucle o condición

```vb
# Uso en un bucle o condición
#
# Devuelve los índices numéricos actuales de los scripts.
#
# Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni
# registros de texto.

SUB Main()
    # Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la
    # longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
    # Sin argumentos. Pasar cada número al getter de nombre, ruta o estado. Modificar la matriz
    # devuelta no controla scripts.
    # Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni
    # registros de texto.

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
- Sin argumentos. Pasar cada número al getter de nombre, ruta o estado. Modificar la matriz devuelta no controla scripts.
- Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni registros de texto.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Devuelve los índices numéricos actuales de los scripts.
#
# Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni
# registros de texto.

SUB Main()
    # La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del
    # comando API que usa.
    # FindNamedScript devuelve el primer índice actual con nombre mostrado exactamente igual, o -1.
    # Puede haber nombres repetidos e índices que cambien después.
    # Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni
    # registros de texto.

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**Explicación de los parámetros y la ejecución:**

- La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del comando API que usa.
- FindNamedScript devuelve el primer índice actual con nombre mostrado exactamente igual, o -1. Puede haber nombres repetidos e índices que cambien después.
- Array de Integer: índices 0..N-1 o una matriz vacía. Sus elementos son números, no nombres ni registros de texto.
