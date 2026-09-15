# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Declare vincula un nombre Basic con un export de una DLL nativa Windows x64. Este subconjunto funciona en el cliente compilado sin generar código durante la ejecución; no equivale a toda la interoperabilidad VB.NET.

## Sintaxis exacta

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Parámetros

- `name / Public / Private` — Nombre local sin distinción de mayúsculas, llamado sin UO. Declaración en el archivo o Module, sin cuerpo ni End Function/End Sub. Public por defecto; Private dentro de Module. No puede sustituir comandos integrados Basic/UO: elegir otro nombre y Alias.
- `Lib / library.dll` — Nombre o ruta .dll obligatorio. Los nombres de sistema simples se buscan primero en System32; otras rutas relativas parten del archivo que declara, incluido Include. Se aceptan rutas absolutas. No se busca en el directorio actual ni PATH. Las dependencias pueden estar junto a la DLL o en System32.
- `Alias / export` — Nombre de export exacto y sensible a mayúsculas, opcional; por defecto el nombre local simple. No admite ordinales. Debe ser una función nativa Windows x64 con firma idéntica, no un método .NET administrado.
- `Ansi / Unicode / Auto` — Ansi por defecto copia en la codificación ANSI de Windows y puede perder caracteres. Unicode usa UTF-16. Ambos buscan el nombre exacto. Auto usa UTF-16, intenta el nombre exacto y después añade W. No deduce la codificación real: para API Unicode conviene Unicode con export W explícito.
- `ByVal arg As Type` — De cero a cuatro parámetros con ByVal y As Integer, Double, Boolean o String explícitos. Integer: 32 bits con signo; Double: 64 bits; Boolean: BOOL Windows de 32 bits, no bool C/C++. String es una copia temporal de entrada, solo lectura, terminada en NUL, máximo 1048576 unidades UTF-16 sin NUL interno. La DLL no debe guardar el puntero ni escribir en el búfer. Argumentos nombrados mediante nombres locales. No admite ByRef, Optional, ParamArray, matrices, estructuras ni punteros.
- `As ResultType / Sub` — Function exige As Integer, Double o Boolean. Sub no tiene As y produce Unit. Los argumentos Integer/Boolean deben ser Integer; Double acepta también Integer. Convertir explícitamente con CInt/CDbl/CStr cuando proceda. Retornos de cadenas, punteros o enteros de 64 bits requieren un adaptador nativo con firma compatible.

## Devuelve

Integer devuelve un número de 32 bits con signo cuyo significado depende de la función nativa, no necesariamente éxito. Double devuelve un flotante de 64 bits. As Boolean convierte cero en 0/False y cualquier otro BOOL en 1/True; para estos indicadores normalizados es equivalente comparar con 1/0 o True/False. Sub no devuelve valor (Unit). Ejemplos: 1, "3:8", "missing export:1".

## Comportamiento

- Declaraciones no compatibles se rechazan antes de ejecutar con SC031. Límites: 256 declaraciones y 64 bibliotecas cargadas por script principal. Análisis y autocompletado no cargan DLL. La firma nativa real es desconocida: una declaración errónea puede provocar el cierre del cliente.
- La primera llamada carga la DLL; las siguientes reutilizan biblioteca y dirección. Los argumentos se evalúan una vez en orden de escritura y después se reordenan por nombre. Try/Catch captura errores de carga, arquitectura, export y conversión; una infracción de memoria nativa no es un error ordinario recuperable.
- Las cadenas temporales se liberan tras cada llamada, incluso si falla una conversión. Las bibliotecas se liberan cuando termina, falla o se cancela el script principal. Cerrar solo la IDE conserva el script y sus bibliotecas.
- Llamada síncrona en el worker del script. Pausa y parada se comprueban antes y después; el motor no puede interrumpir una función nativa que nunca vuelve. Usar operaciones cortas y Basic Wait para esperar. No admite DLL administradas, callbacks a Basic, exports variádicos ni API arbitrarias con punteros.

## Ejemplos

### 1. ID del proceso cliente

```vb
# ClientProcessId llama a GetCurrentProcessId de kernel32.dll sin parámetros. Main guarda el ID Windows numérico en processId. La comparación processId > 0 devuelve 1/True; el ID no es Boolean ni serial de UO.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Explicación de los parámetros y la ejecución:**

ClientProcessId llama a GetCurrentProcessId de kernel32.dll sin parámetros. Main guarda el ID Windows numérico en processId. La comparación processId > 0 devuelve 1/True; el ID no es Boolean ni serial de UO.

### 2. Texto, potencia y nombres

```vb
# TextLength(text) pasa UTF-16 a lstrlenW y devuelve la longitud. Power(value, exponent) llama a pow con dos Double. Describe("ore", 2, 3) recibe tres argumentos, escribe los argumentos nombrados de Power en orden inverso y devuelve "3:8". Se muestran todas las funciones auxiliares.
Option Explicit On
Declare Unicode Function TextLength Lib "kernel32.dll" Alias "lstrlenW"(ByVal text As String) As Integer
Declare Function Power Lib "ucrtbase.dll" Alias "pow"(ByVal value As Double, ByVal exponent As Double) As Double

Function Describe(ByVal text As String, ByVal value As Double, ByVal exponent As Double) As String
    Dim length = TextLength(text:=text)
    Dim powered = Power(exponent:=exponent, value:=value)
    Return CStr(length) & ":" & CStr(powered)
End Function

Sub Main()
    Return Describe("ore", 2, 3)
End Sub
```

**Explicación de los parámetros y la ejecución:**

TextLength(text) pasa UTF-16 a lstrlenW y devuelve la longitud. Power(value, exponent) llama a pow con dos Double. Describe("ore", 2, 3) recibe tres argumentos, escribe los argumentos nombrados de Power en orden inverso y devuelve "3:8". Se muestran todas las funciones auxiliares.

### 3. Export inexistente

```vb
# NativeDemo.MissingExport nombra deliberadamente un export ausente. TryRead captura el error, fija status="missing export" y Finally fija finished=1. Main devuelve "missing export:1". Private mantiene la declaración en el módulo. Finally describe errores normales, sin garantizar limpieza de scripts tras cancelación de emergencia.
Option Explicit On
Module NativeDemo
    Private Declare Function MissingExport Lib "kernel32.dll" Alias "BasicManualMissingExport_71cf"() As Integer
    Public Function TryRead() As String
        Dim status = "unexpected export"
        Dim finished = 0
        Try
            MissingExport()
        Catch problem
            status = "missing export"
        Finally
            finished = 1
        End Try
        Return status & ":" & CStr(finished)
    End Function
End Module

Sub Main()
    Return NativeDemo.TryRead()
End Sub
```

**Explicación de los parámetros y la ejecución:**

NativeDemo.MissingExport nombra deliberadamente un export ausente. TryRead captura el error, fija status="missing export" y Finally fija finished=1. Main devuelve "missing export:1". Private mantiene la declaración en el módulo. Finally describe errores normales, sin garantizar limpieza de scripts tras cancelación de emergencia.


### Funciones internas: de la llamada al resultado

Declare vincula un nombre Basic con un export de una DLL nativa Windows x64. Este subconjunto funciona en el cliente compilado sin generar código durante la ejecución; no equivale a toda la interoperabilidad VB.NET.

#### 1. ExternalDeclaration

Declaraciones no compatibles se rechazan antes de ejecutar con SC031. Límites: 256 declaraciones y 64 bibliotecas cargadas por script principal. Análisis y autocompletado no cargan DLL. La firma nativa real es desconocida: una declaración errónea puede provocar el cierre del cliente.

`source -> typed declaration -> SC031 on unsupported ABI`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; función `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Nombre o ruta .dll obligatorio. Los nombres de sistema simples se buscan primero en System32; otras rutas relativas parten del archivo que declara, incluido Include. Se aceptan rutas absolutas. No se busca en el directorio actual ni PATH. Las dependencias pueden estar junto a la DLL o en System32.

`first call -> absolute DLL path -> cached library -> exact export`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; función `LibraryPath / GetCallable`.

#### 3. Invoke

De cero a cuatro parámetros con ByVal y As Integer, Double, Boolean o String explícitos. Integer: 32 bits con signo; Double: 64 bits; Boolean: BOOL Windows de 32 bits, no bool C/C++. String es una copia temporal de entrada, solo lectura, terminada en NUL, máximo 1048576 unidades UTF-16 sin NUL interno. La DLL no debe guardar el puntero ni escribir en el búfer. Argumentos nombrados mediante nombres locales. No admite ByRef, Optional, ParamArray, matrices, estructuras ni punteros.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; función `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function exige As Integer, Double o Boolean. Sub no tiene As y produce Unit. Los argumentos Integer/Boolean deben ser Integer; Double acepta también Integer. Convertir explícitamente con CInt/CDbl/CStr cuando proceda. Retornos de cadenas, punteros o enteros de 64 bits requieren un adaptador nativo con firma compatible.

`Windows x64 argument slots -> native call -> declared result`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; función `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Las cadenas temporales se liberan tras cada llamada, incluso si falla una conversión. Las bibliotecas se liberan cuando termina, falla o se cancela el script principal. Cerrar solo la IDE conserva el script y sus bibliotecas.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; función `Dispose`.

Integer devuelve un número de 32 bits con signo cuyo significado depende de la función nativa, no necesariamente éxito. Double devuelve un flotante de 64 bits. As Boolean convierte cero en 0/False y cualquier otro BOOL en 1/True; para estos indicadores normalizados es equivalente comparar con 1/0 o True/False. Sub no devuelve valor (Unit). Ejemplos: 1, "3:8", "missing export:1".

<!-- implementation references (not callable script procedures):
Runtime/ExternalDeclaration.cs: type and declaration validation
Analysis/ExternalDeclarationValidator.cs: SC031
Runtime/ExternalLibraries.cs: LibraryPath / GetCallable / Invoke / Dispose
Runtime/ExternalCallSites.cs: CallInteger / CallDouble / CallVoid
Runtime/Interpreter.cs: CallSubrutine / CallObserved
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/declare-statement
https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
-->
