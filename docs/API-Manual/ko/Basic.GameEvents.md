# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

AddHandler로 새 저널 항목, 캐릭터 자원 및 연결 상태 변화를 구독합니다. 이 UO. 이름은 함수가 아닌 이벤트이므로 괄호로 호출하거나 RaiseEvent로 발생시킬 수 없습니다.

## 정확한 구문

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

## 매개변수

- `Handler / AddressOf` — 현재 로드한 스크립트의 Sub를 AddressOf로 전달하세요. 모든 매개변수에 ByVal을 명시하고 서명의 형식과 순서를 맞춰야 합니다. Function, Optional, ParamArray와 다른 스크립트의 콜백은 허용하지 않습니다.
- `text / serial / name / hue` — JournalEntry는 text String, serial Integer(출처 ID, 없으면 0), name String, hue Integer(UO 색조 인덱스, RGB 아님)를 전달합니다. Serial은 아이템 그래픽/type이 아닙니다. 문자열은 비어 있을 수 있습니다. 저널 항목 재사용 전에 값을 복사하며 구독 이후 새 항목만 전달합니다. 로컬 메시지도 포함됩니다.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged의 current와 previous는 현재와 이전 절대 포인트 수인 Integer입니다. 백분율이나 Boolean이 아닙니다. 클라이언트 갱신마다 비교하므로 중간 변화가 합쳐질 수 있습니다. 초기 상태와 캐릭터 변경은 새 기준을 만들며 자원 이벤트를 보내지 않습니다.
- `online` — ConnectionChanged의 online은 Boolean입니다. True/1은 클라이언트 세계에 플레이어와 지도가 있음, False/0은 없음을 뜻합니다. 원격 소켓 정상 여부 검사가 아니며 초기 이벤트도 재생하지 않습니다.
- `RemoveHandler` — RemoveHandler는 마지막으로 일치하는 구독을 제거합니다. 중복은 등록 순서대로 여러 번 호출됩니다. 현재 메시지는 고정된 처리기 목록을 사용하며 변경은 다음 메시지에 적용됩니다. 마지막 처리기를 제거하면 큐가 해제됩니다.

## 반환값

AddHandler, RemoveHandler와 Sub는 값을 반환하지 않습니다(Unit). 결과는 공유 Module 필드에 저장하세요. online과 논리 조건만 1/0 = True/False입니다. serial, hue, 자원 포인트 및 State.changes는 ID 또는 수량입니다.

## 동작

- 클라이언트는 복사한 데이터만 큐에 넣습니다. 처리기는 스크립트의 스레드에서 문장 사이 및 Wait, Sleep, UO.Wait, Wait Until 중에 실행되며 동시에 겹치지 않습니다. 검사 간격은 최소 25 ms, 회당 이벤트별 최대 16개 메시지입니다. 긴 네이티브 호출은 전달을 지연합니다.
- 일시 정지 중에는 실행하지 않고 메시지를 쌓습니다. Stop은 취소하고 구독을 해제하며 Catch로 긴급 중지를 삼킬 수 없습니다. 최상위 프로시저 반환이나 오류 시 클라이언트 구독을 삭제하고 새 실행에 남기지 않습니다. IDE를 닫아도 실행 중인 스크립트는 계속됩니다. 연결 해제 자동 일시 정지는 재개까지 이벤트를 지연합니다.
- 이벤트별 큐 한도는 256개입니다. 초과하면 잡을 수 있는 오류를 발생시키고 해당 구독을 비활성화합니다. 처리기 오류도 구독을 끄고 같은 메시지의 나머지 처리기를 건너뜁니다. Catch/Finally 후 다시 구독할 수 있습니다. 모든 저널 메시지를 같은 저널에 다시 출력하지 마세요.
- 이 다섯 이벤트는 Basic IDE가 켜진 Full에서 지원됩니다. 다른 이벤트, 패킷 구독, Handles 및 WithEvents는 포함하지 않습니다. 스크립트 선언 이벤트는 Basic.Events를 참고하세요.

## 예제

### 1. 새 저널 메시지 찾기

```vb
# OnJournal은 네 인자를 받습니다. 전체 IsReadyMessage 함수는 InStr > 0으로 문구 존재 여부를 확인합니다. 로컬 메시지가 State.message를 설정하며 Wait Until은 최대 5000 ms 후 타임아웃 오류를 냅니다. Finally에서 해제합니다. Main은 "ready: ore"를 반환합니다.
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

**매개변수 및 실행 설명:**

OnJournal은 네 인자를 받습니다. 전체 IsReadyMessage 함수는 InStr > 0으로 문구 존재 여부를 확인합니다. 로컬 메시지가 State.message를 설정하며 Wait Until은 최대 5000 ms 후 타임아웃 오류를 냅니다. Finally에서 해제합니다. Main은 "ready: ore"를 반환합니다.

### 2. 자원 관찰

```vb
# 세 처리기가 current/previous를 전체 Remember 프로시저에 전달합니다. State.changes는 알림 수, State.last는 SP:58:60 같은 마지막 문자열입니다. Wait(250) 후 최대 5000 ms 변화를 기다리며 없으면 타임아웃입니다. Finally가 세 구독을 해제합니다. 결과는 Boolean 아닌 String입니다.
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

**매개변수 및 실행 설명:**

세 처리기가 current/previous를 전체 Remember 프로시저에 전달합니다. State.changes는 알림 수, State.last는 SP:58:60 같은 마지막 문자열입니다. Wait(250) 후 최대 5000 ms 변화를 기다리며 없으면 타임아웃입니다. Finally가 세 구독을 해제합니다. 결과는 Boolean 아닌 String입니다.

### 3. 연결 관찰

```vb
# OnConnection은 Boolean online을 받아 Wait(1000) 동안 전환 수를 셉니다. Finally에서 해제하고 Main은 횟수를 반환합니다. 0은 변화 없음, 1은 한 번이지 True가 아닙니다. State.online은 마지막으로 받은 상태이며 초기 조회가 아닙니다.
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

**매개변수 및 실행 설명:**

OnConnection은 Boolean online을 받아 Wait(1000) 동안 전환 수를 셉니다. Finally에서 해제하고 Main은 횟수를 반환합니다. 0은 변화 없음, 1은 한 번이지 True가 아닙니다. State.online은 마지막으로 받은 상태이며 초기 조회가 아닙니다.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
