# UO.CalcDir

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: es -->

Calcula la dirección entre dos puntos del mundo sin mover al personaje.

## Sintaxis exacta

```text
UO.CalcDir(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parámetros

- `Xfrom` — X de origen.
- `Yfrom` — Y de origen.
- `Xto` — X de destino.
- `Yto` — Y de destino.

## Devuelve

Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como dirección de un paso.

## Comportamiento

- Cálculo puro sin paquetes, esperas, cargar mapas, obstáculos, Z ni comprobar el mundo. No busca un camino transitable ni garantiza llegar. Use un mismo sistema de coordenadas; un rodeo puede ser mayor.
- Los cuatro parámetros son obligatorios: coordenadas mundiales Integer en el rango documentado 0..65535. Any indica el adaptador, no un ID. Sin valores predeterminados, coordenadas de contenedor, quinto Z ni sobrecarga con un objeto.
- Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven 100.

### Funciones internas: de la llamada al resultado

El tercer ejemplo reconstruye el algoritmo mediante una función de script; no afirma que el motor llame a esa función de ejemplo.

#### 1. ExecuteStealthCompatibility

El adaptador lee las posiciones 0..3 como enteros Xfrom,Yfrom,Xto,Yto y llama al cálculo.

Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como dirección de un paso.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `ExecuteStealthCompatibility`.

#### 2. CalculateDirection

`CalculateDirection: dx=Math.Sign(toX-fromX); dy=Math.Sign(toY-fromY); identical ->100; axis/sign branches ->0..7.`

Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven 100.

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; función `CalculateDirection`.

Cálculo puro sin paquetes, esperas, cargar mapas, obstáculos, Z ni comprobar el mundo. No busca un camino transitable ni garantiza llegar. Use un mismo sistema de coordenadas; un rodeo puede ser mayor.


## Ejemplos

### Cálculo directo

```vb
# Cálculo directo
#
# Calcula la dirección entre dos puntos del mundo sin mover al personaje.
#
# Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No
# es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como
# dirección de un paso.

SUB Main()
    # De (100,100) a (101,100) solo aumenta X. Main devuelve Integer 2, este, sin movimiento.
    # Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No
    # es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como
    # dirección de un paso.
    # Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar
    # ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven
    # 100.

    Return UO.CalcDir(100,100,101,100)
END SUB
```

**Explicación de los parámetros y la ejecución:**

- De (100,100) a (101,100) solo aumenta X. Main devuelve Integer 2, este, sin movimiento.
- Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como dirección de un paso.
- Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven 100.

### Comprobar el resultado

```vb
# Comprobar el resultado
#
# Calcula la dirección entre dos puntos del mundo sin mover al personaje.
#
# Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No
# es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como
# dirección de un paso.

SUB Main()
    # Dos puntos (100,100) dan direction=100 y Main devuelve "already there". Puntos distintos toman
    # la otra rama. Compare con 100, no con True.
    # Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No
    # es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como
    # dirección de un paso.
    # Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar
    # ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven
    # 100.

    Dim direction=UO.CalcDir(100,100,100,100)
    If direction=100 Then
        Return "already there"
    End If
    Return "different point"
END SUB
```

**Explicación de los parámetros y la ejecución:**

- Dos puntos (100,100) dan direction=100 y Main devuelve "already there". Puntos distintos toman la otra rama. Compare con 100, no con True.
- Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como dirección de un paso.
- Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven 100.

### Algoritmo completo en script

```vb
# Algoritmo completo en script
#
# Calcula la dirección entre dos puntos del mundo sin mover al personaje.
#
# Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No
# es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como
# dirección de un paso.

SUB Main()
    # De (20,20) a (19,21), baja X y sube Y. UO.CalcDir y RebuildDirection devuelven 5; Main
    # devuelve "5:5". La función completa muestra cada rama y los mismos cuatro parámetros.
    # Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No
    # es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como
    # dirección de un paso.
    # Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar
    # ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven
    # 100.

    Dim actual=UO.CalcDir(20,20,19,21)
    Dim rebuilt=RebuildDirection(20,20,19,21)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildDirection(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Xto-Xfrom
    Dim dy = Yto-Yfrom
    If dx=0 AndAlso dy=0 Then
        Return 100
    End If
    If dx=0 Then
        If dy<0 Then
            Return 0
        End If
        Return 4
    End If
    If dy=0 Then
        If dx>0 Then
            Return 2
        End If
        Return 6
    End If
    If dx>0 Then
        If dy<0 Then
            Return 1
        End If
        Return 3
    End If
    If dy>0 Then
        Return 5
    End If
    Return 7
End Function
```

**Explicación de los parámetros y la ejecución:**

- De (20,20) a (19,21), baja X y sube Y. UO.CalcDir y RebuildDirection devuelven 5; Main devuelve "5:5". La función completa muestra cada rama y los mismos cuatro parámetros.
- Código Integer: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Puntos idénticos devuelven 100. No es Boolean: 0 significa norte, no error; 1 significa noreste, no éxito. No use 100 como dirección de un paso.
- Resta origen de destino y examina signos. Y decreciente es norte, X creciente es este. Cambiar ambos ejes elige una diagonal sin importar las magnitudes. Ambas diferencias cero devuelven 100.
