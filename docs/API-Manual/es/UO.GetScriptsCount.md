# UO.GetScriptsCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Cuenta las ejecuciones activas de este cliente.

## Sintaxis exacta

```text
UO.GetScriptsCount() -> Integer
```

## Parámetros

Sin parámetros.

## Devuelve

Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un Boolean ni un índice.

## Comportamiento

- Se cuentan ejecuciones en curso y pausadas; se excluyen las terminadas o con cancelación solicitada. El script que llama suele contarse a sí mismo. Una pestaña solamente cargada no es una ejecución.
- Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.
- Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.
- GetScriptsList proporciona índices, GetScriptsCount una cantidad y GetScriptState un código de tres estados. No intercambiarlos ni interpretar todo valor distinto de cero como true.
- Sin argumentos. Contar no ordena la lista ni modifica estados.

### Funciones internas: de la llamada al resultado

Estos son métodos reales del cliente. Los ejemplos Basic incluyen auxiliares completos; los nombres internos C# no son comandos de script adicionales.

#### 1. ExecuteStealthCompatibility

El runtime llama al comando UO registrado y envuelve la respuesta del puente como Integer, String o Array.

Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un Boolean ni un índice.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetScriptsCount

El puente utiliza el gestor de ejecuciones de este cliente.

Sin argumentos. Contar no ordena la lista ni modifica estados.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetScriptsCount`.

#### 3. GetScriptsCount

`_running.Count(entry => !entry.Value.Cancellation.IsCancellationRequested)`

Los índices son posiciones actuales por orden de inicio. Inicios y paradas pueden desplazarlas. Llamadas separadas no son una instantánea atómica; releer antes de una acción de control posterior.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; función `GetScriptsCount`.

Cerrar Basic IDE no elimina ejecuciones activas. Los comandos afectan a este cliente, no a otros clientes ni a procesos Windows.


## Ejemplos

### Primera llamada y resultado

```vb
# Primera llamada y resultado
#
# Cuenta las ejecuciones activas de este cliente.
#
# Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un
# Boolean ni un índice.

SUB Main()
    # Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento.
    # Los textos Print son mensajes de ejemplo.
    # Sin argumentos. Contar no ordena la lista ni modifica estados.
    # Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un
    # Boolean ni un índice.

    Dim count=UO.GetScriptsCount()
    UO.Print(CStr(count))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Sub Main. El 0 pasado es un índice; los paréntesis vacíos indican ningún argumento. Los textos Print son mensajes de ejemplo.
- Sin argumentos. Contar no ordena la lista ni modifica estados.
- Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un Boolean ni un índice.

### Uso en un bucle o condición

```vb
# Uso en un bucle o condición
#
# Cuenta las ejecuciones activas de este cliente.
#
# Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un
# Boolean ni un índice.

SUB Main()
    # Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la
    # longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
    # Sin argumentos. Contar no ordena la lista ni modifica estados.
    # Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un
    # Boolean ni un índice.

    Dim before=UO.GetScriptsCount()
    Wait(250)
    Dim after=UO.GetScriptsCount()
    UO.Print(CStr(after-before))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Ejemplo independiente que combina comandos. Los índices comienzan en cero: comprobar la longitud antes del acceso. Wait(250), si aparece, espera 250 milisegundos.
- Sin argumentos. Contar no ordena la lista ni modifica estados.
- Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un Boolean ni un índice.

### Función auxiliar completa

```vb
# Función auxiliar completa
#
# Cuenta las ejecuciones activas de este cliente.
#
# Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un
# Boolean ni un índice.

SUB Main()
    # La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del
    # comando API que usa.
    # HasOtherScripts compara con 1 porque quien llama suele ocupar una entrada. Solo la función
    # auxiliar devuelve true/false.
    # Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un
    # Boolean ni un índice.

    If HasOtherScripts() Then
        UO.Print("Other executions are active")
    Else
        UO.Print("No other active executions")
    End If
END SUB

Function HasOtherScripts() As Boolean
    Dim count=UO.GetScriptsCount()
    Return count > 1
End Function
```

**Explicación de los parámetros y la ejecución:**

- La función completa está debajo de Main. Sus parámetros y resultado se explican aparte del comando API que usa.
- HasOtherScripts compara con 1 porque quien llama suele ocupar una entrada. Solo la función auxiliar devuelve true/false.
- Integer >= 0: cantidad de ejecuciones activas, incluidas las pausadas. Un recuento, no un Boolean ni un índice.
