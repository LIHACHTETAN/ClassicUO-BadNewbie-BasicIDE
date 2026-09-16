# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Devuelve el selector especial del suelo para el contenedor de búsqueda o el destino de traslado.

## Sintaxis exacta

```text
UO.Ground() -> Integer
```

## Parámetros

Sin parámetros.

## Devuelve

Integer, siempre 0. Ese cero identifica válidamente el suelo, no FALSE, un fallo, un ID, gráfico, mapa o coordenada. Compruebe el resultado de la búsqueda o del traslado, no Ground() como indicador de éxito.

## Comportamiento

- Sin parámetros. Ground() solo no busca, no mueve, no abre un target, no envía paquetes ni cambia los resultados anteriores. También devuelve 0 antes de conectar.
- Úselo en container/destination de FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx o MoveItem. La búsqueda ve objetos cargados, sin cargar casillas lejanas. X/Y/Z del suelo son coordenadas del mundo, no píxeles de la ventana del contenedor.
- FindType(type, color) sigue buscando en el inventario: el segundo argumento es el color. Suelo: FindType(type, color, UO.Ground()). Los compactos FindType/MoveItem usan -1 para inventario; los compatibles FindTypeEx/FindTypesArrayEx/CountEx también aceptan -1 para suelo. Prefiera UO.Ground() o el nombre ground a copiar números entre comandos con convenciones distintas.
- Fuente primaria: [Stealth Ground](https://stealth.od.ua/api/Ground/). Las convenciones y ejemplos describen este cliente.

### Funciones internas: de la llamada al resultado

Operaciones internas reales. FindGroundTypes es una función de usuario completa, no otro comando integrado.

#### 1. ExecuteStealthCompatibility

La rama runtime sin argumentos devuelve Integer 0 sin llamar al bridge.

Integer, siempre 0. Ese cero identifica válidamente el suelo, no FALSE, un fallo, un ID, gráfico, mapa o coordenada. Compruebe el resultado de la búsqueda o del traslado, no Ground() como indicador de éxito.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

El adaptador compacto convierte 0 explícito al suelo interno y conserva -1 para inventario. El compatible acepta 0 y el histórico -1 para suelo; los nombres de contenedores se resuelven aparte.

FindType(type, color) sigue buscando en el inventario: el segundo argumento es el color. Suelo: FindType(type, color, UO.Ground()). Los compactos FindType/MoveItem usan -1 para inventario; los compatibles FindTypeEx/FindTypesArrayEx/CountEx también aceptan -1 para suelo. Prefiera UO.Ground() o el nombre ground a copiar números entre comandos con convenciones distintas.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

El adaptador compacto convierte 0 explícito al suelo interno y conserva -1 para inventario. El compatible acepta 0 y el histórico -1 para suelo; los nombres de contenedores se resuelven aparte.

FindType(type, color) sigue buscando en el inventario: el segundo argumento es el color. Suelo: FindType(type, color, UO.Ground()). Los compactos FindType/MoveItem usan -1 para inventario; los compatibles FindTypeEx/FindTypesArrayEx/CountEx también aceptan -1 para suelo. Prefiera UO.Ground() o el nombre ground a copiar números entre comandos con convenciones distintas.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

El destino suelo se mantiene como 0. El bridge usa coordenadas del mundo; el campo contenedor del paquete de soltar es 0xFFFFFFFF. El selector API y el campo de red tienen representaciones distintas.

Cambie 0x40001001 por el serial de un objeto accesible. IsObjectExists comprueba el objeto cargado. MoveItem(item, amount, destination, X, Y, Z): amount=0 es la pila completa; Ground() elige el suelo; GetX/GetY/GetZ leen la casilla del jugador. result=1 significa solicitud aceptada por el cliente, si no 0; no es Ground() ni una confirmación del servidor.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ResolveTransferDestination`.

#### 5. MoveItem

El destino suelo se mantiene como 0. El bridge usa coordenadas del mundo; el campo contenedor del paquete de soltar es 0xFFFFFFFF. El selector API y el campo de red tienen representaciones distintas.

Cambie 0x40001001 por el serial de un objeto accesible. IsObjectExists comprueba el objeto cargado. MoveItem(item, amount, destination, X, Y, Z): amount=0 es la pila completa; Ground() elige el suelo; GetX/GetY/GetZ leen la casilla del jugador. result=1 significa solicitud aceptada por el cliente, si no 0; no es Ground() ni una confirmación del servidor.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `MoveItem`.

Sin parámetros. Ground() solo no busca, no mueve, no abre un target, no envía paquetes ni cambia los resultados anteriores. También devuelve 0 antes de conectar.


## Ejemplos

### Leer el selector

```vb
# Leer el selector
#
# Devuelve el selector especial del suelo para el contenedor de búsqueda o el destino de
# traslado.
#
# Integer, siempre 0. Ese cero identifica válidamente el suelo, no FALSE, un fallo, un ID,
# gráfico, mapa o coordenada. Compruebe el resultado de la búsqueda o del traslado, no Ground()
# como indicador de éxito.

SUB Main()
    # destination recibe Integer 0 y Print lo muestra. No se deja ningún objeto.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- destination recibe Integer 0 y Print lo muestra. No se deja ningún objeto.

### Buscar una pila de oro en el suelo

```vb
# Buscar una pila de oro en el suelo
#
# Devuelve el selector especial del suelo para el contenedor de búsqueda o el destino de
# traslado.
#
# Integer, siempre 0. Ese cero identifica válidamente el suelo, no FALSE, un fallo, un ID,
# gráfico, mapa o coordenada. Compruebe el resultado de la búsqueda o del traslado, no Ground()
# como indicador de éxito.

SUB Main()
    # 0x0EED: gráfico del oro; segundo -1: cualquier color. Ground() elige el mundo; FALSE desactiva
    # la recursión. FindTypeEx devuelve un serial o 0; <> 0 comprueba ese serial. Se aplican
    # FindDistance/FindVertical e Ignore.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**Explicación de los parámetros y la ejecución:**

- 0x0EED: gráfico del oro; segundo -1: cualquier color. Ground() elige el mundo; FALSE desactiva la recursión. FindTypeEx devuelve un serial o 0; <> 0 comprueba ese serial. Se aplican FindDistance/FindVertical e Ignore.

### Función completa para dos gráficos

```vb
# Función completa para dos gráficos
#
# Devuelve el selector especial del suelo para el contenedor de búsqueda o el destino de
# traslado.
#
# Integer, siempre 0. Ese cero identifica válidamente el suelo, no FALSE, un fallo, un ID,
# gráfico, mapa o coordenada. Compruebe el resultado de la búsqueda o del traslado, no Ground()
# como indicador de éxito.

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) busca oro 0x0EED y perlas negras 0x0F7A
    # con radius=5, height=10. DIM types[1] crea dos posiciones; colors[0] y containers[0], una cada
    # uno. Una pila cuenta como un objeto; tipos/colores son alternativas y contenedores solapados
    # no duplican ID. Devuelve una matriz guardada de serials. Finally restaura los límites y Main
    # imprime cada ID. Se incluye toda la función.

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- FindGroundTypes(firstType, secondType, radius, height) busca oro 0x0EED y perlas negras 0x0F7A con radius=5, height=10. DIM types[1] crea dos posiciones; colors[0] y containers[0], una cada uno. Una pila cuenta como un objeto; tipos/colores son alternativas y contenedores solapados no duplican ID. Devuelve una matriz guardada de serials. Finally restaura los límites y Main imprime cada ID. Se incluye toda la función.

### Colocar un objeto en la casilla del personaje

```vb
# Colocar un objeto en la casilla del personaje
#
# Devuelve el selector especial del suelo para el contenedor de búsqueda o el destino de
# traslado.
#
# Integer, siempre 0. Ese cero identifica válidamente el suelo, no FALSE, un fallo, un ID,
# gráfico, mapa o coordenada. Compruebe el resultado de la búsqueda o del traslado, no Ground()
# como indicador de éxito.

SUB Main()
    # Cambie 0x40001001 por el serial de un objeto accesible. IsObjectExists comprueba el objeto
    # cargado. MoveItem(item, amount, destination, X, Y, Z): amount=0 es la pila completa; Ground()
    # elige el suelo; GetX/GetY/GetZ leen la casilla del jugador. result=1 significa solicitud
    # aceptada por el cliente, si no 0; no es Ground() ni una confirmación del servidor.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Cambie 0x40001001 por el serial de un objeto accesible. IsObjectExists comprueba el objeto cargado. MoveItem(item, amount, destination, X, Y, Z): amount=0 es la pila completa; Ground() elige el suelo; GetX/GetY/GetZ leen la casilla del jugador. result=1 significa solicitud aceptada por el cliente, si no 0; no es Ground() ni una confirmación del servidor.
