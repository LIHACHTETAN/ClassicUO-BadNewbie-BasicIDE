Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["delay"]=350
    Config.SetFlag(settings, "enabled", True)
    Config.Save("demo-settings.json", settings)
    Dim loaded=Config.Load("demo-settings.json", Dictionary())
    Return CStr(Config.GetFlag(loaded, "enabled")) & ":" & CStr(loaded["delay"])
End Sub
