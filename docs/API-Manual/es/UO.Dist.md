# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Calcula la distancia en casillas como la mayor diferencia absoluta entre X e Y.

## Sintaxis exacta

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parámetros

- `Xfrom` — X de origen.
- `Yfrom` — Y de origen.
- `Xto` — X de destino.
- `Yto` — Y de destino.

## Devuelve

Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.

## Comportamiento

- Cálculo puro sin paquetes, esperas, cargar mapas, obstáculos, Z ni comprobar el mundo. No busca un camino transitable ni garantiza llegar. Use un mismo sistema de coordenadas; un rodeo puede ser mayor.
- Los cuatro parámetros son obligatorios: coordenadas mundiales Integer en el rango documentado 0..65535. Any indica el adaptador, no un ID. Sin valores predeterminados, coordenadas de contenedor, quinto Z ni sobrecarga con un objeto.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

### Funciones internas: de la llamada al resultado

El tercer ejemplo reconstruye el algoritmo mediante una función de script; no afirma que el motor llame a esa función de ejemplo.

#### 1. ExecuteStealthCompatibility

El adaptador lee las posiciones 0..3 como enteros Xfrom,Yfrom,Xto,Yto y llama al cálculo.

Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `GetDistance`.

Cálculo puro sin paquetes, esperas, cargar mapas, obstáculos, Z ni comprobar el mundo. No busca un camino transitable ni garantiza llegar. Use un mismo sistema de coordenadas; un rodeo puede ser mayor.


## Ejemplos

### Cálculo directo

```vb
# Cálculo directo
#
# Calcula la distancia en casillas como la mayor diferencia absoluta entre X e Y.
#
# Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No
# es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.

SUB Main()
    # De (100,100) a (103,104), diferencias 3 y 4: Main devuelve Integer 4, la mayor.
    # Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No
    # es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es
    # distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

    Return UO.Dist(100,100,103,104)
END SUB
```

**Explicación de los parámetros y la ejecución:**

- De (100,100) a (103,104), diferencias 3 y 4: Main devuelve Integer 4, la mayor.
- Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

### Comprobar el resultado

```vb
# Comprobar el resultado
#
# Calcula la distancia en casillas como la mayor diferencia absoluta entre X e Y.
#
# Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No
# es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.

SUB Main()
    # Entre (100,100) y (101,99), distancia 1; distance<=2 es True=1. En "1:1" el primer número es
    # distancia y el segundo resultado lógico.
    # Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No
    # es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es
    # distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Entre (100,100) y (101,99), distancia 1; distance<=2 es True=1. En "1:1" el primer número es distancia y el segundo resultado lógico.
- Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

### Algoritmo completo en script

```vb
# Algoritmo completo en script
#
# Calcula la distancia en casillas como la mayor diferencia absoluta entre X e Y.
#
# Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No
# es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.

SUB Main()
    # UO.Dist y RebuildTileDistance devuelven 4; Main devuelve "4:4". La función completa calcula
    # Abs y devuelve la diferencia mayor. Es código de ejemplo, no otra orden API.
    # Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No
    # es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es
    # distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**Explicación de los parámetros y la ejecución:**

- UO.Dist y RebuildTileDistance devuelven 4; Main devuelve "4:4". La función completa calcula Abs y devuelve la diferencia mayor. Es código de ejemplo, no otra orden API.
- Distancia Integer no negativa para coordenadas válidas. 0 indica XY iguales, 1 una casilla. No es un indicador de éxito. La comparación independiente distance<=2 da 1/True o 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Intercambiar puntos no cambia el resultado. No es distancia euclídea, suma de diferencias ni número de pasos rodeando un obstáculo.
