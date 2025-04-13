' Ideal for Windows VMs and remote sessions c[_]
set WScriptShell = CreateObject("WScript.Shell")
Do
	WScript.Sleep(60000)
	WScriptShell.SendKeys("{NUMLOCK}")
	WScriptShell.SendKeys("{NUMLOCK}")
Loop