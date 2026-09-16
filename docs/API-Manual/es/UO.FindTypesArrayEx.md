# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Busca gráficos, colores y contenedores alternativos en un recorrido y devuelve un ID. GetFoundItems proporciona la lista completa.

## Sintaxis exacta

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## Parámetros

- `ObjTypes` — Graphic/body, no el serial de un objeto. 0..65534 elige un gráfico; -1 o 0xFFFF cualquiera. Otros Integer negativos también funcionan como comodines.
- `Colors` — Hue, no cantidad. 0 significa sin tinte; -1 o 0xFFFF cualquier hue. Otros Integer negativos también eliminan este filtro.
- `Containers` — Suelo: UO.Ground(), 0, -1, 0xFFFFFFFF o cadena ground. Mochila: backpack o su serial. Acepta seriales decimales/hex y nombres AddObject. my elige todo el inventario propio, incluido equipo y bolsas anidadas. Un nombre desconocido produce un error de script. Compruebe el serial resuelto: 0 explícito selecciona suelo. Prefiera ground/backpack a las convenciones numéricas distintas entre API.
- `InSub` — TRUE/FALSE (1/0), obligatorio. FALSE busca contenido directo del contenedor concreto; TRUE también bolsas anidadas cargadas. No cambia el suelo. my ya incluye todo el inventario propio.

## Devuelve

Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico, cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía ni estabilidad.

## Comportamiento

- Pase un Array; también se admite un escalar como un elemento. DIM values[1] crea índices 0 y 1: asigne todos. Tipos y colores son alternativas independientes, no parejas por índice. Un comodín en cualquier posición o un array tipos/colores vacío elimina ese filtro. Un array de contenedores vacío elige el inventario propio. Repeticiones y solapamientos no duplican ID.
- Son obligatorios los cuatro argumentos posicionales; no se omite ninguno.
- El suelo aplica FindDistance/FindVertical de este script, excluye self e incluye Item y Mobile coincidentes. Un contenedor concreto no aplica esos límites de distancia/altura. Ignore y objetos destruidos se excluyen en ambos casos.
- Antes de recorrer se vacían FindItem, FindCount, FindFullQuantity y GetFoundItems. Sin coincidencias quedan ceros y un array vacío. FindFullQuantity suma max(1, Amount) por Item y 1 por Mobile. FindQuantity lee la cantidad actual de FindItem. Guarde GetFoundItems antes de que otra búsqueda sustituya el estado.
- El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.
- Solo datos recibidos: no abre contenedores, carga celdas ni mueve objetos. Ningún resultado no demuestra que el cofre esté vacío en el servidor. Compruebe Connected si necesita conexión activa; la búsqueda lee el estado local.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). La referencia describe el último ID y una mochila alternativa para contenedores inválidos. Aquí se conserva la primera coincidencia local; un nombre desconocido no cambia a mochila. Ground acepta también 0; FindDistance local empieza en 18, máximo 255.

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

#### 4. BuildFindIdentityMask

Pase un Array; también se admite un escalar como un elemento. DIM values[1] crea índices 0 y 1: asigne todos. Tipos y colores son alternativas independientes, no parejas por índice. Un comodín en cualquier posición o un array tipos/colores vacío elimina ese filtro. Un array de contenedores vacío elige el inventario propio. Repeticiones y solapamientos no duplican ID.

El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `BuildFindIdentityMask`.

#### 5. FindTypes

El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.

El suelo aplica FindDistance/FindVertical de este script, excluye self e incluye Item y Mobile coincidentes. Un contenedor concreto no aplica esos límites de distancia/altura. Ignore y objetos destruidos se excluyen en ambos casos.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body, no el serial de un objeto. 0..65534 elige un gráfico; -1 o 0xFFFF cualquiera. Otros Integer negativos también funcionan como comodines. Hue, no cantidad. 0 significa sin tinte; -1 o 0xFFFF cualquier hue. Otros Integer negativos también eliminan este filtro.

El bridge recorre una vez los Item cargados, después los Mobile si se selecciona suelo. Deben coincidir tipo, color y al menos un contenedor. Cada objeto se registra una vez, sin recorrer todo el mundo por cada combinación.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `MatchesFindIdentity`.

#### 7. MatchesFindContainer

TRUE/FALSE (1/0), obligatorio. FALSE busca contenido directo del contenedor concreto; TRUE también bolsas anidadas cargadas. No cambia el suelo. my ya incluye todo el inventario propio.

El suelo aplica FindDistance/FindVertical de este script, excluye self e incluye Item y Mobile coincidentes. Un contenedor concreto no aplica esos límites de distancia/altura. Ignore y objetos destruidos se excluyen en ambos casos.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `MatchesFindContainer`.

#### 8. RegisterFound

Antes de recorrer se vacían FindItem, FindCount, FindFullQuantity y GetFoundItems. Sin coincidencias quedan ceros y un array vacío. FindFullQuantity suma max(1, Amount) por Item y 1 por Mobile. FindQuantity lee la cantidad actual de FindItem. Guarde GetFoundItems antes de que otra búsqueda sustituya el estado.

Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico, cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía ni estabilidad.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `RegisterFound`.

Solo datos recibidos: no abre contenedores, carga celdas ni mueve objetos. Ningún resultado no demuestra que el cofre esté vacío en el servidor. Compruebe Connected si necesita conexión activa; la búsqueda lee el estado local.


## Ejemplos

### Dos gráficos en suelo

```vb
# Dos gráficos en suelo
#
# Busca gráficos, colores y contenedores alternativos en un recorrido y devuelve un ID.
# GetFoundItems proporciona la lista completa.
#
# Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico,
# cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila
# cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía
# ni estabilidad.

SUB Main()
    # types contiene oro 0x0EED y perla negra 0x0F7A; color=-1 acepta todo hue, Ground elige mundo.
    # FALSE no cambia el suelo. Se aplican límites actuales. Imprime ID, objetos y unidades.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- types contiene oro 0x0EED y perla negra 0x0F7A; color=-1 acepta todo hue, Ground elige mundo. FALSE no cambia el suelo. Se aplican límites actuales. Imprime ID, objetos y unidades.

### Oro en mochila y suelo

```vb
# Oro en mochila y suelo
#
# Busca gráficos, colores y contenedores alternativos en un recorrido y devuelve un ID.
# GetFoundItems proporciona la lista completa.
#
# Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico,
# cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila
# cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía
# ni estabilidad.

SUB Main()
    # types solo oro; colors cualquier hue. Containers incluye backpack y suelo; TRUE incluye bolsas
    # anidadas. Imprime objetos/pilas y unidades de ambos ámbitos sin duplicarlos.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Explicación de los parámetros y la ejecución:**

- types solo oro; colors cualquier hue. Containers incluye backpack y suelo; TRUE incluye bolsas anidadas. Imprime objetos/pilas y unidades de ambos ámbitos sin duplicarlos.

### Función completa con lista guardada

```vb
# Función completa con lista guardada
#
# Busca gráficos, colores y contenedores alternativos en un recorrido y devuelve un ID.
# GetFoundItems proporciona la lista completa.
#
# Integer: serial de la primera coincidencia local, o 0 si no hay ninguna. No es gráfico,
# cantidad, array ni Boolean. Compruebe result <> 0, no result = TRUE ni result = 1. Una pila
# cuenta como un objeto; un Mobile como un objeto y una unidad. El orden no garantiza cercanía
# ni estabilidad.

SUB Main()
    # SearchTypesIn(container,firstType,secondType) devuelve Array<Integer>, mientras el comando
    # integrado devuelve un solo Integer ID. El código completo llena arrays, busca recursivamente y
    # copia GetFoundItems de inmediato. Main comprueba e imprime cada ID.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- SearchTypesIn(container,firstType,secondType) devuelve Array<Integer>, mientras el comando integrado devuelve un solo Integer ID. El código completo llena arrays, busca recursivamente y copia GetFoundItems de inmediato. Main comprueba e imprime cada ID.
