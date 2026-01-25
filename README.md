# configs (windows) [WIP]
THIS IS STILL DEVELOPING and always will! PR/issues are very welcome.

This config is for Windows 10/11. It is based on my [linux configs](https://github.com/egnrse/configs).

Install in powershell with:
```ps1
Set-ExecutionPolicy -Scope Process Bypass
.\installV0.ps1
```


## Synced configs:
- glazewm
- nvim

### nvim
*(configs-linux/nvim/)*  
see [linux configs](https://github.com/egnrse/configs#nvim)

## Appendix

### Programs
git nvim glazewm zebar

### windows commands
```ps1
mklink /D linkdir targetdir
winget upgrade --all
```

### git submodule
```sh
git submodule add https://github.com/egnrse/configs.git ./configs-linux
git submodule update
```
