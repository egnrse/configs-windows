#Requires AutoHotkey 2.0
; some basic changes
; (by egnrse)
; #-Win, !-Alt, ^-Ctrl, +-Shift, &-CombineKeys

; map CapsLock to Esc
#HotIf WinActive
CapsLock::Esc


;; START APPS ;;

; Win+Q: (Windows) Terminal
#q::
{
	Run "wt.exe"
	; wait for PowerShell to start (timeout at 5sec)
	WinWait("PowerShell", , 5)
	WinActivate
}

; Win+D: App drawer

; Win+R: Run apps (using PowerToys)
#r::Send "#+^!r"
; Win+Shift+R: remap windows run
#+r::{
	Send "$#r"
}
