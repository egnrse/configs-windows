# configs (windows) [WIP]
THIS IS STILL DEVELOPING and always will! PR/issues are very welcome.

This config is for Windows 10/11. It is based on my [linux configs](https://github.com/egnrse/configs).

Install in powershell with:
```ps1
Set-ExecutionPolicy -Scope Process Bypass
.\installV0.ps1 -verbose
```

<details>
	<summary>Custom Keymappings</summary>


`Win+R`			: launch runner (PowerToys+ahk)  
`Win+Shift+R`	: normal windows run dialog (ahk)  
`Win+Q`			: launch terminal (ahk)  

`Win+C`			: close active window (ahk)  
`Win+M`			: maximize (ahk)  
`Win+P`			: pin window to front (PowerToys)  

`Caps-Lock`		: escape (ahk)  
`Ctrl` x2		: find cursor (PowerToys)  
`Ctrl+Alt+T`	: show window info (ahk)  

</details>

## Synced configs:
- AutoHotkey
- git
- glazewm
- lazygit
- nvim
- powershell

### nvim
*(configs-linux/nvim/)*  
see [linux configs](https://github.com/egnrse/configs#nvim)

### other
Some other things in this git. (mostly in the `other` folder)  

#### PowerToys backups
load my settings with: General > Back up & restore > Restore

#### WinUtil
A windows debloater: https://github.com/ChrisTitusTech/winutil  
Run the following in a admin terminal (powershell):
```ps1
irm "https://christitus.com/win" | iex
```

import [my settings](./other/WinUtilSettings_202602.json) with: top-right corner cogweel > Import  


## Appendix

### Programs
zoxide fzf git  
glazewm zebar AutoHotkey  
nvim python ripgrep  
gpg lazygit ctags

### windows commands
```ps1
mklink /D linkdir targetdir
takeown.exe /F . /R
winget upgrade --all
```

### windows settings
System > Multitasking: Snap windows (can be disabled)  

### git submodule
```sh
git clone --recurse-submodules https://github.com/egnrse/configs-windows
git pull --recurse-submodules

git submodule add https://github.com/egnrse/configs.git ./configs-linux
git submodule update
git submodule update --init --recursive
```
