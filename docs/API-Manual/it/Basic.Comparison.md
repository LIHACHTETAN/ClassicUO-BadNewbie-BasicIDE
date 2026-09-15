# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Gli operatori di confronto verificano due valori e producono un risultato logico, utilizzabile in IF, in una variabile o nel RETURN di una funzione ausiliaria.

## Sintassi esatta

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## Parametri

- `left` — Valore sinistro: letterale, variabile dichiarata, espressione o risultato di funzione.
- `right` — Valore destro. I confronti d’ordine richiedono Integer o Decimal; l’uguaglianza accetta anche altri tipi di valore.
- `operator` — = e == verificano l’uguaglianza nelle espressioni; <> la disuguaglianza; < e > l’ordine stretto; <= e >= includono l’uguaglianza. Un’istruzione separata name = expression assegna un valore.

## Restituisce

Integer 1 (TRUE) se il confronto è vero, altrimenti Integer 0 (FALSE). Per questo risultato result=1 equivale a result=TRUE e result=0 a result=FALSE. Una quantità o un ID ha un significato diverso: 2 non è zero, ma 2=TRUE è falso. Verificare una quantità non nulla con count<>0.

## Comportamento

- Integer e Decimal si confrontano numericamente: 5=5.0 è vero. Il testo non viene convertito: "5"=5 è falso. Le stringhe si confrontano in modo ordinale distinguendo le maiuscole: "Ore"<>"ore". Ordinare testo, array, oggetti o Unit con <, >, <=, >= genera un errore.
- L’uguaglianza tra array e oggetti nativi verifica l’identità, non il contenuto. Due Unit sono uguali, ma Unit non è lo zero numerico. Tipi diversi sono disuguali salvo Integer/Decimal. NaN è diverso anche da sé stesso e tutti i confronti numerici d’ordine con NaN sono falsi.
- L’aritmetica precede i confronti. Le catene vengono valutate da sinistra a destra: 1<3<2 significa (1<3)<2 ed è vero. Per un intervallo scrivere (low<=value) AND (value<=high). Le parentesi rendono esplicito il raggruppamento.
- I calcoli binari in virgola mobile possono arrotondare. Per misure approssimate usare Abs(actual-expected)<=tolerance con una tolleranza adeguata non negativa. È una regola dello script, non una tolleranza automatica degli operatori.
- = confronta lo stesso tipo dichiarato e i campi; <> restituisce l’inverso. I riferimenti si confrontano per identità. È un’estensione del motore, non una regola generale per VB.NET. Hash memorizzati e coppie già visitate evitano ripetute espansioni di valori annidati condivisi.

## Esempi

### 1. Intervallo inclusivo e TRUE

```vb
# InRange riceve value=4, low=2, high=5. Entrambi i confronti danno 1, AND li combina in 1, Main verifica accepted=TRUE e restituisce 1. Funzione e chiamante sono completi.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

InRange riceve value=4, low=2, high=5. Entrambi i confronti danno 1, AND li combina in 1, Main verifica accepted=TRUE e restituisce 1. Funzione e chiamante sono completi.

### 2. Testo, numeri e maiuscole

```vb
# sameCase confronta "Ore" con "ore" e vale 0. sameKind confronta "5" con Integer 5 e vale 0. converted usa esplicitamente CDbl("5") e vale 1. CStr crea la diagnostica restituita "0:0:1".
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

sameCase confronta "Ore" con "ore" e vale 0. sameKind confronta "5" con Integer 5 e vale 0. converted usa esplicitamente CDbl("5") e vale 1. CStr crea la diagnostica restituita "0:0:1".

### 3. Uguaglianza decimale approssimata

```vb
# NearlyEqual riceve 0.1+0.2, expected=0.3, tolerance=0.000001. Una tolleranza negativa viene rifiutata. Abs calcola il modulo della differenza; <= accetta lo scarto entro la tolleranza. Main restituisce 1. Tutti i parametri ausiliari sono espliciti.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

NearlyEqual riceve 0.1+0.2, expected=0.3, tolerance=0.000001. Una tolleranza negativa viene rifiutata. Abs calcola il modulo della differenza; <= accetta lo scarto entro la tolleranza. Main restituisce 1. Tutti i parametri ausiliari sono espliciti.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
