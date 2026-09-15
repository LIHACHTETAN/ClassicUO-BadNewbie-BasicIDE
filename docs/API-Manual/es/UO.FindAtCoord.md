# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Busca objetos cargados en una casilla X/Y exacta del mapa actual.

## Sintaxis exacta

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## Parámetros

- `X` — coordenada horizontal del mundo, Integer 0..65535. Obligatoria; no son píxeles de la ventana del contenedor.
- `Y` — coordenada vertical del mundo, Integer 0..65535. Obligatoria. No hay argumentos adicionales Z, mapa, tipo o radio.

## Devuelve

Integer: serial del primer objeto coincidente en la lista de este cliente. 0 indica que no hay resultados, falta el personaje/está eliminado o las coordenadas están fuera de 0..65535. Es un ID, no un tipo, cantidad o Boolean. Conserva los 32 bits: comprobar <> 0, no = TRUE ni > 0. El mismo ID pasa a FindItem().

## Comportamiento

- Examina Items no eliminados en el suelo y Mobiles, incluido el personaje en esa casilla. Excluye contenido de contenedores y equipo: sus X/Y no son coordenadas del mundo. Excluye serials ignorados.
- Admite cualquier altura Z en esos X/Y exactos. FindDistance y FindVertical no limitan esta búsqueda. Solo ve objetos cargados del mundo actual; no carga terreno, estáticos ni otro mapa. No envía paquetes, abre target ni mueve objetos.
- Cada llamada borra primero la búsqueda anterior. FindCount() cuenta objetos, FindFullQuantity() suma unidades de pilas (un Mobile aporta uno), GetFoundItems() proporciona serials. Primero Items, después Mobiles, según el orden actual de cada colección. Guardar la lista antes de otra búsqueda.
- Referencia: [Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/). El orden y los filtros anteriores describen este cliente.

### Funciones internas: de la llamada al resultado

Estos son los pasos internos reales. CountGraphicAt es una función de script definida completamente, no otro comando integrado.

#### 1. ExecuteStealthCompatibility

La ruta registrada convierte los dos argumentos X/Y posicionales o con nombre; devuelve el Integer del puente.

Integer: serial del primer objeto coincidente en la lista de este cliente. 0 indica que no hay resultados, falta el personaje/está eliminado o las coordenadas están fuera de 0..65535. Es un ID, no un tipo, cantidad o Boolean. Conserva los 32 bits: comprobar <> 0, no = TRUE ni > 0. El mismo ID pasa a FindItem().

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

En el hilo del juego borra resultados previos, comprueba personaje y coordenadas y recorre los Items del suelo y Mobiles coincidentes. No acepta contenido de contenedores.

Examina Items no eliminados en el suelo y Mobiles, incluido el personaje en esa casilla. Excluye contenido de contenedores y equipo: sus X/Y no son coordenadas del mundo. Excluye serials ignorados.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `FindAtCoord`.

#### 3. RegisterFound

Cada coincidencia aumenta el contador y añade su serial. El primero permanece en FindItem; Item.Amount aporta al menos una unidad y un Mobile aporta una.

Cada llamada borra primero la búsqueda anterior. FindCount() cuenta objetos, FindFullQuantity() suma unidades de pilas (un Mobile aporta uno), GetFoundItems() proporciona serials. Primero Items, después Mobiles, según el orden actual de cada colección. Guardar la lista antes de otra búsqueda.

Código del proyecto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; función `RegisterFound`.

Admite cualquier altura Z en esos X/Y exactos. FindDistance y FindVertical no limitan esta búsqueda. Solo ve objetos cargados del mundo actual; no carga terreno, estáticos ni otro mapa. No envía paquetes, abre target ni mueve objetos.


## Ejemplos

### Leer un ID

```vb
# Leer un ID
#
# Busca objetos cargados en una casilla X/Y exacta del mapa actual.
#
# Integer: serial del primer objeto coincidente en la lista de este cliente. 0 indica que no hay
# resultados, falta el personaje/está eliminado o las coordenadas están fuera de 0..65535. Es un
# ID, no un tipo, cantidad o Boolean. Conserva los 32 bits: comprobar <> 0, no = TRUE ni > 0. El
# mismo ID pasa a FindItem().

SUB Main()
    # 1445 y 1690 son X/Y de ejemplo; sustituirlos por la casilla deseada. id guarda un serial, HEX
    # lo formatea. <> 0 comprueba un resultado, no una cantidad.

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**Explicación de los parámetros y la ejecución:**

- 1445 y 1690 son X/Y de ejemplo; sustituirlos por la casilla deseada. id guarda un serial, HEX lo formatea. <> 0 comprueba un resultado, no una cantidad.

### Examinar todos los objetos de la casilla

```vb
# Examinar todos los objetos de la casilla
#
# Busca objetos cargados en una casilla X/Y exacta del mapa actual.
#
# Integer: serial del primer objeto coincidente en la lista de este cliente. 0 indica que no hay
# resultados, falta el personaje/está eliminado o las coordenadas están fuera de 0..65535. Es un
# ID, no un tipo, cantidad o Boolean. Conserva los 32 bits: comprobar <> 0, no = TRUE ni > 0. El
# mismo ID pasa a FindItem().

SUB Main()
    # x/y se leen del personaje; ids guarda la lista. Cada ID representa un objeto, incluida una
    # pila completa. GetType(id) lee graphic/body. No selecciona ni utiliza objetos.

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**Explicación de los parámetros y la ejecución:**

- x/y se leen del personaje; ids guarda la lista. Cada ID representa un objeto, incluida una pila completa. GetType(id) lee graphic/body. No selecciona ni utiliza objetos.

### Función completa CountGraphicAt

```vb
# Función completa CountGraphicAt
#
# Busca objetos cargados en una casilla X/Y exacta del mapa actual.
#
# Integer: serial del primer objeto coincidente en la lista de este cliente. 0 indica que no hay
# resultados, falta el personaje/está eliminado o las coordenadas están fuera de 0..65535. Es un
# ID, no un tipo, cantidad o Boolean. Conserva los 32 bits: comprobar <> 0, no = TRUE ni > 0. El
# mismo ID pasa a FindItem().

SUB Main()
    # CountGraphicAt(x, y, graphic) busca una vez y cuenta los ID guardados con el gráfico indicado.
    # graphic=0x0EED selecciona oro. Devuelve cantidad de objetos/pilas, no unidades totales ni
    # true/false; una pila cuenta uno. La función completa está después de Main.

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**Explicación de los parámetros y la ejecución:**

- CountGraphicAt(x, y, graphic) busca una vez y cuenta los ID guardados con el gráfico indicado. graphic=0x0EED selecciona oro. Devuelve cantidad de objetos/pilas, no unidades totales ni true/false; una pila cuenta uno. La función completa está después de Main.
