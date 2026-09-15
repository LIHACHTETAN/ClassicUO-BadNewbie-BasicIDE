# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Crea un valor JSON null explícito.

## Sintaxis exacta

```text
JsonNull() -> Object
```

## Parámetros

Sin parámetros.

## Devuelve

Objeto JsonNull que se serializa como null, ni0 ni String vacía. Prueba:JsonKind(value)="null".

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Crea un valor JSON null explícito.

#### 1. JsonNullObject



Objeto JsonNull que se serializa como null, ni0 ni String vacía. Prueba:JsonKind(value)="null".

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; función `JsonNullObject`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonNull · 1

```vb
# JsonNull · 1
#
# Crea un valor JSON null explícito.
#
# Objeto JsonNull que se serializa como null, ni0 ni String vacía.
# Prueba:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Ejecutar Main. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# Crea un valor JSON null explícito.
#
# Objeto JsonNull que se serializa como null, ni0 ni String vacía.
# Prueba:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Ejecutar Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# Crea un valor JSON null explícito.
#
# Objeto JsonNull que se serializa como null, ni0 ni String vacía.
# Prueba:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Ejecutar Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .
