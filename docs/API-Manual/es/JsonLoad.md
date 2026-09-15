# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee un archivo JSON.

## Sintaxis exacta

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## Parámetros

- `fileName` — Ruta obligatoria. Las relativas parten de la carpeta del script principal, también desde Include. Se permiten rutas absolutas.
- `defaultValue` — Alternativa opcional solo si falta el archivo o la carpeta. Copia independiente mediante JSON; errores de contenido, codificación o acceso no se ocultan.

## Devuelve

Any como JsonParse. Archivo inexistente sin defaultValue: error.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Lee un archivo JSON.

#### 1. LoadCore

Ruta obligatoria. Las relativas parten de la carpeta del script principal, también desde Include. Se permiten rutas absolutas. Alternativa opcional solo si falta el archivo o la carpeta. Copia independiente mediante JSON; errores de contenido, codificación o acceso no se ocultan.

Any como JsonParse. Archivo inexistente sin defaultValue: error.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; función `LoadCore`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# Lee un archivo JSON.
#
# Any como JsonParse. Archivo inexistente sin defaultValue: error.

Option Explicit On
Sub Main()
    # Ejecutar Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# Lee un archivo JSON.
#
# Any como JsonParse. Archivo inexistente sin defaultValue: error.

Option Explicit On
Sub Main()
    # Ejecutar Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# Lee un archivo JSON.
#
# Any como JsonParse. Archivo inexistente sin defaultValue: error.

Option Explicit On
Sub Main()
    # Ejecutar Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
