# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

CreateTimer는 정지한 콜백 타이머를 만듭니다. Start는 같은 스크립트 실행 스레드에서 Sub를 예약합니다. 이 프로젝트 확장은 경과 초를 읽는 Basic Timer()와 별개입니다.

## 정확한 구문

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

## 매개변수

- `milliseconds` — milliseconds는 1..2147483647 범위의 Integer 밀리초입니다. 문자열, 소수, 0, 음수는 오류입니다. SetInterval도 같은 규칙입니다. Interval()은 설정한 간격이지 남은 시간이 아닙니다.
- `handler` — 매개변수가 전혀 없는 고유한 Sub의 AddressOf 또는 현재 스크립트의 콜백 변수/팩터리입니다. Function, Optional/ParamArray, 이름 문자열, 다른 스크립트 참조는 거부됩니다. 공유 상태는 Module 필드에 저장하며 지역 클로저는 캡처하지 않습니다.
- `repeating` — 선택적인 세 번째 인수: True/1은 반복, False/0은 한 번 실행입니다. 기본값은 True이며 이름 있는 인수는 repeating:=입니다. 다른 숫자와 문자열은 오류입니다. 일회성 타이머는 처리기를 호출하기 전에 비활성화됩니다.
- `timer / Start / Stop / Dispose / SetInterval` — 메서드: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). 활성 타이머의 Start는 아무것도 바꾸지 않습니다. Stop 후 Start할 수 있습니다. SetInterval은 활성 상태이면 지금부터 다시 세고, 정지 상태이면 정지를 유지합니다. Dispose는 반복 호출할 수 있는 영구 해제이며 이후 Start/SetInterval은 실패합니다. Using은 종료 시 캡처한 객체를 해제합니다.

## 반환값

CreateTimer는 Object(ScriptTimer)를 반환하며 아이템 ID나 스크립트 인덱스가 아닙니다. Start/Stop/Dispose/SetInterval은 Unit입니다. Enabled는 Integer 1=True 또는 0=False로 둘 다 비교할 수 있습니다. Interval은 밀리초이며 Boolean이 아닙니다. 예제 결과는 String "3:0", "ready:0", "tick failed:0"입니다.

## 동작

- 명령 사이와 Basic Wait/Sleep 및 Wait Until 안에서 단조 경과 시간을 검사합니다. 활성 타이머가 있으면 Wait를 최대25밀리초 단위로 나눕니다. 게임 API나 다른 차단 네이티브 호출은 먼저 반환해야 합니다. 실시간 정밀도는 보장하지 않으며 새 스레드를 만들지 않습니다.
- 기한순, 같으면 생성순이며 검사당 최대64개 처리기를 호출하고 나머지는 다음 검사에서 실행합니다. 처리기 안에서는 Wait를 써도 다른 타이머가 재진입하지 않습니다. 반복 간격은 완료 후 시작하며 놓친 횟수는 쌓지 않습니다. 일시정지는 호출을 멈추고 재개 시 지연된 타이머를 한 번 실행합니다.
- 처리기 오류는 타이머를 끄고 호출자의 Catch/Finally로 전달됩니다. 처리기 안의 Stop/SetInterval은 반영됩니다. 비상정지는 일반 Catch가 삼키지 않습니다. 최상위 실행의 종료·오류·정지는 모든 타이머를 해제하며 재실행/재로드 시 다시 만들어야 합니다. IDE만 닫으면 실행 중 스크립트의 타이머는 유지됩니다. 미해제 타이머는 최대1024개이며 Dispose가 자리를 반환합니다.
- RunThreePulses와 GetHandler는 전체 코드가 있는 예제 보조 함수입니다. 내부 CreateTimer는 인수와 소유자를 검사하고 Start는 기한을 기록하며 Pump는 Sub를 호출합니다. Fire는 완료 후 다음 기한을 설정하고 Release는 루트 실행 종료 시 해제합니다. 종료 후 독립 서비스는 남지 않습니다.

## 예제

### 1. 세 번 호출 후 정리

```vb
# RunThreePulses는20밀리초와 기본 repeating=True를 사용합니다. CountPulse는 State.count를 증가시키고3에서 멈춥니다. Wait Until은3000밀리초 제한으로 상태와 타이머를 검사합니다. Enabled()=0이므로 "3:0"입니다. Return해도 Using이 해제합니다.
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

**매개변수 및 실행 설명:**

RunThreePulses는20밀리초와 기본 repeating=True를 사용합니다. CountPulse는 State.count를 증가시키고3에서 멈춥니다. Wait Until은3000밀리초 제한으로 상태와 타이머를 검사합니다. Enabled()=0이므로 "3:0"입니다. Return해도 Using이 해제합니다.

### 2. 이름 있는 인수와 일회성 호출

```vb
# GetHandler는 AddressOf SetReady를 반환합니다. 이름 있는 인수는5밀리초, callback, repeating=False입니다. SetInterval이 Start 전에10으로 바꿉니다. SetReady가 "ready"를 저장할 때 타이머는 이미 꺼졌습니다. Main은 최대3000밀리초 기다리고 "ready:0"을 반환합니다. 모든 보조 함수가 포함됩니다.
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

**매개변수 및 실행 설명:**

GetHandler는 AddressOf SetReady를 반환합니다. 이름 있는 인수는5밀리초, callback, repeating=False입니다. SetInterval이 Start 전에10으로 바꿉니다. SetReady가 "ready"를 저장할 때 타이머는 이미 꺼졌습니다. Main은 최대3000밀리초 기다리고 "ready:0"을 반환합니다. 모든 보조 함수가 포함됩니다.

### 3. Wait 중 오류 처리

```vb
# FailingPulse가 "tick failed"를 던집니다. 5밀리초 타이머가 Wait(2000) 안에서 실행되고 꺼지며 대기를 중단합니다. Catch는 문자열과 Enabled()=0을 저장하고 Finally가 해제합니다. "tick failed:0"은 메시지와 상태입니다. 비상정지는 엔진이 처리합니다.
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

**매개변수 및 실행 설명:**

FailingPulse가 "tick failed"를 던집니다. 5밀리초 타이머가 Wait(2000) 안에서 실행되고 꺼지며 대기를 중단합니다. Catch는 문자열과 Enabled()=0을 저장하고 Finally가 해제합니다. "tick failed:0"은 메시지와 상태입니다. 비상정지는 엔진이 처리합니다.


### 내부 함수: 호출부터 결과까지

RunThreePulses와 GetHandler는 전체 코드가 있는 예제 보조 함수입니다. 내부 CreateTimer는 인수와 소유자를 검사하고 Start는 기한을 기록하며 Pump는 Sub를 호출합니다. Fire는 완료 후 다음 기한을 설정하고 Release는 루트 실행 종료 시 해제합니다. 종료 후 독립 서비스는 남지 않습니다.

#### 1. CreateTimer

milliseconds는 1..2147483647 범위의 Integer 밀리초입니다. 문자열, 소수, 0, 음수는 오류입니다. SetInterval도 같은 규칙입니다. Interval()은 설정한 간격이지 남은 시간이 아닙니다.

매개변수가 전혀 없는 고유한 Sub의 AddressOf 또는 현재 스크립트의 콜백 변수/팩터리입니다. Function, Optional/ParamArray, 이름 문자열, 다른 스크립트 참조는 거부됩니다. 공유 상태는 Module 필드에 저장하며 지역 클로저는 캡처하지 않습니다.

선택적인 세 번째 인수: True/1은 반복, False/0은 한 번 실행입니다. 기본값은 True이며 이름 있는 인수는 repeating:=입니다. 다른 숫자와 문자열은 오류입니다. 일회성 타이머는 처리기를 호출하기 전에 비활성화됩니다.

CreateTimer는 Object(ScriptTimer)를 반환하며 아이템 ID나 스크립트 인덱스가 아닙니다. Start/Stop/Dispose/SetInterval은 Unit입니다. Enabled는 Integer 1=True 또는 0=False로 둘 다 비교할 수 있습니다. Interval은 밀리초이며 Boolean이 아닙니다. 예제 결과는 String "3:0", "ready:0", "tick failed:0"입니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; 함수 `CreateTimer`.

#### 2. Start

메서드: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). 활성 타이머의 Start는 아무것도 바꾸지 않습니다. Stop 후 Start할 수 있습니다. SetInterval은 활성 상태이면 지금부터 다시 세고, 정지 상태이면 정지를 유지합니다. Dispose는 반복 호출할 수 있는 영구 해제이며 이후 Start/SetInterval은 실패합니다. Using은 종료 시 캡처한 객체를 해제합니다.

`Due = now + interval; enabled = true;`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 함수 `Start`.

#### 3. WaitWithTimers

명령 사이와 Basic Wait/Sleep 및 Wait Until 안에서 단조 경과 시간을 검사합니다. 활성 타이머가 있으면 Wait를 최대25밀리초 단위로 나눕니다. 게임 API나 다른 차단 네이티브 호출은 먼저 반환해야 합니다. 실시간 정밀도는 보장하지 않으며 새 스레드를 만들지 않습니다.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; 함수 `WaitWithTimers`.

#### 4. Pump

기한순, 같으면 생성순이며 검사당 최대64개 처리기를 호출하고 나머지는 다음 검사에서 실행합니다. 처리기 안에서는 Wait를 써도 다른 타이머가 재진입하지 않습니다. 반복 간격은 완료 후 시작하며 놓친 횟수는 쌓지 않습니다. 일시정지는 호출을 멈추고 재개 시 지연된 타이머를 한 번 실행합니다.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; 함수 `Pump`.

#### 5. Fire

처리기 오류는 타이머를 끄고 호출자의 Catch/Finally로 전달됩니다. 처리기 안의 Stop/SetInterval은 반영됩니다. 비상정지는 일반 Catch가 삼키지 않습니다. 최상위 실행의 종료·오류·정지는 모든 타이머를 해제하며 재실행/재로드 시 다시 만들어야 합니다. IDE만 닫으면 실행 중 스크립트의 타이머는 유지됩니다. 미해제 타이머는 최대1024개이며 Dispose가 자리를 반환합니다.

`callback -> completion -> next Due; error -> disabled -> throw`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 함수 `Fire`.

#### 6. Dispose

메서드: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). 활성 타이머의 Start는 아무것도 바꾸지 않습니다. Stop 후 Start할 수 있습니다. SetInterval은 활성 상태이면 지금부터 다시 세고, 정지 상태이면 정지를 유지합니다. Dispose는 반복 호출할 수 있는 영구 해제이며 이후 Start/SetInterval은 실패합니다. Using은 종료 시 캡처한 객체를 해제합니다.

`Release -> scheduler.Remove -> Changed`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 함수 `Dispose`.

#### 7. Release

처리기 오류는 타이머를 끄고 호출자의 Catch/Finally로 전달됩니다. 처리기 안의 Stop/SetInterval은 반영됩니다. 비상정지는 일반 Catch가 삼키지 않습니다. 최상위 실행의 종료·오류·정지는 모든 타이머를 해제하며 재실행/재로드 시 다시 만들어야 합니다. IDE만 닫으면 실행 중 스크립트의 타이머는 유지됩니다. 미해제 타이머는 최대1024개이며 Dispose가 자리를 반환합니다.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; 함수 `Release`.

RunThreePulses는20밀리초와 기본 repeating=True를 사용합니다. CountPulse는 State.count를 증가시키고3에서 멈춥니다. Wait Until은3000밀리초 제한으로 상태와 타이머를 검사합니다. Enabled()=0이므로 "3:0"입니다. Return해도 Using이 해제합니다.

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
