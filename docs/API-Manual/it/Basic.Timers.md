# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

CreateTimer crea un timer di callback fermo. Start pianifica una Sub sul thread dello script. È un’estensione del progetto, separata da Basic Timer(), che legge i secondi trascorsi.

## Sintassi esatta

```text
CreateTimer(milliseconds, handler) -> Object (ScriptTimer)
CreateTimer(milliseconds, handler, repeating) -> Object (ScriptTimer)
timer.Start() -> Unit
timer.Stop() -> Unit
timer.Dispose() -> Unit
timer.Enabled() -> Integer (0/1)
timer.Interval() -> Integer (ms)
timer.SetInterval(milliseconds) -> Unit
Using timer ... End Using
```

## Parametri

- `milliseconds` — Integer in millisecondi, 1..2147483647. Stringhe, frazioni, zero e valori negativi sono errori. Stessa regola per SetInterval. Interval() restituisce l’intervallo configurato, non il tempo residuo.
- `handler` — AddressOf una Sub univoca senza parametri, oppure una variabile/fabbrica di callback dello script caricato. Function, Optional/ParamArray, stringhe con nomi e riferimenti estranei sono rifiutati. Dati condivisi nei campi Module; nessuna chiusura locale.
- `repeating` — Terzo argomento facoltativo: True/1 ripete, False/0 esegue una volta. Predefinito True; nome repeating:=. Altri numeri e stringhe sono errori. Il timer singolo si disabilita prima del gestore.
- `timer / Start / Stop / Dispose / SetInterval` — Metodi: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start su un timer attivo non cambia nulla. Stop consente un successivo Start. SetInterval riparte da ora se attivo; un timer fermo rimane fermo. Dispose è ripetibile e definitivo; poi Start/SetInterval falliscono. Using libera l’oggetto catturato all’uscita.

## Restituisce

CreateTimer restituisce Object (ScriptTimer), non ID o indice di script. Start/Stop/Dispose/SetInterval restituiscono Unit. Enabled restituisce Integer 1=True oppure 0=False; entrambi i confronti sono validi. Interval indica millisecondi, non Boolean. Esempi: String "3:0", "ready:0", "tick failed:0".

## Comportamento

- Il tempo monotono viene controllato fra istruzioni e in Basic Wait/Sleep e Wait Until. Con timer attivi, Wait usa segmenti fino a 25 ms. Un comando di gioco o nativo bloccante deve prima terminare. Nessuna precisione garantita in tempo reale e nessun nuovo thread.
- Ordine per scadenza, poi creazione a parità; massimo 64 gestori per controllo, i restanti al prossimo. Nessuna rientranza durante un gestore, nemmeno con Wait. Il prossimo intervallo parte dal completamento; quelli persi vengono saltati. Pausa sospende i gestori; riprendendo, un timer scaduto viene chiamato una volta.
- Un errore disabilita il timer e raggiunge Catch/Finally. Stop/SetInterval nel gestore vengono rispettati. Catch non assorbe l’arresto d’emergenza. Fine, errore o arresto della chiamata radice liberano i timer; ricrearli al prossimo avvio/caricamento. Chiudere solo l’IDE conserva quelli dello script attivo. Limite 1024 timer non liberati; Dispose libera uno spazio.
- RunThreePulses e GetHandler sono ausiliari mostrati integralmente. Internamente CreateTimer valida argomenti/proprietario, Start imposta la scadenza, Pump chiama la Sub, Fire ripianifica dopo il completamento, Release libera alla fine. Nessun servizio separato continua dopo lo script.

## Esempi

### 1. Tre chiamate e pulizia

```vb
# RunThreePulses usa 20 ms e repeating=True predefinito. CountPulse incrementa State.count e ferma a tre. Wait Until controlla stato e timer entro 3000 ms. Enabled()=0 produce "3:0". Using libera anche con Return.
Option Explicit On
Module State
    Public Dim count As Integer = 0
    Public Dim pulse
End Module

Sub CountPulse()
    State.count += 1
    If State.count >= 3 Then
        State.pulse.Stop()
    End If
End Sub

Function RunThreePulses() As String
    State.pulse = CreateTimer(20, AddressOf CountPulse)
    Using State.pulse
        State.pulse.Start()
        Wait Until State.count >= 3 Timeout 3000
        Return CStr(State.count) & ":" & CStr(State.pulse.Enabled())
    End Using
End Function

Sub Main()
    Return RunThreePulses()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

RunThreePulses usa 20 ms e repeating=True predefinito. CountPulse incrementa State.count e ferma a tre. Wait Until controlla stato e timer entro 3000 ms. Enabled()=0 produce "3:0". Using libera anche con Return.

### 2. Chiamata singola con nomi

```vb
# GetHandler restituisce AddressOf SetReady. Argomenti nominati: 5 ms, callback, repeating=False. SetInterval cambia a 10 prima di Start. SetReady scrive "ready"; il timer è già disabilitato. Main attende fino a 3000 ms e restituisce "ready:0". Tutti gli ausiliari sono inclusi.
Option Explicit On
Module State
    Public Dim message As String = ""
End Module

Sub SetReady()
    State.message = "ready"
End Sub

Function GetHandler()
    Return AddressOf SetReady
End Function

Sub Main()
    Dim callback = GetHandler()
    Dim notice = CreateTimer(repeating:=False, handler:=callback, milliseconds:=5)
    Using notice
        notice.SetInterval(10)
        notice.Start()
        Wait Until State.message = "ready" Timeout 3000
        Return State.message & ":" & CStr(notice.Enabled())
    End Using
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

GetHandler restituisce AddressOf SetReady. Argomenti nominati: 5 ms, callback, repeating=False. SetInterval cambia a 10 prima di Start. SetReady scrive "ready"; il timer è già disabilitato. Main attende fino a 3000 ms e restituisce "ready:0". Tutti gli ausiliari sono inclusi.

### 3. Errore durante Wait

```vb
# FailingPulse genera "tick failed". Il timer da 5 ms opera in Wait(2000), si disabilita e interrompe l’attesa. Catch legge testo e Enabled()=0; Finally libera. "tick failed:0" contiene messaggio e stato. L’arresto d’emergenza resta gestito dal motore.
Option Explicit On
Sub FailingPulse()
    Throw "tick failed"
End Sub

Sub Main()
    Dim pulse = CreateTimer(5, AddressOf FailingPulse)
    Dim problemText As String = ""
    Dim enabledAfterError As Boolean = True
    Try
        pulse.Start()
        Wait(2000)
    Catch problem
        problemText = problem
        enabledAfterError = pulse.Enabled()
    Finally
        pulse.Dispose()
    End Try
    Return problemText & ":" & CStr(enabledAfterError)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

FailingPulse genera "tick failed". Il timer da 5 ms opera in Wait(2000), si disabilita e interrompe l’attesa. Catch legge testo e Enabled()=0; Finally libera. "tick failed:0" contiene messaggio e stato. L’arresto d’emergenza resta gestito dal motore.


### Funzioni interne: dalla chiamata al risultato

RunThreePulses e GetHandler sono ausiliari mostrati integralmente. Internamente CreateTimer valida argomenti/proprietario, Start imposta la scadenza, Pump chiama la Sub, Fire ripianifica dopo il completamento, Release libera alla fine. Nessun servizio separato continua dopo lo script.

#### 1. CreateTimer

Integer in millisecondi, 1..2147483647. Stringhe, frazioni, zero e valori negativi sono errori. Stessa regola per SetInterval. Interval() restituisce l’intervallo configurato, non il tempo residuo.

AddressOf una Sub univoca senza parametri, oppure una variabile/fabbrica di callback dello script caricato. Function, Optional/ParamArray, stringhe con nomi e riferimenti estranei sono rifiutati. Dati condivisi nei campi Module; nessuna chiusura locale.

Terzo argomento facoltativo: True/1 ripete, False/0 esegue una volta. Predefinito True; nome repeating:=. Altri numeri e stringhe sono errori. Il timer singolo si disabilita prima del gestore.

CreateTimer restituisce Object (ScriptTimer), non ID o indice di script. Start/Stop/Dispose/SetInterval restituiscono Unit. Enabled restituisce Integer 1=True oppure 0=False; entrambi i confronti sono validi. Interval indica millisecondi, non Boolean. Esempi: String "3:0", "ready:0", "tick failed:0".

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; funzione `CreateTimer`.

#### 2. Start

Metodi: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start su un timer attivo non cambia nulla. Stop consente un successivo Start. SetInterval riparte da ora se attivo; un timer fermo rimane fermo. Dispose è ripetibile e definitivo; poi Start/SetInterval falliscono. Using libera l’oggetto catturato all’uscita.

`Due = now + interval; enabled = true;`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; funzione `Start`.

#### 3. WaitWithTimers

Il tempo monotono viene controllato fra istruzioni e in Basic Wait/Sleep e Wait Until. Con timer attivi, Wait usa segmenti fino a 25 ms. Un comando di gioco o nativo bloccante deve prima terminare. Nessuna precisione garantita in tempo reale e nessun nuovo thread.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; funzione `WaitWithTimers`.

#### 4. Pump

Ordine per scadenza, poi creazione a parità; massimo 64 gestori per controllo, i restanti al prossimo. Nessuna rientranza durante un gestore, nemmeno con Wait. Il prossimo intervallo parte dal completamento; quelli persi vengono saltati. Pausa sospende i gestori; riprendendo, un timer scaduto viene chiamato una volta.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; funzione `Pump`.

#### 5. Fire

Un errore disabilita il timer e raggiunge Catch/Finally. Stop/SetInterval nel gestore vengono rispettati. Catch non assorbe l’arresto d’emergenza. Fine, errore o arresto della chiamata radice liberano i timer; ricrearli al prossimo avvio/caricamento. Chiudere solo l’IDE conserva quelli dello script attivo. Limite 1024 timer non liberati; Dispose libera uno spazio.

`callback -> completion -> next Due; error -> disabled -> throw`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; funzione `Fire`.

#### 6. Dispose

Metodi: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start su un timer attivo non cambia nulla. Stop consente un successivo Start. SetInterval riparte da ora se attivo; un timer fermo rimane fermo. Dispose è ripetibile e definitivo; poi Start/SetInterval falliscono. Using libera l’oggetto catturato all’uscita.

`Release -> scheduler.Remove -> Changed`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; funzione `Dispose`.

#### 7. Release

Un errore disabilita il timer e raggiunge Catch/Finally. Stop/SetInterval nel gestore vengono rispettati. Catch non assorbe l’arresto d’emergenza. Fine, errore o arresto della chiamata radice liberano i timer; ricrearli al prossimo avvio/caricamento. Chiudere solo l’IDE conserva quelli dello script attivo. Limite 1024 timer non liberati; Dispose libera uno spazio.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; funzione `Release`.

RunThreePulses usa 20 ms e repeating=True predefinito. CountPulse incrementa State.count e ferma a tre. Wait Until controlla stato e timer entro 3000 ms. Enabled()=0 produce "3:0". Using libera anche con Return.

<!-- implementation references (not callable script procedures):
Runtime/InjectionApi.cs: CreateTimer / Wait
Runtime/Interpreter.Timers.cs: CreateTimer / WaitWithTimers / TimerCheckpoint
Runtime/ScriptTimerScheduler.cs: Pump / Delay / Release
Runtime/ObjectTypes/ScriptTimerObject.cs: Start / Fire / SetInterval / Dispose
Runtime/Interpreter.cs: statement checkpoints / VisitWaitUntilStatement / root-call cleanup
Runtime/RealTimeSource.cs: Stopwatch elapsed time
https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.stopwatch
https://learn.microsoft.com/en-us/dotnet/api/system.threading.timer (comparison only; this script timer does not use ThreadPool callbacks)
-->
