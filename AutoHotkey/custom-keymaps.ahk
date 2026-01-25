#Requires AutoHotkey 2.0
; #-Win, !-Alt, ^-Ctrl, +-Shift, &-CombineKeys

; system classes to ignore
; Taskbar, Desktop, Zeebar (might have collisions)
ignoreClassList := ["Shell_TrayWnd", "Progman", "Tauri Window"]

; Ctrl+Alt+T: Show window info
^!T::
{
	hwnd := WinExist("A")
	title := WinGetTitle("ahk_id " hwnd)
	class := WinGetClass("ahk_id " hwnd)
	minmax := WinGetMinMax("ahk_id " hwnd)
	MsgBox(
		"hwnd: " hwnd "`n"
		"title: " title "`n"
		"class: " class "`n"
		"Min/Max: " minmax
	)
}

; win+leftmousehold -> move window under cursor
;#LButton::
;{
;    ; get the window under cursor
;    MouseGetPos &start_x, &start_y, &hwnd
;	win_state := WinGetMinMax("ahk_id " hwnd)
;
;	/*
;	if win_state = 0
;		fn := CustomWindowMove.Bind(&hwnd, &start_x, &start_y)
;		SetTimer fn, 5
;		*/
;    WinGetPos &win_x, &win_y,,, "ahk_id " hwnd
;
;    ; loop while left button is down
;    while GetKeyState("LButton","P")
;    {
;        MouseGetPos &x1, &y1
;        dx := x1 - start_x
;        dy := y1 - start_y
;
;        ; move the window
;        WinMove win_x + dx, win_y + dy,,, "ahk_id " hwnd
;        Sleep 1
;    }
;}

CustomWindowMove(&hwnd, &start_x, &start_y)
{
    ; get position
	MouseGetPos &current_x, &current_y
    WinGetPos &win_x, &win_y,,, "ahk_id " hwnd
	; move the window
	WinMove win_x + current_x - start_x, win_y + current_y - start_y,,, "ahk_id " hwnd

	start_x := current_x
	start_y := current_y
	if not GetKeyState("LButton", "P")
	{
		SetTimer , 0
		return
	}
}

; Win+M: Maximize toggle
#m::
{
	hwnd := WinExist("A")
	minmax := WinGetMinMax("ahk_id " hwnd)

	if (minmax = 1)
		WinRestore("ahk_id " hwnd)
	else
		WinMaximize("ahk_id " hwnd)
}


; Win+D: App drawer
; Win+R: Run apps

; map CapsLock to Esc
#HotIf WinActive
CapsLock::Esc
