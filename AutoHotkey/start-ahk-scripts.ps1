# start my ahk scripts on login
# this file should be linked into '$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup'
# (by egnrse)

# path to autohotkey exe
$ahk = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

# path to your main script
$script = "$env:userprofile\Documents\ahk\main.ahk"

Start-Process $ahk $script

