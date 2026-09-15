# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

AS fixe la conversion d’une variable scalaire. Les valeurs internes sont Integer, Decimal, String, Array, Object et Unit (absence de valeur). Boolean utilise Integer 1/0. Les alias de ce dialecte Basic ne garantissent pas les tailles de stockage de VB.NET.

## Syntaxe exacte

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## Paramètres

- `name` — Nom déclaré. Sa lecture donne la valeur courante ; chaque nouvelle affectation applique de nouveau AS.
- `type` — Integer, Long, Short, Byte : entier signé 32 bits, de -2147483648 à 2147483647 ; Short et Byte ne restreignent pas cette plage. Double, Single, Decimal : flottant binaire 64 bits, nommé Decimal en interne, sans arithmétique décimale exacte. String : texte. Boolean, Bool : Integer 1/0. Variant, Object : conservent le genre fourni sans exiger une instance d’objet. Noms insensibles à la casse.
- `value` — Valeur initiale facultative : nombre, texte, variable ou résultat de fonction. AS appartient à la déclaration ; CInt(value), CDbl(value), CStr(value), CBool(value) sont des expressions de conversion explicites.

## Retour

AS ne renvoie rien. Lire la variable renvoie son genre et sa valeur stockés. Les résultats logiques utilisent TRUE=1 et FALSE=0. Le nombre 2 est non nul, mais 2=TRUE est faux ; testez la présence d’objets avec count<>0 ou CBool(count).

## Comportement

- Sans initialisation, VAR typé donne 0 pour les entiers/Boolean, un zéro flottant pour Double/Single/Decimal et du texte vide pour String. VAR sans type et VAR AS Variant/Object donnent Unit. DIM scalaire insère du texte vide pour String, sinon 0. Unit reste Unit lors d’une affectation AS.
- AS Integer tronque vers zéro les fractions dans la plage admise. CInt/CLng arrondissent, avec les moitiés en s’éloignant de zéro : 2.6 donne 3, contre 2 pour AS Integer. Le texte entier doit être intégralement décimal entier ou hexadécimal 0x ; "2.6" est refusé. Vérifiez la plage avant conversion.
- AS Boolean compare la valeur originale au zéro numérique : nombre non nul → 1, zéro → 0. Il ne lit pas les mots : même le texte "false" donne 1. CBool effectue d’abord une conversion numérique. Utilisez nombres/valeurs logiques ou comparez explicitement le texte au mot attendu.
- AS String utilise la représentation textuelle du moteur. AS Double/Single/Decimal lit le texte avec un point décimal. AS numérique transforme Array en 0, mais rejette Object et le texte numérique invalide par une erreur traitable avec TRY/CATCH. CInt/CLng/CDbl/CSng/CBool sont permissifs : texte non reconnu, Array, Object ou Unit deviennent d’abord 0. Vérifiez IsNumeric(value) avant de compter sur une conversion de texte.
- La déclaration évalue l’initialisation, applique AS et stocke résultat et type. Chaque affectation répète la conversion. Les flottants sont approximatifs, sans garantie de calcul monétaire décimal exact. VAR / DIM décrit les portées, CONST protège les liaisons.
- As accepte aussi le nom d’une Structure déclarée. VAR et DIM de ce type sans initialiseur créent ses champs par défaut. Seul ce même type déclaré est compatible ; aucun passage automatique entre types de structures distincts. Structure / New décrit les copies imbriquées et les références.

## Exemples

### 1. Conversion et arrondi

```vb
# source=2.6 est flottant. whole AS Integer stocke 2 ; CInt(source) donne 3 dans rounded. Main renvoie 2*10+3=23 pour vérifier les deux conversions.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**Explication des paramètres et du déroulement:**

source=2.6 est flottant. whole AS Integer stocke 2 ; CInt(source) donne 3 dans rounded. Main renvoie 2*10+3=23 pour vérifier les deux conversions.

### 2. Quantité et valeur logique

```vb
# count=2 est une quantité. hasItems AS Boolean devient 1. count=TRUE est faux car TRUE vaut exactement 1 ; count<>0 est vrai. Main renvoie hasItems=1 : des objets existent, sans affirmer qu’il y en a un seul.
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

**Explication des paramètres et du déroulement:**

count=2 est une quantité. hasItems AS Boolean devient 1. count=TRUE est faux car TRUE vaut exactement 1 ; count<>0 est vrai. Main renvoie hasItems=1 : des objets existent, sans affirmer qu’il y en a un seul.

### 3. Variant conserve le genre

```vb
# value AS Variant contient Integer 7, puis String "ore". text AS String est initialement vide. CStr(12) donne "12" ; joindre les textes produit "ore12", renvoyé par Main. Variant permet ce changement de genre.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**Explication des paramètres et du déroulement:**

value AS Variant contient Integer 7, puis String "ore". text AS String est initialement vide. CStr(12) donne "12" ; joindre les textes produit "ore12", renvoyé par Main. Variant permet ce changement de genre.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
