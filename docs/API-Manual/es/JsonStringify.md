# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Convierte valores Basic en texto JSON.

## Sintaxis exacta

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Parámetros

- `value` — Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados.
- `indented` — Indicador Integer:0 compacto, distinto de0 con sangría. Predeterminado:Stringify=0, Save=1.

## Devuelve

String JSON; no crea archivos.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Convierte valores Basic en texto JSON.

#### 1. Stringify

Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados. Indicador Integer:0 compacto, distinto de0 con sangría. Predeterminado:Stringify=0, Save=1.

String JSON; no crea archivos.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; función `Stringify`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Convierte valores Basic en texto JSON.
#
# String JSON; no crea archivos.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=Dictionary(name="ore",count=3), indented=0 → String
    # {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Convierte valores Basic en texto JSON.
#
# String JSON; no crea archivos.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Convierte valores Basic en texto JSON.
#
# String JSON; no crea archivos.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=List → value[0]=value → Catch → "cycle".
