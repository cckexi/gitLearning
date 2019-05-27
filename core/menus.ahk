!v::
MButton::
	Menu, VMenu, Add
	Menu, VMenu, DeleteAll
	isMouse := InStr(A_ThisHotkey,"Button") || InStr(A_ThisHotkey,"Wheel") 
	if isMouse
		scope := GetScope()
	sel := SubStr(scope,1,1) != "@" ? GetSelect() : ["",""]
	selname := GetShortName(sel[2])
	Menu, VMenu, Add, V-Menu, Label_Copy
	;~ menu, VMenu, icon, V-Menu, shell32.dll, 4
	menu, VMenu, disable, V-Menu
	menu, VMenu, Default, V-Menu
	if isMouse
	{
		MouseGetPos, , , winId
		IfWinNotActive, ahk_Id %winId%
			WinActivate, ahk_Id %winId%
	}
	hasMenu := 0
	mSecs := $M.GetSections()
	Loop, parse, mSecs, `n
	{
		mScope := $M[A_LoopField]["!Scope"]
		if (SubStr(A_LoopField,1,2) = "S_")
			continue
		if ((isMouse && !FitScope(scope,mScope)) || !FitWin(A_LoopField))
			continue	
		if (SubStr(A_LoopField,1,2) = "N_")		
		{
			hasMenu := 0
			break
		}		
		if (!FitSel(sel[1],$M[A_LoopField]["!Select"]))
			continue
		
		Menu, VMenu, Add
		hasMenu := CreateSubMenu(A_LoopField,"VMenu")
	}
	if hasMenu
		Menu, VMenu, Show
	else
		Send {MButton}
	return

CreateSubMenu(Name,ParentMenu)
{
	hasMenu := 0
	mkeys := $M.GetKeys(Name)
	Loop, parse, mkeys, `n
	{
		; 属性
		if (SubStr(A_LoopField,1,1) = "!")
			continue
		; 分隔线
		if (SubStr(A_LoopField,1,1) = "-")
		{
			Menu, %ParentMenu%, Add
			continue
		}
		; 菜单项
		temp := _SplitStr($M[Name][A_LoopField], ":")
		sCmd := temp[1]
		temp := _SplitStr(temp[2], " |", 0)
		args := StrSplit(temp[1], ",")
		aIco := StrSplit(temp[2], ",")
		
		if (sCmd = "Menu")
		{
			subName := args[1]
			Menu, %subName%, Add
			Menu, %subName%, DeleteAll
			CreateSubMenu(subName,subName)
			Menu, %ParentMenu%, Add, %A_LoopField%, :%subName%
		}
		else
		{
			fn := Func("VDo").Bind(sCmd,args)
			Menu, %ParentMenu%, Add, %A_LoopField%, %fn%
		}
		try
		{
			ico := aIco[1]
			num := aIco[2]
			Menu, %ParentMenu%, icon, %A_LoopField%, %ico%, %num%
		}
		hasMenu := 1
	}
	return hasMenu
}

VDo(cmd,args)
{
;~ RunA, RunD, RunO, RunP, RunW, Send, Clip, Show, GoTo, Func, Mode, Menu
	#%cmd%(args)
}