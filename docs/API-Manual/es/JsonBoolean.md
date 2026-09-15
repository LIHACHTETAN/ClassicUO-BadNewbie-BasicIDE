# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Crea un booleano JSON explícito.

## Sintaxis exacta

```text
JsonBoolean(value:Any) -> Object
```

## Parámetros

- `value` — Número o String numérica:0=false, otro=true. Basic True/False son1/0; leer booleanos JSON con flag.Value().

## Devuelve

Objeto JsonBoolean que se serializa como true/false. Value() devuelve Integer1/True o0/False para If. El objeto no es directamente un indicador numérico.

## Comportamiento

- Funciones Basic locales sin UO., no envían paquetes de juego. JsonParse/JsonStringify trabajan en memoria. Basic True se guarda como número1; JsonBoolean(True) produce JSON true. JsonNull() distingue null de0.
- Solo números finitos. Enteros fuera de ±9007199254740991 rechazados; guardar ID grandes como Strings. Otros números usan precisión Double. UTF-8 estricto: BOM de entrada permitido, salida sin BOM. Unicode inválido genera error.
- Límites:1048576 unidades UTF-16,4MiB de bytes,64 contenedores anidados,100000 nodos. Excederlos genera error. Leer/analizar crea colecciones nuevas; guardar no clona objetos de memoria.
- Save valida todo, crea carpetas, escribe un temporal junto al destino, vacía el búfer y mueve/reemplaza. Error/cancelación antes del reemplazo conserva el archivo anterior. Limpia el temporal si el sistema lo permite. Reemplazos ya completados no se revierten.
- Pausa/parada se revisan cada256 valores, entre bloques4096 bytes/caracteres y antes del reemplazo. Sin hilo adicional; las llamadas OS no se interrumpen forzosamente. Escrituras simultáneas: gana el último reemplazo correcto; no es transacción de base de datos.

### Funciones internas: de la llamada al resultado

Crea un booleano JSON explícito.

#### 1. BasicJsonBoolean

Número o String numérica:0=false, otro=true. Basic True/False son1/0; leer booleanos JSON con flag.Value().

Objeto JsonBoolean que se serializa como true/false. Value() devuelve Integer1/True o0/False para If. El objeto no es directamente un indicador numérico.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; función `BasicJsonBoolean`.

Config.Load(fileName, defaults) devuelve un Dictionary nuevo: las claves guardadas de primer nivel sustituyen una copia profunda de defaults. Los objetos anidados se sustituyen completos. Config.Save(fileName, settings) guarda explícitamente y no devuelve valor. Config.GetFlag(settings, key, fallback=False) devuelve1/True o0/False; valores existentes no booleanos generan error. Config.SetFlag(settings, key, value) cambia solo memoria, sin resultado. Load/Save requieren Dictionaries con claves String. Private RequireObject comprueba el tipo exterior; JSON valida todo el contenido.


## Ejemplos

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Crea un booleano JSON explícito.
#
# Objeto JsonBoolean que se serializa como true/false. Value() devuelve Integer1/True o0/False
# para If. El objeto no es directamente un indicador numérico.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Crea un booleano JSON explícito.
#
# Objeto JsonBoolean que se serializa como true/false. Value() devuelve Integer1/True o0/False
# para If. El objeto no es directamente un indicador numérico.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Crea un booleano JSON explícito.
#
# Objeto JsonBoolean que se serializa como true/false. Value() devuelve Integer1/True o0/False
# para If. El objeto no es directamente un indicador numérico.

Option Explicit On
Sub Main()
    # Ejecutar Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Explicación de los parámetros y la ejecución:**

- Ejecutar Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
