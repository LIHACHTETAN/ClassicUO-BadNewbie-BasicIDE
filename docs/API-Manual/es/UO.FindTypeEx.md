# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Busca un gráfico/color en un contenedor o en el suelo y devuelve un ID coincidente.

## Sintaxis exacta

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## Parámetros

- `ObjType` — Graphic/body, no el serial de un objeto. 0..65534 elige un gráfico; -1 o 0xFFFF cualquiera. Otros Integer negativos también funcionan como comodines.
- `Color` — Hue, no cantidad. 0 significa sin tinte; -1 o 0xFFFF cualquier hue. Otros Integer negativos también eliminan este filtro.
- `Container` — Suelo: UO.Ground(), 0, -1, 0xFFFFFFFF o cadena ground. Mochila: backpack o su serial. Acepta seriales decimales/hex y nombres AddObject. my elige todo el inventario propio, incluido equipo y bolsas anidadas. Un nombre desconocido produce un error de script. Compruebe el serial resuelto: 0 explícito selecciona suelo. Prefiera ground/backpack a las convenciones numéricas distintas entre API.
- `InSub` — TRUE/FALSE (1/0), obligatorio. FALSE busca contenido directo del contenedor concreto; TRUE también bolsas anidadas cargadas. No cambia el suelo. my ya incluye todo el inventario propio.

## Devuelve

Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico, cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía ni estabilidad.

## Comportamiento

- Son obligatorios los cuatro argumentos posicionales; no se omite ninguno.
- El suelo aplica FindDistance/FindVertical de este script, excluye self e incluye Item y Mobile coincidentes. Un contenedor concreto no aplica esos límites de distancia/altura. Ignore y objetos destruidos se excluyen en ambos casos.
- Antes de recorrer se vacían FindItem, FindCount, FindFullQuantity y GetFoundItems. Sin coincidencias quedan ceros y un array vacío. FindFullQuantity suma max(1, Amount) por Item y 1 por Mobile. FindQuantity lee la cantidad actual de FindItem. Guarde GetFoundItems antes de que otra búsqueda sustituya el estado.
- El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.
- Solo datos recibidos: no abre contenedores, carga celdas ni mueve objetos. Ningún resultado no demuestra que el cofre esté vacío en el servidor. Compruebe Connected si necesita conexión activa; la búsqueda lee el estado local.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). La referencia describe el último ID y una mochila alternativa para contenedores inválidos. Aquí se conserva la primera coincidencia local; un nombre desconocido no cambia a mochila. Ground acepta también 0; FindDistance local empieza en 18, máximo 255.

### Funciones internas: de la llamada al resultado

Etapas reales de implementación, no comandos públicos adicionales. FindGoldNearSelf y SearchTypesIn se incluyen como funciones de script completas.

#### 1. ExecuteStealthCompatibility

El runtime convierte los filtros numéricos y resuelve los nombres por separado; el suelo pasa al ámbito mundo interno del bridge.

Son obligatorios los cuatro argumentos posicionales; no se omite ninguno.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

Suelo: UO.Ground(), 0, -1, 0xFFFFFFFF o cadena ground. Mochila: backpack o su serial. Acepta seriales decimales/hex y nombres AddObject. my elige todo el inventario propio, incluido equipo y bolsas anidadas. Un nombre desconocido produce un error de script. Compruebe el serial resuelto: 0 explícito selecciona suelo. Prefiera ground/backpack a las convenciones numéricas distintas entre API.

El runtime convierte los filtros numéricos y resuelve los nombres por separado; el suelo pasa al ámbito mundo interno del bridge.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

Antes de recorrer se vacían FindItem, FindCount, FindFullQuantity y GetFoundItems. Sin coincidencias quedan ceros y un array vacío. FindFullQuantity suma max(1, Amount) por Item y 1 por Mobile. FindQuantity lee la cantidad actual de FindItem. Guarde GetFoundItems antes de que otra búsqueda sustituya el estado.

Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico, cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía ni estabilidad.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `ResetFindResults`.

#### 4. FindType

El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.

El suelo aplica FindDistance/FindVertical de este script, excluye self e incluye Item y Mobile coincidentes. Un contenedor concreto no aplica esos límites de distancia/altura. Ignore y objetos destruidos se excluyen en ambos casos.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindType`.

#### 5. MatchesFindIdentity

Graphic/body, no el serial de un objeto. 0..65534 elige un gráfico; -1 o 0xFFFF cualquiera. Otros Integer negativos también funcionan como comodines. Hue, no cantidad. 0 significa sin tinte; -1 o 0xFFFF cualquier hue. Otros Integer negativos también eliminan este filtro.

El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `MatchesFindIdentity`.

#### 6. MatchesFindContainer

TRUE/FALSE (1/0), obligatorio. FALSE busca contenido directo del contenedor concreto; TRUE también bolsas anidadas cargadas. No cambia el suelo. my ya incluye todo el inventario propio.

El suelo aplica FindDistance/FindVertical de este script, excluye self e incluye Item y Mobile coincidentes. Un contenedor concreto no aplica esos límites de distancia/altura. Ignore y objetos destruidos se excluyen en ambos casos.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `MatchesFindContainer`.

#### 7. RegisterFound

Antes de recorrer se vacían FindItem, FindCount, FindFullQuantity y GetFoundItems. Sin coincidencias quedan ceros y un array vacío. FindFullQuantity suma max(1, Amount) por Item y 1 por Mobile. FindQuantity lee la cantidad actual de FindItem. Guarde GetFoundItems antes de que otra búsqueda sustituya el estado.

Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico, cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía ni estabilidad.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `RegisterFound`.

Solo datos recibidos: no abre contenedores, carga celdas ni mueve objetos. Ningún resultado no demuestra que el cofre esté vacío en el servidor. Compruebe Connected si necesita conexión activa; la búsqueda lee el estado local.


## Ejemplos

### Contenido directo de la mochila

```vb
# Contenido directo de la mochila
#
# Busca un gráfico/color en un contenedor o en el suelo y devuelve un ID coincidente.
#
# Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico,
# cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila
# cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía
# ni estabilidad.

SUB Main()
    # 0x0EED es oro; -1 cualquier hue; backpack/FALSE excluye bolsas anidadas. Imprime primer ID hex
    # sin 0x, objetos y unidades. Pilas de 20 y 50 dan 2 objetos y 70 unidades.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- 0x0EED es oro; -1 cualquier hue; backpack/FALSE excluye bolsas anidadas. Imprime primer ID hex sin 0x, objetos y unidades. Pilas de 20 y 50 dan 2 objetos y 70 unidades.

### Función completa de búsqueda temporal en suelo

```vb
# Función completa de búsqueda temporal en suelo
#
# Busca un gráfico/color en un contenedor o en el suelo y devuelve un ID coincidente.
#
# Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico,
# cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila
# cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía
# ni estabilidad.

SUB Main()
    # radius=5 y height=10 se aplican dentro de FindGoldNearSelf. Finally restaura ambos incluso
    # tras Return o error. Devuelve serial de oro o 0; Main comprueba <> 0.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- radius=5 y height=10 se aplican dentro de FindGoldNearSelf. Finally restaura ambos incluso tras Return o error. Devuelve serial de oro o 0; Main comprueba <> 0.

### Contenedor nombrado y bolsas anidadas

```vb
# Contenedor nombrado y bolsas anidadas
#
# Busca un gráfico/color en un contenedor o en el suelo y devuelve un ID coincidente.
#
# Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico,
# cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila
# cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía
# ni estabilidad.

SUB Main()
    # GetSerial resuelve backpack; comprobar cero evita elegir suelo accidentalmente. AddObject
    # guarda search_bag. TRUE incluye bolsas anidadas. GetFoundItems copia la lista; IsObjectExists
    # comprueba cada ID otra vez.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**Explicación de los parámetros y la ejecución:**

- GetSerial resuelve backpack; comprobar cero evita elegir suelo accidentalmente. AddObject guarda search_bag. TRUE incluye bolsas anidadas. GetFoundItems copia la lista; IsObjectExists comprueba cada ID otra vez.
