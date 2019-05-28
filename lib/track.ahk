loop
{
    ; Get current Window ID & Name
    WinGet, active_id, ID, A
    WinGet, process_name, ProcessName, A

    ; Only do anything if any other windows was activated
    if(active_id = PrevActiveId)
    {
        ; Do nothing
    }
    else
    {
        ; Format the time-stamp.
        current=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%

        ; Write this data to the log.txt file.
        fileappend, %current% - %process_name%`n, log.txt

        ; Get the URL if process_name = "chrome.exe"
        if(process_name = "chrome.exe")
        {
            ; Put URL in log file
            ; fileappend, %current% - %current_url%`n, log.txt
        }
    }

    PrevActiveId = %active_id%
    Sleep, 100
}