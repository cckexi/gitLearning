FitScope(scope,prop)
{
	if (prop == "" && SubStr(scope,1,1) != "@")
		return 1
	Loop, parse, scope, `,
	{
		if A_LoopField in % prop
			return 1
	}
	return 0
}

GetPosition()
{
	S_Value =
	CoordMode, Mouse, Screen
	MouseGetPos, smX, smY, winId
	WinGetPos, winX, winY, wWidth, wHeight, ahk_id %winId%
	
	AllScope := $.GetKeys("Scope")
	Loop, parse, AllScope, `n
	{
		scope := $.Scope[A_LoopField]
		coord := StrSplit(SubStr(scope,3),",")
		if (coord.Length() >= 4)
		{
			if (SubStr(scope,1,1) = "A")
			{
				aX := (coord.1 >= 0 ? coord.1 : A_ScreenWidth + coord.1)
				aY := (coord.2 >= 0 ? coord.2 : A_ScreenHeight + coord.2)
				bX := (coord.3 >= 0 ? coord.3 : A_ScreenWidth + coord.3)
				bY := (coord.4 >= 0 ? coord.4 : A_ScreenHeight + coord.4)
			}
			else
			{
				aX := winX + (coord.1 >= 0 ? coord.1 : wWidth + coord.1)
				aY := winY + (coord.2 >= 0 ? coord.2 : wHeight + coord.2)
				bX := winX + (coord.3 >= 0 ? coord.3 : wWidth + coord.3)
				bY := winY + (coord.4 >= 0 ? coord.4 : wHeight + coord.4)
			}
			if (aX <= smX && bX >= smX && aY <= smY && bY >= smY)
			{
				if (SubStr(A_LoopField,1,1) = "@")
					return A_LoopField
				S_Value .= A_LoopField ","
			}
		}
	}
	return S_Value
}