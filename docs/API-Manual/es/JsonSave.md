# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Guarda un valor en un archivo JSON.

## Sintaxis exacta

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## Parámetros

- `fileName` — Ruta obligatoria. Las relativas parten de la carpeta del script principal, también desde Include. Se permiten rutas absolutas.
- `value` — Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados.
- `indented` — Indicador Integer:0 compacto, distinto de0 con sangría. Predeterminado:Stringify=0, Save=1.

## Devuelve

Unit: sin valor. Terminar normalmente indica éxito; gestionar errores con Try/Catch.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Guarda un valor en un archivo JSON.

#### 1. Save

Ruta obligatoria. Las relativas parten de la carpeta del script principal, también desde Include. Se permiten rutas absolutas. Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados. Indicador Integer:0 compacto, distinto de0 con sangría. Predeterminado:Stringify=0, Save=1.

Unit: sin valor. Terminar normalmente indica éxito; gestionar errores con Try/Catch.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; función `Save`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonSave · 1

```vb
# JsonSave · 1
#
# Guarda un valor en un archivo JSON.
#
# Unit: sin valor. Terminar normalmente indica éxito; gestionar errores con Try/Catch.

Option Explicit On
Sub Main()
    # Ejecutar Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# Guarda un valor en un archivo JSON.
#
# Unit: sin valor. Terminar normalmente indica éxito; gestionar errores con Try/Catch.

Option Explicit On
Sub Main()
    # Ejecutar Main. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# Guarda un valor en un archivo JSON.
#
# Unit: sin valor. Terminar normalmente indica éxito; gestionar errores con Try/Catch.

Option Explicit On
Sub Main()
    # Ejecutar Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
