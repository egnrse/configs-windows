# configs (windows) [WIP]
THIS IS STILL DEVELOPING and always will! PR/issues are very welcome.

This config is for Windows 10/11. It is based on my [linux configs](https://github.com/egnrse/configs).

Install in powershell with:
```ps1
Set-ExecutionPolicy -Scope Process Bypass
.\installV0.ps1
```


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

## Appendix

### Programs
zoxide fzf git
glazewm zebar AutoHotkey
nvim python ripgrep
gpg lazygit ctags

### windows debloater
https://github.com/ChrisTitusTech/winutil
```ps1
irm "https://christitus.com/win" | iex
```

### windows commands
```ps1
mklink /D linkdir targetdir
takeown.exe /F . /R
winget upgrade --all
```

### git submodule
```sh
git clone --recurse-submodules https://github.com/egnrse/configs-windows
git pull --recurse-submodules

git submodule add https://github.com/egnrse/configs.git ./configs-linux
git submodule update
git submodule update --init --recursive
```
