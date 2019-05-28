/*
    程序: 仿Listart(By_Kawvin)
    作用: ahk实现listary中的Ctrl+G打开最近目录等功能
    作者: Kawvin，改自sunwind
    版本: 0.1
    时间: 20180301
    使用方法：Ctrl+G
    脚本说明:
        0、ahk实现listary中的Ctrl+G打开最近目录等功能
        1、获取到的当前资源管理器打开的路径
        2、获取到的当前TotalCommand打开的路径
        3、获取excel文档路径(可以扩展其它常用应用的文档路径)【未启用】
        4、用弹出菜单展示
        5、在保存/打开对话框中点击菜单项，可以更换对话框到相应路径
        5、在非保存/打开对话框中点击菜单项，可以用资源管理器打开相应路径
        6、点击菜单项中的xls文档路径，可以跳转到文档所在路径（其它类型的office文档都可实现，暂未开发）
        7、最近使用的exe,点击可以激活
        8、常用路径,点击可以打开/切换
*/

#SingleInstance,Force

 ;定义主要变量内容
history=%A_ScriptDir%\history.txt
application=%A_ScriptDir%\application.txt
MostUsedDir=    ;最常用的路径
(Ltrim
    e:\2015年度公司架构及工作\联发滨海D2-1地块幕墙工程\X现场签证\2017年5月-新版预算【给业主的资料】\20170622-拟上报的签证单及联系单
    f:\TDDOWNLOAD
)

^g::    ;Ctrl+G 【Ctrl+G】运行主程序 ;{
    ;生成菜单
    ;添加菜单--目录
    HKN:=0
    HKStr:="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    Menu, MyMenu, Add  ; 添加分隔线.
    Menu, MyMenu,  DeleteAll ; 清空菜单项
    
    ;获取打开的目录，并添加到dir数组
    Menu, MyMenu, Add, 【当前打开的路径有】, MenuHandler
    Menu, MyMenu, Disable, 【当前打开的路径有】

    ;获取Explorer打开的目录，并添加到dir数组
    for oExplore in ComObjCreate("Shell.Application").Windows
    {  
        OutDir:=oExplore.LocationURL
        if (OutDir="") { ;剔除 资源管理器显示的 "库" 这种情况
            
        }else {
            fileread,AllDir,%history%
            IfNotInString,AllDir,%OutDir%
                Log(OutDir)
            HKN+=1
            HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
            MenuItem:=HKTem . OutDir
            Menu, MyMenu, Add, %MenuItem%, MenuHandler
        }
    }
    
    ;获取TC打开的目录，并添加到dir数组
    ifwinexist,ahk_class TTOTAL_CMD
    {
        ;左侧
        ;~ Postmessage, 1075, 132, 0,, ahk_class TTOTAL_CMD	;光标定位到焦点地址栏
        ;~ sleep 300
        PostMessage,1075,2029,0,,ahk_class TTOTAL_CMD ;获取路径
        sleep 100
        OutDir:=Clipboard
        If(OutDir!="ERROR"){		;错误则退出
            fileread,AllDir,%history%
            IfNotInString,AllDir,%OutDir%
                Log(OutDir)
            HKN+=1
            HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
            MenuItem:=HKTem . OutDir
            Menu, MyMenu, Add, %MenuItem%, MenuHandler
        }
        ;右侧
        ;~ Postmessage, 1075, 232, 0,, ahk_class TTOTAL_CMD	;光标定位到焦点地址栏
        ;~ sleep 300
        PostMessage,1075,2030,0,,ahk_class TTOTAL_CMD ;获取路径
        sleep 100
        OutDir:=Clipboard
        If(OutDir!="ERROR"){		;错误则退出
            fileread,AllDir,%history%
            IfNotInString,AllDir,%OutDir%
                Log(OutDir)
            HKN+=1
            HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
            MenuItem:=HKTem . OutDir
            Menu, MyMenu, Add, %MenuItem%, MenuHandler
        }
    }
    Menu, MyMenu, Add   ;添加分隔线
    

    ;~ ;获取已经打开的excel文档路径 ,这里可以扩展其它office文件的路径，并添加到dir数组
    ;~ try{
        ;~ oExcel := ComObjActive("Excel.Application")
        ;~ for Item in oExcel.workbooks
        ;~ {
            ;~ if (a_index=1){
                ;~ dir.Push("【当前打开的xls有】")
            ;~ }
            ;~ item:=oExcel.workbooks(A_index).FullName
            ;~ SplitPath,item,,OutDir ;获取Excel文件路径
            ;~ dir.Push(OutDir)
            ;~ Log(OutDir)
            ;~ oExcel.ActiveWindow.Caption :=Item
        ;~ }
    ;~ } catch e {
        
    ;~ }

    ;遍历【常用路径】
    Menu, MyMenu, Add, 【常用路径】, MenuHandler
    Menu, MyMenu, Disable, 【常用路径】
    loop,parse,MostUsedDir,"`n"
    {
        HKN+=1
        HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
        MenuItem:=HKTem .  LTrim(A_LoopField)
        Menu, MyMenu, Add, %MenuItem%, MenuHandler
    }
    Menu, MyMenu, Add   ;添加分隔线
    
    ;读取【最近使用的路径】
    Menu, MyMenu, Add, 【最近使用的路径】, MenuHandler
    Menu, MyMenu, Disable, 【最近使用的路径】
    gaopin:=getHistory(history)
    loop,parse,gaopin,"`n"
    {
        StringTrimLeft, Outdir, A_LoopField, 6 ; trim左侧6个字符
        if Outdir=
            continue
        ;~ MsgBox %Outdir%
        HKN+=1
        HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
        MenuItem:=HKTem .  Outdir
        Menu, MyMenu, Add, %MenuItem%, MenuHandler
    }
    Menu, MyMenu, Add   ;添加分隔线

    ;获取【最近使用的exe】
    _dir:=getExePath()
    Loop,parse,_dir,`n
    {
        fileread,AllApplication,%application%
        IfNotInString,AllApplication,%A_LoopField%
            Log2(A_LoopField,application)
    }
    Menu, MyMenu, Add, 【最近使用的exe】, MenuHandler
    Menu, MyMenu, Disable, 【最近使用的exe】
    Loop,Read,%application%
    {
        if (A_index>10)
            break
        if (not ( instr(A_LoopReadLine,"explorer")  OR instr(A_LoopReadLine,"CCC"))){
            if (A_LoopReadLine<>""){
                HKN+=1
                HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
                MenuItem:=HKTem . A_LoopReadLine
                Menu, MyMenu, Add, %MenuItem%, MenuHandler
            }
        }
    }  

    ;~ if (InStr(item,"file:///")){
        ;~ Menu, MyMenu, Add, %item%, MenuHandler
    ;~ }else if (InStr(item,"http")) {
        ;~ ;过滤掉http开头的。
    ;~ }else{
        ;~ Menu, MyMenu, Add, %item%, MenuHandler
    ;~ }

    ;显示菜单
    Menu, MyMenu, Show
return
;}

MenuHandler:    ;执行菜单项  ;{
    if (substr(A_ThisMenuItem,1,1)="&")
        T_ThisMenuItem:=substr(A_ThisMenuItem,5)
    if (instr(T_ThisMenuItem,".exe")){
        ;~ WinActivate,ahk_exe %T_ThisMenuItem%
        try {
            RunOrActivateProgram(T_ThisMenuItem)
        }catch{
            MsgBox, 16,, 本计算机上无此程序!
        }
    }else {
        WinGet, this_id,ID, A
        WinGetTitle, this_title, ahk_id %this_id%
        WinGetClass,this_class,ahk_id %this_id%
        if(this_class="#32770") { ;保存/打开对话框
            If(instr(this_title,"存") or instr(this_title,"Save") or instr(this_title,"文件")) {
                ChangePath(T_ThisMenuItem,this_id)   
            }else if(instr(this_title,"开") or instr(this_title,"Open")) {
                ChangePath(T_ThisMenuItem,this_id)   
            }
        } else  {  ;普通窗口
            try{
                OpenPath(T_ThisMenuItem)
            } catch e {
                MsgBox % "Error in " e.What ", which was called at line " e.Line  "`n" e.Message  "`n" e.Extra
            }
        }
    }
return
;}

OpenPath(_dir){ ;只是打开路径
    Run,"%_dir%"  
}

OpenAndSelect(){

}

ChangePath(_dir,this_id){
    WinActivate,ahk_id %this_id%
    ControlFocus,ReBarWindow321,ahk_id %this_id%
    ControlSend,ReBarWindow321,{f4},ahk_id %this_id%
    Loop{
        ControlFocus,Edit2,ahk_id %this_id%
        ControlGetFocus,f,ahk_id %this_id%
        if A_index>50 
            break
    }until (f="Edit2")
    ControlSetText,edit2,%_dir%,ahk_id %this_id%
    ControlSend,edit2,{Enter},ahk_id %this_id%
}

Log(debugstr){
    global
    FileAppend, %debugstr%`n, %history%
    return
}

Log2(debugstr,file){
    FileAppend, %debugstr%`n, %file%
    return
}

getHistory(history){
    ;获取最近使用的top10路径
    a := []
    b =
    Loop, read, %history%
    {
        last_line := A_LoopReadLine  ; 当循环结束时, 这里会保持最后一行的内容.
        if !a["" last_line]
            a["" last_line] := 1
        else
            a["" last_line] += 1
    }
    for c,d in a
    {
        d2 := SubStr("00000", 1, 5-strlen(d)) d
        str := d2 "_" c
        b .= b ? "`n" str : str
    }
    Sort, b, R
    e := StrSplit(b,"`n","`r")
    f =
    loop 10
        f .= f ? "`n" e[A_index] : e[A_index]
    return %f%
}

getExePath(){
    ;~ 打开当前激活窗口的exe程序所在目录
    ;~ for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
      ;~ WinGet, _ProcessPath, ProcessPath, A  
      ;~ Run,% "Explorer.exe /select, " _ProcessPath   
      ;~ return _ProcessPath
    WinGet, id, list
    Loop, %id%
    {
      this_id := id%A_Index%
      WinGet, pp, ProcessPath, ahk_id %this_id%
      out .= pp "`n"
    }
    ;~ MsgBox, % out
    return out
}

RunOrActivateProgram(Target,WinTitle=""){
    SplitPath,Target,TargetNameOnly
    Process,Exist,%TargetNameOnly%
    If ErrorLevel>0
        PID=%ErrorLevel%
    Else
        Run,%Target%,,,PID
    If WinTitle<>
    {
        SetTitleMatchMode,2
        WinWait,%WinTitle%,,3
        WinActivate,%WinTitle%
    }Else{
        WinWait,ahk_pid%PID%,,3
        WinActivate,ahk_pid%PID%
    }
    Return
}

#z::ExitApp