# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Convierte texto JSON en valores Basic.

## Sintaxis exacta

```text
JsonParse(text:String) -> Any
```

## Parámetros

- `text` — String JSON obligatoria con un único valor completo. Claves únicas que distinguen mayúsculas. Comentarios y comas finales generan errores.

## Devuelve

Any: objeto→Dictionary, matriz→List, texto→String, número→Integer o Decimal(Double), true/false→JsonBoolean, null→JsonNull. No es indicador de éxito.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Convierte texto JSON en valores Basic.

#### 1. Parse

String JSON obligatoria con un único valor completo. Claves únicas que distinguen mayúsculas. Comentarios y comas finales generan errores.

Any: objeto→Dictionary, matriz→List, texto→String, número→Integer o Decimal(Double), true/false→JsonBoolean, null→JsonNull. No es indicador de éxito.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; función `Parse`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonParse · 1

```vb
# JsonParse · 1
#
# Convierte texto JSON en valores Basic.
#
# Any: objeto→Dictionary, matriz→List, texto→String, número→Integer o Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. No es indicador de éxito.

Option Explicit On
Sub Main()
    # Ejecutar Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Convierte texto JSON en valores Basic.
#
# Any: objeto→Dictionary, matriz→List, texto→String, número→Integer o Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. No es indicador de éxito.

Option Explicit On
Sub Main()
    # Ejecutar Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null;
    # index2 → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Convierte texto JSON en valores Basic.
#
# Any: objeto→Dictionary, matriz→List, texto→String, número→Integer o Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. No es indicador de éxito.

Option Explicit On
Sub Main()
    # Ejecutar Main. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. text={"x":1,"x":2} → Catch → "duplicate key".
