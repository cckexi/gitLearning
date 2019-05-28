;~ #include core\action.ahk
#include core\config.ahk
;~ #include core\keymap.ahk
;~ #include core\menus.ahk
;~ #include core\position.ahk
;~ #include core\selection.ahk
;~ #include core\window.ahk

;~ global $ = readConfig("config\\config.json")
;~ global $keymap = readConfig("config\\keymap\\global.json")

Loop, config\keymap\*.json
{
	keymap := loadConfig(A_LoopFileFullPath)
	if(keymap.window.Count()>0)
	{
		includeGroup := A_LoopFileName "includeGroup"
		excludeGroup := A_LoopFileName "excludeGroup"
		Loop, % keymap.window.Count()
		{
			MsgBox % keymap.window[A_Index]
		}
	}
}

;~ a:="ahk_class Chrome_WidgetWin_1"
;~ b:="ahk_exe Code.exe"
;~ #If (WinActive(a) and !WinActive(b))
;~ Hotkey, !v, MyLabel
;~ Hotkey, !s, MyLabel
;~ return



MyLabel:
MsgBox you pressed %A_ThisHotKey%.
return
