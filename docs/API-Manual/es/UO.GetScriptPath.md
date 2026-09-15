# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee la ruta del archivo fuente de una ejecución activa.

## Sintaxis exacta

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## Parámetros

- `ScriptIndex` — ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

## Devuelve

String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser completa; un comando o código en memoria puede no tener un archivo normal.

## Comportamiento

- Se cuentan ejecuciones en curso y pausadas; se excluyen las terminadas o con cancelación solicitada. El script que llama suele contarse a sí mismo. Una pestaña solamente cargada no es una ejecución.
- Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.
- Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.
- GetScriptsList proporciona índices, GetScriptsCount una cantidad y GetScriptState un código de tres estados. No intercambiarlos ni interpretar todo valor distinto de cero como true.
- ScriptIndex=0 selecciona la primera ejecución actual. El getter identifica su fuente; no abre, guarda ni inicia ese archivo.

### Funciones internas: de la llamada al resultado

Estos son métodos reales del cliente. Los ejemplos Basic incluyen auxiliares completos; los nombres internos C# no son comandos de script adicionales.

#### 1. ExecuteStealthCompatibility

El runtime llama al comando UO registrado y envuelve la respuesta del puente como Integer, String o Array.

String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser completa; un comando o código en memoria puede no tener un archivo normal.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

El puente utiliza el gestor de ejecuciones de este cliente.

ScriptIndex=0 selecciona la primera ejecución actual. El getter identifica su fuente; no abre, guarda ni inicia ese archivo.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; función `GetScriptPath`.

Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.


## Ejemplos

### Primera llamada y resultado

```vb
# Primera llamada y resultado
#
# Lee la ruta del archivo fuente de una ejecución activa.
#
# String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser
# completa; un comando o código en memoria puede no tener un archivo normal.

SUB Main()
    # Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento.
    # Los textos Print son mensajes de ejemplo.
    # ScriptIndex=0 selecciona la primera ejecución actual. El getter identifica su fuente; no abre,
    # guarda ni inicia ese archivo.
    # String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser
    # completa; un comando o código en memoria puede no tener un archivo normal.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento. Los textos Print son mensajes de ejemplo.
- ScriptIndex=0 selecciona la primera ejecución actual. El getter identifica su fuente; no abre, guarda ni inicia ese archivo.
- String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser completa; un comando o código en memoria puede no tener un archivo normal.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

### Uso en un bucle o condición

```vb
# Uso en un bucle o condición
#
# Lee la ruta del archivo fuente de una ejecución activa.
#
# String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser
# completa; un comando o código en memoria puede no tener un archivo normal.

SUB Main()
    # Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la
    # longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
    # ScriptIndex=0 selecciona la primera ejecución actual. El getter identifica su fuente; no abre,
    # guarda ni inicia ese archivo.
    # String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser
    # completa; un comando o código en memoria puede no tener un archivo normal.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
- ScriptIndex=0 selecciona la primera ejecución actual. El getter identifica su fuente; no abre, guarda ni inicia ese archivo.
- String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser completa; un comando o código en memoria puede no tener un archivo normal.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Lee la ruta del archivo fuente de una ejecución activa.
#
# String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser
# completa; un comando o código en memoria puede no tener un archivo normal.

SUB Main()
    # La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del
    # comando API que usa.
    # ReadScriptPath usa fallback únicamente si la ruta está vacía. No es una nueva sobrecarga de
    # GetScriptPath.
    # String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser
    # completa; un comando o código en memoria puede no tener un archivo normal.
    # ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un
    # índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales
    # de objetos, nombres de procedimientos ni ID de ejecución de la IDE.

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**Explicación de los parámetros y la ejecución:**

- La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del comando API que usa.
- ReadScriptPath usa fallback únicamente si la ruta está vacía. No es una nueva sobrecarga de GetScriptPath.
- String: ruta fuente guardada, o "" si falta el índice. Al iniciar un archivo suele ser completa; un comando o código en memoria puede no tener un archivo normal.
- ScriptIndex obligatorio: índice entero desde cero obtenido de un GetScriptsList reciente. Un índice negativo o ausente devuelve el valor vacío/desconocido documentado. No pasar seriales de objetos, nombres de procedimientos ni ID de ejecución de la IDE.
