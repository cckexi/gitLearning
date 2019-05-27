FitSel(sel_Type,prop)
{
	if (prop == "")
		return 1
	Loop, parse, sel_Type, `,
	{
		if A_LoopField in % prop
			return 1
	}
	return 0
}

GetSelect()
{ 
	ClipSaved := ClipboardAll
    Clipboard =
    Send, ^c
    ClipWait,0.1
	Sel = %Clipboard% 
	Sel_All := ClipboardAll
	IsFile := DllCall("IsClipboardFormatAvailable","int",15)
	Clipboard := ClipSaved   
	ClipSaved =  
	
	if (!Strlen(Sel))
	{
		;未选中
		return ["None",""]
	}
	if (IsFile && RegExMatch(Sel,"(^.:\\.*)|(^\\\\.*)"))
	{
		; 多文件
		if RegExMatch(Sel,"\n")
			return ["File,MultiFile",Sel]
		; 磁盘
		if RegExMatch(Sel,"[a-zA-Z]:\\$")
			return ["File,Drive",Sel]
		; 文件夹
		if RegExMatch(FileExist(Sel),"D") 
			return ["File,Folder",Sel]
		; 带后缀
		Splitpath, Sel, Sel_Name, , Sel_Ext
		if Sel_Ext
		{
			Sel_Type := "File,Ext,." Sel_Ext
			keys := $.GetKeys("FileType")
			Loop, parse, keys, `n
			{
				if  Sel_Ext in % $.FileType[A_LoopField]
					Sel_Type .= "," A_LoopField
			}
			return [Sel_Type,Sel]
		}
		; 无后缀
		return ["File,NoExt",Sel]
	}
	else
	{
		; 文本
		Sel_Type := "Text"
		; 网址
		if (RegExMatch(Sel,"^\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))"))
			Sel_Type .= ",Url"
		return [Sel_Type,Sel]
	}
}

Explorer_GetSelection(hwnd="")   
{  
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")  
    WinGetClass class, ahk_id %hwnd%  
    if (process != "explorer.exe")  
        return  
    if (class ~= "Progman|WorkerW") {  
            ControlGet, files, List, Selected Col1, SysListView321, ahk_class %class%  
            Loop, Parse, files, `n, `r  
                ToReturn .= A_Desktop "\" A_LoopField "`n"  
        } else if (class ~= "(Cabinet|Explore)WClass") {  
            for window in ComObjCreate("Shell.Application").Windows 
			{
				try{
                if (window.hwnd==hwnd)  
                    sel := window.Document.SelectedItems  
				}catch e {
					continue
			}
			}
            for item in sel  
                ToReturn .= item.path "`n"  
        }  
    return Trim(ToReturn,"`n")  
} 
