# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

AddHandler collega una Sub ai nuovi messaggi del diario, alle risorse del personaggio e ai cambiamenti della connessione. Questi nomi UO. sono eventi, non funzioni: non invocarli con RaiseEvent.

## Sintassi esatta

```text
AddHandler UO.JournalEntry, AddressOf OnJournal
Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
AddHandler UO.HitPointsChanged, AddressOf OnHits
AddHandler UO.ManaChanged, AddressOf OnMana
AddHandler UO.StaminaChanged, AddressOf OnStamina
Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
AddHandler UO.ConnectionChanged, AddressOf OnConnection
Sub OnConnection(ByVal online As Boolean)
RemoveHandler UO.JournalEntry, AddressOf OnJournal
```

## Parametri

- `Handler / AddressOf` — Usare AddressOf una Sub dello script caricato. Dichiarare tutti i parametri esplicitamente ByVal, con tipi e ordine delle firme. Function, Optional, ParamArray e callback di altri script sono rifiutati.
- `text / serial / name / hue` — JournalEntry passa text String, serial Integer (ID sorgente, 0 se assente), name String e hue Integer (indice tinta UO, non RGB). Serial non è la grafica di un oggetto. Testo e nome possono essere vuoti. I valori sono copiati prima del riuso della voce. Si ricevono solo nuovi messaggi dopo la sottoscrizione, inclusi quelli locali.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged passano current e previous Integer come punti assoluti, non percentuali o Boolean. Il confronto avviene a ogni aggiornamento; variazioni intermedie possono unirsi. Stato iniziale e cambio personaggio impostano una base senza notifiche di risorse.
- `online` — ConnectionChanged passa online Boolean: True/1 indica personaggio e mappa nel mondo client, False/0 la loro assenza. Non verifica la salute del socket. Non ripete lo stato iniziale.
- `RemoveHandler` — RemoveHandler rimuove l’ultima occorrenza corrispondente. I duplicati vengono chiamati più volte in ordine. Il messaggio corrente usa una lista fissa; le modifiche valgono per quelli successivi. Rimuovere l’ultimo gestore libera la coda.

## Restituisce

AddHandler/RemoveHandler e le Sub non restituiscono un valore (Unit). Salvare i risultati nei campi condivisi di Module. Solo online e i predicati usano 1/0 = True/False; serial, hue, punti e State.changes sono identificatori o quantità.

## Comportamento

- Il client accoda copie dei dati; i gestori lavorano nel thread del proprio script, tra istruzioni e dentro Wait, Sleep, UO.Wait e Wait Until. Controllo non più spesso di 25 ms, massimo 16 messaggi per evento a passaggio. Chiamate native lunghe possono ritardare la consegna.
- La pausa accoda senza eseguire. Stop annulla e libera le sottoscrizioni; Catch non sopprime l’arresto. Ritorno o errore della procedura principale rimuove tutte le sottoscrizioni client; il prossimo avvio riparte senza di esse. Chiudere IDE non ferma uno script attivo. La pausa automatica alla disconnessione ritarda la notifica fino alla ripresa.
- Limite: 256 messaggi per evento. Il superamento produce un errore intercettabile e disattiva quella sottoscrizione. Anche un errore del gestore la disattiva e salta i gestori successivi del messaggio. Dopo Catch/Finally si può sottoscrivere di nuovo. Non riscrivere ogni messaggio nello stesso diario.
- Questi cinque eventi richiedono Full con Basic IDE abilitata. Altri eventi, pacchetti, Handles e WithEvents non sono inclusi. Per eventi dichiarati dallo script vedere Basic.Events.

## Esempi

### 1. Riconoscere un nuovo messaggio

```vb
# OnJournal riceve quattro parametri. IsReadyMessage è mostrata per intero e controlla InStr > 0. Il messaggio locale aggiorna State.message. Wait Until attende fino a 5000 ms, poi genera timeout. Finally rimuove il gestore. Main restituisce "ready: ore".
Option Explicit On
Module State
    Public Dim matched As Boolean = False
    Public Dim message As String = ""
End Module

Function IsReadyMessage(ByVal text As String) As Boolean
    Return InStr(text, "ready: ore") > 0
End Function

Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
    If IsReadyMessage(text) Then
        State.message = text
        State.matched = True
    End If
End Sub

Sub Main()
    AddHandler UO.JournalEntry, AddressOf OnJournal
    Try
        UO.AddToJournal("ready: ore")
        Wait Until State.matched Timeout 5000
    Finally
        RemoveHandler UO.JournalEntry, AddressOf OnJournal
    End Try
    Return State.message
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

OnJournal riceve quattro parametri. IsReadyMessage è mostrata per intero e controlla InStr > 0. Il messaggio locale aggiorna State.message. Wait Until attende fino a 5000 ms, poi genera timeout. Finally rimuove il gestore. Main restituisce "ready: ore".

### 2. Osservare le risorse

```vb
# Tre gestori passano current/previous alla procedura completa Remember. State.changes conta le notifiche e State.last contiene, per esempio, SP:58:60. Dopo Wait(250), Wait Until attende fino a 5000 ms; senza cambiamenti scatta il timeout. Finally rimuove le tre sottoscrizioni. Il risultato è String, non Boolean.
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim last As String = ""
End Module

Sub Remember(ByVal label As String, ByVal current As Integer, ByVal previous As Integer)
    State.changes += 1
    State.last = label & ":" & CStr(current) & ":" & CStr(previous)
End Sub

Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
    Remember("HP", current, previous)
End Sub

Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
    Remember("MP", current, previous)
End Sub

Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
    Remember("SP", current, previous)
End Sub

Sub Main()
    AddHandler UO.HitPointsChanged, AddressOf OnHits
    AddHandler UO.ManaChanged, AddressOf OnMana
    AddHandler UO.StaminaChanged, AddressOf OnStamina
    Try
        Wait(250)
        Wait Until State.changes > 0 Timeout 5000
    Finally
        RemoveHandler UO.HitPointsChanged, AddressOf OnHits
        RemoveHandler UO.ManaChanged, AddressOf OnMana
        RemoveHandler UO.StaminaChanged, AddressOf OnStamina
    End Try
    Return State.last
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Tre gestori passano current/previous alla procedura completa Remember. State.changes conta le notifiche e State.last contiene, per esempio, SP:58:60. Dopo Wait(250), Wait Until attende fino a 5000 ms; senza cambiamenti scatta il timeout. Finally rimuove le tre sottoscrizioni. Il risultato è String, non Boolean.

### 3. Osservare la connessione

```vb
# OnConnection riceve Boolean online e conta le transizioni durante Wait(1000). Finally rimuove la sottoscrizione. Main restituisce il numero: 0 senza cambiamenti, 1 per una transizione; qui 1 non è True. State.online conserva l’ultimo stato ricevuto.
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim online As Boolean = False
End Module

Sub OnConnection(ByVal online As Boolean)
    State.online = online
    State.changes += 1
End Sub

Sub Main()
    AddHandler UO.ConnectionChanged, AddressOf OnConnection
    Try
        Wait(1000)
    Finally
        RemoveHandler UO.ConnectionChanged, AddressOf OnConnection
    End Try
    Return State.changes
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

OnConnection riceve Boolean online e conta le transizioni durante Wait(1000). Finally rimuove la sottoscrizione. Main restituisce il numero: 0 senza cambiamenti, 1 per una transizione; qui 1 non è True. State.online conserva l’ultimo stato ricevuto.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
