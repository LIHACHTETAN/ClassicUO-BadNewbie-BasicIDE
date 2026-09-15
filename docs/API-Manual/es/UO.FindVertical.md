# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Lee o cambia la diferencia de altura permitida por defecto en la búsqueda.

## Sintaxis exacta

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## Parámetros

- `value` — Integer opcional. Sin argumento lee; value establece. Se limita a 0..120; un negativo pasa a 0, no a ilimitado. Runtime nuevo: 2; un estado restaurado puede diferir. Los decimales se truncan hacia cero; también admite cadenas numéricas decimal/0x. Use Integer para evitar conversiones implícitas.

## Devuelve

Sin argumentos: Integer, límite actual (diferencia en unidades Z del mundo), no un ID, cantidad de objetos o Boolean. 0 significa límite cero, no fallo. Con value: Unit, sin valor, ni TRUE/FALSE ni valor anterior. Lea FindVertical() después de escribir.

## Comportamiento

- Altura: abs(object.Z - player.Z), en ambos sentidos e incluyendo el límite. 0 exige la misma Z. No es un número de planta ni una distancia horizontal.
- Se guarda en el runtime del script y se comparte entre sus procedimientos; runtimes independientes tienen valores separados. Leer/escribir no busca, no borra FindItem/FindCount/GetFoundItems, no envía paquetes, no mueve al personaje ni carga objetos lejanos.
- FindTypeEx y FindTypesArrayEx aplican estos límites al suelo, no al contenido de contenedores. Siguen vigentes tipo, color, Ignore y objetos cargados. FindAtCoord ignora ambos. distance/maxZ explícitos de comandos ampliados pueden sustituirlos; -1 en esos parámetros usa el valor por defecto, a diferencia de asignar -1 al ajuste. FindList también filtra Z en contenedores; la excepción anterior no se le aplica.
- Guarde antes de una búsqueda temporal y restaure en Finally; no hay reversión automática. Finally cubre finalización normal y errores capturables; la parada de emergencia no es un mecanismo de limpieza.
- Referencia: [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). Este cliente conserva valores iniciales/rangos propios: FindDistance 18 / 0..255; FindVertical 2 / 0..120. La sintaxis Basic y los filtros ampliados describen este proyecto.

### Funciones internas: de la llamada al resultado

Etapas internas reales. CountGroundInRange es una función de usuario completa, no un comando integrado oculto.

#### 1. ExecuteStealthCompatibility

Cero argumentos seleccionan lectura; uno convierte value y escribe. Los metadatos distinguen Integer de Unit.

Sin argumentos: Integer, límite actual (diferencia en unidades Z del mundo), no un ID, cantidad de objetos o Boolean. 0 significa límite cero, no fallo. Con value: Unit, sin valor, ni TRUE/FALSE ni valor anterior. Lea FindVertical() después de escribir.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

El bridge lee el ajuste runtime o limita y guarda el entero, sin recorrer el mundo.

Sin argumentos: Integer, límite actual (diferencia en unidades Z del mundo), no un ID, cantidad de objetos o Boolean. 0 significa límite cero, no fallo. Con value: Unit, sin valor, ni TRUE/FALSE ni valor anterior. Lea FindVertical() después de escribir.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `GetFindVertical`.

#### 3. SetFindVertical

El bridge lee el ajuste runtime o limita y guarda el entero, sin recorrer el mundo.

Integer opcional. Sin argumento lee; value establece. Se limita a 0..120; un negativo pasa a 0, no a ilimitado. Runtime nuevo: 2; un estado restaurado puede diferir. Los decimales se truncan hacia cero; también admite cadenas numéricas decimal/0x. Use Integer para evitar conversiones implícitas.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `SetFindVertical`.

#### 4. FindType

La búsqueda posterior lee el ajuste cuando no hay sustitución explícita. Items del suelo y Mobiles pasan los filtros de distancia y altura correspondientes.

FindTypeEx y FindTypesArrayEx aplican estos límites al suelo, no al contenido de contenedores. Siguen vigentes tipo, color, Ignore y objetos cargados. FindAtCoord ignora ambos. distance/maxZ explícitos de comandos ampliados pueden sustituirlos; -1 en esos parámetros usa el valor por defecto, a diferencia de asignar -1 al ajuste. FindList también filtra Z en contenedores; la excepción anterior no se le aplica.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindType`.

#### 5. FindList

La búsqueda posterior lee el ajuste cuando no hay sustitución explícita. Items del suelo y Mobiles pasan los filtros de distancia y altura correspondientes.

FindTypeEx y FindTypesArrayEx aplican estos límites al suelo, no al contenido de contenedores. Siguen vigentes tipo, color, Ignore y objetos cargados. FindAtCoord ignora ambos. distance/maxZ explícitos de comandos ampliados pueden sustituirlos; -1 en esos parámetros usa el valor por defecto, a diferencia de asignar -1 al ajuste. FindList también filtra Z en contenedores; la excepción anterior no se le aplica.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindList`.

Se guarda en el runtime del script y se comparte entre sus procedimientos; runtimes independientes tienen valores separados. Leer/escribir no busca, no borra FindItem/FindCount/GetFoundItems, no envía paquetes, no mueve al personaje ni carga objetos lejanos.


## Ejemplos

### Leer, establecer y comprobar los límites

```vb
# Leer, establecer y comprobar los límites
#
# Lee o cambia la diferencia de altura permitida por defecto en la búsqueda.
#
# Sin argumentos: Integer, límite actual (diferencia en unidades Z del mundo), no un ID,
# cantidad de objetos o Boolean. 0 significa límite cero, no fallo. Con value: Unit, sin valor,
# ni TRUE/FALSE ni valor anterior. Lea FindVertical() después de escribir.

SUB Main()
    # previous guarda el ajuste real. value:=10 fija un límite normal; 1000 se reduce a 120. Print
    # lee por separado. Finally restaura previous.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Explicación de los parámetros y la ejecución:**

- previous guarda el ajuste real. value:=10 fija un límite normal; 1000 se reduce a 120. Print lee por separado. Finally restaura previous.

### Búsqueda temporal en el suelo

```vb
# Búsqueda temporal en el suelo
#
# Lee o cambia la diferencia de altura permitida por defecto en la búsqueda.
#
# Sin argumentos: Integer, límite actual (diferencia en unidades Z del mundo), no un ID,
# cantidad de objetos o Boolean. 0 significa límite cero, no fallo. Con value: Unit, sin valor,
# ni TRUE/FALSE ni valor anterior. Lea FindVertical() después de escribir.

SUB Main()
    # previous conserva el valor del llamador. 10 cambia solo FindVertical; el otro límite
    # permanece. 0x0EED: gráfico del oro; -1: cualquier color; Container=-1: mundo; FALSE: sin
    # recursión de contenedores. id es un serial; <> 0 comprueba existencia. FindCount cuenta
    # objetos/pilas. Finally restaura el ajuste, no la lista.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Explicación de los parámetros y la ejecución:**

- previous conserva el valor del llamador. 10 cambia solo FindVertical; el otro límite permanece. 0x0EED: gráfico del oro; -1: cualquier color; Container=-1: mundo; FALSE: sin recursión de contenedores. id es un serial; <> 0 comprueba existencia. FindCount cuenta objetos/pilas. Finally restaura el ajuste, no la lista.

### Función completa CountGroundInRange

```vb
# Función completa CountGroundInRange
#
# Lee o cambia la diferencia de altura permitida por defecto en la búsqueda.
#
# Sin argumentos: Integer, límite actual (diferencia en unidades Z del mundo), no un ID,
# cantidad de objetos o Boolean. 0 significa límite cero, no fallo. Con value: Unit, sin valor,
# ni TRUE/FALSE ni valor anterior. Lea FindVertical() después de escribir.

SUB Main()
    # CountGroundInRange(graphic, radius, height) guarda ambos límites, establece radius=5 y
    # height=10, busca graphic=0x0EED y devuelve FindCount(). Una pila cuenta como un objeto.
    # Función completa después de Main. Finally restaura incluso al salir con Return; los resultados
    # de búsqueda permanecen.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- CountGroundInRange(graphic, radius, height) guarda ambos límites, establece radius=5 y height=10, busca graphic=0x0EED y devuelve FindCount(). Una pila cuenta como un objeto. Función completa después de Main. Finally restaura incluso al salir con Return; los resultados de búsqueda permanecen.
