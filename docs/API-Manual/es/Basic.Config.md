# JSON / Config.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Config.bas está en Scripts/Include. Colocar Include/Config.bas junto al script principal y usar Include "Config.bas". Combina JSON persistente con valores predeterminados independientes.

## Sintaxis exacta

```text
Include "Config.bas"
settings = Config.Load(fileName, defaults)
Config.Save(fileName, settings)
enabled = Config.GetFlag(settings, key, fallback=False)
Config.SetFlag(settings, key, value)
JsonParse(text) / JsonStringify(value[, indented=0])
JsonLoad(fileName[, defaultValue]) / JsonSave(fileName, value[, indented=1])
JsonKind(value) / JsonBoolean(value) / JsonNull() / flag.Value()
```

## Parámetros

- `fileName` — Ruta obligatoria. Las relativas parten de la carpeta del script principal, también desde Include. Se permiten rutas absolutas.
- `defaults (Config.Load)` — Dictionary de valores predeterminados obligatorio para Config.Load. La copia profunda JSON recibe las claves guardadas del primer nivel. El original no cambia. defaults no puede omitirse.
- `defaultValue (JsonLoad)` — Alternativa opcional solo si falta el archivo o la carpeta. Copia independiente mediante JSON; errores de contenido, codificación o acceso no se ocultan.
- `settings / value` — Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados.
- `indented` — Indicador Integer:0 compacto, distinto de0 con sangría. Predeterminado:Stringify=0, Save=1.
- `key / fallback` — Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.

## Devuelve

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

## Ejemplos

### 1. Valores predeterminados independientes

```vb
# fileName=missing-settings.json; defaults contiene delay=350. Sin archivo, Load copia defaults. Cambiar el resultado a125 conserva el inicial350. Resultado:"125:350". Renombrar o quitar un archivo de ejemplo anterior para esta prueba.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim defaults=Dictionary()
    defaults["delay"]=350
    Dim settings=Config.Load("missing-settings.json", defaults)
    settings["delay"]=125
    Return CStr(settings["delay"]) & ":" & CStr(defaults["delay"])
End Sub
```

**Explicación de los parámetros y la ejecución:**

fileName=missing-settings.json; defaults contiene delay=350. Sin archivo, Load copia defaults. Cambiar el resultado a125 conserva el inicial350. Resultado:"125:350". Renombrar o quitar un archivo de ejemplo anterior para esta prueba.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 2. Guardar y volver a leer

```vb
# SetFlag crea un booleano JSON. Save crea/reemplaza demo-settings.json; Load lo lee. GetFlag devuelve Integer1, delay=350. Resultado:"1:350".
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["delay"]=350
    Config.SetFlag(settings, "enabled", True)
    Config.Save("demo-settings.json", settings)
    Dim loaded=Config.Load("demo-settings.json", Dictionary())
    Return CStr(Config.GetFlag(loaded, "enabled")) & ":" & CStr(loaded["delay"])
End Sub
```

**Explicación de los parámetros y la ejecución:**

SetFlag crea un booleano JSON. Save crea/reemplaza demo-settings.json; Load lo lee. GetFlag devuelve Integer1, delay=350. Resultado:"1:350".

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 3. Validar indicadores

```vb
# enabled=1 es número, no JSON true. GetFlag lo rechaza; Catch devuelve "invalid flag". SetFlag(settings,"enabled",True) daría el tipo correcto. No cambia archivos.
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["enabled"]=1
    Try
        Dim enabled=Config.GetFlag(settings, "enabled")
    Catch problem
        Return "invalid flag"
    End Try
    Return "unexpected"
End Sub
```

**Explicación de los parámetros y la ejecución:**

enabled=1 es número, no JSON true. GetFlag lo rechaza; Catch devuelve "invalid flag". SetFlag(settings,"enabled",True) daría el tipo correcto. No cambia archivos.

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

<!-- implementation references (not callable script procedures):
Runtime/BasicJson.cs: Parse / Read / Stringify / Write / LoadCore / Save / Resolve / Budget
Runtime/ObjectTypes/JsonPrimitiveObjects.cs: Value
src/ClassicUO.Client/Scripts/Include/Config.bas: RequireObject / Load / Save / GetFlag / SetFlag
https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-dom
-->
