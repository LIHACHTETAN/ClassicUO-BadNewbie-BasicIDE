Option Explicit On
Include "Windows.bas"

Function MeasureWait(ByVal delayMilliseconds As Integer) As Double
    If delayMilliseconds < 0 Then
        Throw "delayMilliseconds must be non-negative"
    End If
    Dim startedAt = Windows.Milliseconds()
    Wait(delayMilliseconds)
    Return Windows.ElapsedMilliseconds(startMilliseconds:=startedAt)
End Function

Sub Main()
    Dim elapsed = MeasureWait(15)
    Return elapsed >= 0
End Sub
