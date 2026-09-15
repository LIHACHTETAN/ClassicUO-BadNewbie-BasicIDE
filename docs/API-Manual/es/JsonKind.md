# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Identifica el tipo compatible con JSON.

## Sintaxis exacta

```text
JsonKind(value:Any) -> String
```

## Parámetros

- `value` — Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados.

## Devuelve

String:number, string, array, object, boolean, null o unsupported. Solo comprueba el tipo exterior.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Identifica el tipo compatible con JSON.

#### 1. Kind

Número, String, matriz, List, Dictionary, JsonBoolean o JsonNull. Claves Dictionary de tipo String. Referencias compartidas permitidas; ciclos rechazados.

String:number, string, array, object, boolean, null o unsupported. Solo comprueba el tipo exterior.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; función `Kind`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonKind · 1

```vb
# JsonKind · 1
#
# Identifica el tipo compatible con JSON.
#
# String:number, string, array, object, boolean, null o unsupported. Solo comprueba el tipo
# exterior.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Identifica el tipo compatible con JSON.
#
# String:number, string, array, object, boolean, null o unsupported. Solo comprueba el tipo
# exterior.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Identifica el tipo compatible con JSON.
#
# String:number, string, array, object, boolean, null o unsupported. Solo comprueba el tipo
# exterior.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
