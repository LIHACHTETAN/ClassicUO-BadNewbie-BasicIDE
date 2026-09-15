# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee el nombre mostrado de una ejecución activa.

## Sintaxis exacta

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## Parámetros

- `ScriptIndex` — ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

## Devuelve

String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede tener un nombre explícitamente vacío.

## Comportamiento

- Se cuentan ejecuciones en curso y pausadas; se excluyen las terminadas o con cancelación solicitada. El script que llama suele contarse a sí mismo. Una pestaña solamente cargada no es una ejecución.
- Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.
- Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.
- GetScriptsList proporciona índices, GetScriptsCount una cantidad y GetScriptState un código de tres estados. No intercambiarlos ni interpretar todo valor distinto de cero como true.
- ScriptIndex=0 significa la primera ejecución actual, no necesariamente quien llama. SetScriptName cambia el nombre mostrado sin renombrar el archivo.

### Funciones internas: de la llamada al resultado

Estos son métodos reales del cliente. Los ejemplos Basic incluyen auxiliares completos; los nombres internos C# no son comandos de script adicionales.

#### 1. ExecuteStealthCompatibility

El runtime llama al comando UO registrado y envuelve la respuesta del puente como Integer, String o Array.

String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede tener un nombre explícitamente vacío.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetScriptName

El puente utiliza el gestor de ejecuciones de este cliente.

ScriptIndex=0 significa la primera ejecución actual, no necesariamente quien llama. SetScriptName cambia el nombre mostrado sin renombrar el archivo.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; función `GetScriptName`.

Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.


## Ejemplos

### Primera llamada y resultado

```vb
# Primera llamada y resultado
#
# Lee el nombre mostrado de una ejecución activa.
#
# String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede
# tener un nombre explícitamente vacío.

SUB Main()
    # Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento.
    # Los textos Print son mensajes de ejemplo.
    # ScriptIndex=0 significa la primera ejecución actual, no necesariamente quien llama.
    # SetScriptName cambia el nombre mostrado sin renombrar el archivo.
    # String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede
    # tener un nombre explícitamente vacío.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento. Los textos Print son mensajes de ejemplo.
- ScriptIndex=0 significa la primera ejecución actual, no necesariamente quien llama. SetScriptName cambia el nombre mostrado sin renombrar el archivo.
- String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede tener un nombre explícitamente vacío.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

### Uso en un bucle o condición

```vb
# Uso en un bucle o condición
#
# Lee el nombre mostrado de una ejecución activa.
#
# String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede
# tener un nombre explícitamente vacío.

SUB Main()
    # Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la
    # longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
    # ScriptIndex=0 significa la primera ejecución actual, no necesariamente quien llama.
    # SetScriptName cambia el nombre mostrado sin renombrar el archivo.
    # String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede
    # tener un nombre explícitamente vacío.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
- ScriptIndex=0 significa la primera ejecución actual, no necesariamente quien llama. SetScriptName cambia el nombre mostrado sin renombrar el archivo.
- String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede tener un nombre explícitamente vacío.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Lee el nombre mostrado de una ejecución activa.
#
# String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede
# tener un nombre explícitamente vacío.

SUB Main()
    # La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del
    # comando API que usa.
    # DescribeScript comprueba el estado y une nombre y ruta. Puede producirse una parada entre
    # llamadas; "missing" pertenece al auxiliar, no a GetScriptName.
    # String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede
    # tener un nombre explícitamente vacío.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**Explicación de los parámetros y la ejecución:**

- La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del comando API que usa.
- DescribeScript comprueba el estado y une nombre y ruta. Puede producirse una parada entre llamadas; "missing" pertenece al auxiliar, no a GetScriptName.
- String: nombre mostrado, o "" si no existe el índice. Una ejecución existente también puede tener un nombre explícitamente vacío.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.
