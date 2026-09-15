# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Carga un archivo Basic y solicita su Sub Main pública.

## Sintaxis exacta

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## Parámetros

- `ScriptPath` — ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar Basic compatible y una Sub Main pública sin argumentos obligatorios.

## Devuelve

Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.

## Comportamiento

- Se cuentan ejecuciones en curso y pausadas; se excluyen las terminadas o con cancelación solicitada. El script que llama suele contarse a sí mismo. Una pestaña solamente cargada no es una ejecución.
- Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.
- Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.
- GetScriptsList proporciona índices, GetScriptsCount una cantidad y GetScriptState un código de tres estados. No intercambiarlos ni interpretar todo valor distinto de cero como true.
- Crear por separado los archivos Worker.bas indicados antes de los ejemplos. Ruta inválida/ilegible, Main inadecuada, Basic deshabilitado o paralelismo rechazado producen un fallo. Una ejecución aún deteniéndose puede causar un reintento diferido; aceptación no significa finalización. Un script corto puede terminar antes de leer el recuento.

### Funciones internas: de la llamada al resultado

Estos son métodos reales del cliente. Los ejemplos Basic incluyen auxiliares completos; los nombres internos C# no son comandos de script adicionales.

#### 1. ExecuteStealthCompatibility

El runtime llama al comando UO registrado y envuelve la respuesta del puente como Integer, String o Array.

Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. StartScript

El puente utiliza el gestor de ejecuciones de este cliente.

Crear por separado los archivos Worker.bas indicados antes de los ejemplos. Ruta inválida/ilegible, Main inadecuada, Basic deshabilitado o paralelismo rechazado producen un fallo. Una ejecución aún deteniéndose puede causar un reintento diferido; aceptación no significa finalización. Un script corto puede terminar antes de leer el recuento.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; función `StartScript`.

Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.


## Ejemplos

### Primera llamada y resultado

```vb
# Primera llamada y resultado
#
# Carga un archivo Basic y solicita su Sub Main pública.
#
# Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo
# de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.

SUB Main()
    # Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento.
    # Los textos Print son mensajes de ejemplo.
    # Crear por separado los archivos Worker.bas indicados antes de los ejemplos. Ruta
    # inválida/ilegible, Main inadecuada, Basic deshabilitado o paralelismo rechazado producen un
    # fallo. Una ejecución aún deteniéndose puede causar un reintento diferido; aceptación no
    # significa finalización. Un script corto puede terminar antes de leer el recuento.
    # Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo
    # de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.
    # ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se
    # admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar
    # Basic compatible y una Sub Main pública sin argumentos obligatorios.

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento. Los textos Print son mensajes de ejemplo.
- Crear por separado los archivos Worker.bas indicados antes de los ejemplos. Ruta inválida/ilegible, Main inadecuada, Basic deshabilitado o paralelismo rechazado producen un fallo. Una ejecución aún deteniéndose puede causar un reintento diferido; aceptación no significa finalización. Un script corto puede terminar antes de leer el recuento.
- Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.
- ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar Basic compatible y una Sub Main pública sin argumentos obligatorios.

### Uso en un bucle o condición

```vb
# Uso en un bucle o condición
#
# Carga un archivo Basic y solicita su Sub Main pública.
#
# Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo
# de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.

SUB Main()
    # Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la
    # longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
    # Crear por separado los archivos Worker.bas indicados antes de los ejemplos. Ruta
    # inválida/ilegible, Main inadecuada, Basic deshabilitado o paralelismo rechazado producen un
    # fallo. Una ejecución aún deteniéndose puede causar un reintento diferido; aceptación no
    # significa finalización. Un script corto puede terminar antes de leer el recuento.
    # Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo
    # de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.
    # ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se
    # admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar
    # Basic compatible y una Sub Main pública sin argumentos obligatorios.

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
- Crear por separado los archivos Worker.bas indicados antes de los ejemplos. Ruta inválida/ilegible, Main inadecuada, Basic deshabilitado o paralelismo rechazado producen un fallo. Una ejecución aún deteniéndose puede causar un reintento diferido; aceptación no significa finalización. Un script corto puede terminar antes de leer el recuento.
- Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.
- ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar Basic compatible y una Sub Main pública sin argumentos obligatorios.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Carga un archivo Basic y solicita su Sub Main pública.
#
# Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo
# de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.

SUB Main()
    # La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del
    # comando API que usa.
    # TryStartBasic compara con 65535 y devuelve true/false. No espera a que termine ni convierte la
    # cantidad en índice.
    # Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo
    # de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.
    # ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se
    # admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar
    # Basic compatible y una Sub Main pública sin argumentos obligatorios.

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**Explicación de los parámetros y la ejecución:**

- La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del comando API que usa.
- TryStartBasic compara con 65535 y devuelve true/false. No espera a que termine ni convierte la cantidad en índice.
- Integer: cantidad de ejecuciones activas después de aceptar el inicio; 65535 (0xFFFF) = fallo de inicio. No es el nuevo índice, un Boolean ni un resultado de finalización.
- ScriptPath obligatorio: String. Las rutas relativas parten de AutoLoad de este cliente; se admiten rutas absolutas. Encerrar entre comillas las rutas con espacios. El archivo debe usar Basic compatible y una Sub Main pública sin argumentos obligatorios.
