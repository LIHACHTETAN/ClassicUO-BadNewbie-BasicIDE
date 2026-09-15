# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

AS stabilisce la conversione di una variabile scalare. I tipi interni sono Integer, Decimal, String, Array, Object e Unit (nessun valore). Boolean usa Integer 1/0. Gli alias di questo Basic non garantiscono le dimensioni dei tipi VB.NET.

## Sintassi esatta

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## Parametri

- `name` — Nome dichiarato. Leggerlo restituisce il valore corrente; ogni nuova assegnazione applica nuovamente AS.
- `type` — Integer, Long, Short, Byte: intero con segno a 32 bit, -2147483648…2147483647; Short e Byte non restringono il limite. Double, Single, Decimal: virgola mobile binaria a 64 bit, chiamata Decimal internamente, non aritmetica decimale esatta. String: testo. Boolean, Bool: Integer 1/0. Variant, Object: mantengono il tipo fornito senza richiedere un’istanza oggetto. Maiuscole e minuscole equivalenti.
- `value` — Valore iniziale facoltativo: numero, testo, variabile o risultato di funzione. AS appartiene alla dichiarazione; CInt(value), CDbl(value), CStr(value), CBool(value) eseguono conversioni esplicite nelle espressioni.

## Restituisce

AS non restituisce valori. Leggere la variabile restituisce tipo e valore memorizzati. I risultati logici usano TRUE=1 e FALSE=0. Il conteggio 2 è diverso da zero, ma 2=TRUE è falso; verificare la presenza con count<>0 o CBool(count).

## Comportamento

- Senza inizializzatore, VAR tipizzato dà 0 per interi/Boolean, zero mobile per Double/Single/Decimal, testo vuoto per String. VAR senza tipo e VAR AS Variant/Object danno Unit. DIM scalare inserisce testo vuoto per String, altrimenti 0. Unit rimane Unit nell’assegnazione AS.
- AS Integer tronca verso zero le frazioni entro l’intervallo ammesso. CInt/CLng arrotondano, con le metà lontano da zero: 2.6 dà 3, mentre AS Integer memorizza 2. Il testo intero deve essere interamente decimale intero o esadecimale 0x; "2.6" non è ammesso. Controllare i limiti prima della conversione.
- AS Boolean confronta il valore originale con zero numerico: numero non nullo → 1, zero → 0. Non interpreta parole: anche "false" come testo dà 1. CBool converte prima in numero. Usare numeri/valori logici oppure confrontare esplicitamente il testo con la parola desiderata.
- AS String usa la rappresentazione testuale del motore. AS Double/Single/Decimal legge numeri con punto decimale. AS numerico converte Array in 0 ma rifiuta Object e testo numerico non valido con un errore gestibile da TRY/CATCH. CInt/CLng/CDbl/CSng/CBool sono permissivi: testo non riconosciuto, Array, Object o Unit diventano prima 0. Verificare IsNumeric(value) prima di fare affidamento sulla conversione del testo.
- La dichiarazione valuta l’inizializzatore, applica AS e conserva risultato e nome del tipo. Le assegnazioni ripetono la conversione. I valori mobili sono approssimati, senza garanzia di contabilità decimale esatta. VAR / DIM spiega gli ambiti, CONST protegge le associazioni.
- As accetta anche il nome di una Structure dichiarata. VAR e DIM di questo tipo senza inizializzatore creano i campi predefiniti. È compatibile solo lo stesso tipo dichiarato; tipi di struttura diversi non vengono convertiti. Structure / New descrive copie annidate e riferimenti.

## Esempi

### 1. Conversione e arrotondamento

```vb
# source=2.6 è mobile. whole AS Integer memorizza 2; CInt(source) dà 3 in rounded. Main restituisce 2*10+3=23 per verificare entrambe le conversioni.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

source=2.6 è mobile. whole AS Integer memorizza 2; CInt(source) dà 3 in rounded. Main restituisce 2*10+3=23 per verificare entrambe le conversioni.

### 2. Conteggio e valore logico

```vb
# count=2 è un conteggio. hasItems AS Boolean diventa 1. count=TRUE è falso poiché TRUE vale precisamente 1; count<>0 è vero. Main restituisce hasItems=1: esistono oggetti, senza affermare che siano uno.
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

count=2 è un conteggio. hasItems AS Boolean diventa 1. count=TRUE è falso poiché TRUE vale precisamente 1; count<>0 è vero. Main restituisce hasItems=1: esistono oggetti, senza affermare che siano uno.

### 3. Variant mantiene il tipo del valore

```vb
# value AS Variant contiene Integer 7 e poi String "ore". text AS String parte vuoto. CStr(12) produce "12"; unire i testi dà "ore12", restituito da Main. Variant consente il cambio di tipo.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

value AS Variant contiene Integer 7 e poi String "ore". text AS String parte vuoto. CStr(12) produce "12"; unire i testi dà "ore12", restituito da Main. Variant consente il cambio di tipo.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
