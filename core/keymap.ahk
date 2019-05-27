aSecs := $G.GetSections()
Loop, parse, aSecs, `n
{
	gName := A_LoopField
	Loop, parse, % $G[gName]["Exe"], `,
		GroupAdd, %gName%, ahk_exe %A_LoopField%
	Loop, parse, % $G[gName]["Class"], `,
		GroupAdd, %gName%, ahk_class %A_LoopField%
	Loop, parse, % $G[gName]["Title"], `,
		GroupAdd, %gName%, %A_LoopField%
}
//====

global $ := class_EasyIni("VriyHotKey.ini")

Loop, parse, % $.IME.CnExe, `,
	GroupAdd, CnGroup, ahk_exe %A_LoopField%
Loop, parse, % $.IME.CnClass, `,
	GroupAdd, CnGroup, ahk_class %A_LoopField%
Loop, parse, % $.IME.EnExe, `,
	GroupAdd, EnGroup, ahk_exe %A_LoopField%
Loop, parse, % $.IME.EnClass, `,
	GroupAdd, EnGroup, ahk_class %A_LoopField%

InitHotKey("^Title ")
InitHotKey("^Exe ")
InitHotKey("^Class ")
InitHotKey("^Group ")
InitHotKey("^Global$")


InitHotKey(sExp)
{
	aSecs := $.FindSecs(sExp)
	Loop, % aSecs.Length()
	{
		sec := aSecs[A_Index]
		StringLeft, sType, sec, 5
		if (sType = "Group")
		{
			GroupName := SubStr(sec, 7)
			Loop, parse, % $[sec]["Exe"], `,
				GroupAdd, %GroupName%, ahk_exe %A_LoopField%
			Loop, parse, % $[sec]["Class"], `,
				GroupAdd, %GroupName%, ahk_class %A_LoopField%
			Loop, parse, % $[sec]["Title"], `,
				GroupAdd, %GroupName%, %A_LoopField%
		}
		if (sec = "Global")
		{
			Loop, parse, % $.Global.ExExe, `,
				GroupAdd, ExGroup, ahk_exe %A_LoopField%
			Loop, parse, % $.Global.ExClass, `,
				GroupAdd, ExGroup, ahk_class %A_LoopField%
			Loop, parse, % $.Global.ExTitle, `,
				GroupAdd, ExGroup, %A_LoopField%
			
			Hotkey, IfWinNotActive, ahk_group ExGroup
		}
		else if (sType = "Title")
			Hotkey, IfWinActive, % SubStr(sec, 7)
		else
			Hotkey, IfWinActive, % "ahk_" sec
		Loop, parse, % $.GetKeys(sec), `n
		{
			key := A_LoopField
			if (key = "Exe" || key = "Class" || key = "Title")
				continue
			if (key = "ExExe" || key = "ExClass" || key = "ExTitle")
				continue
			
			fn := Func("Vriy").Bind($[sec][key])
			Hotkey, % key , %fn%, UseErrorLevel
		}
		continue
	}
}

Vriy(sAct)
{
	sVal := SubStr(sAct, 3)
	StringLeft, sType, sAct, 2
	if (sType = "")
		return
	else if (sType = "R:")
		RunActive(sVal)
	else if (sType = "S:")
		Send, % sVal
	else if (sType = "G:")
		gosub, % sVal
	else if (sType = "I:")
		return
	else if (sType = "M:")
		MsgBox, % sVal
	
	return
}