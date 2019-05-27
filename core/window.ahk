FitWin(sec)
{
	P := "!ExTitle,!InTitle,!ExExe,!InExe,!ExClass,!InClass,!ExGroup,!InGroup"
	hasIn := 0
	Loop, parse, P, `,
	{
		prop := $M[sec][A_LoopField]
		if (prop != "")
		{
			typ := SubStr(A_LoopField,4)
			pfx := (typ != "Title") ? "ahk_" typ " " : ""
			isIn := SubStr(A_LoopField,1,3) = "!In"
			hasIn := hasIn || isIn
			Loop, parse, prop, `,
			{
				IfWinActive, % pfx A_LoopField
					return isIn
			}
		}
	}
	return !hasIn
}