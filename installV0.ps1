Write-Output "script is not ready yet"
exit 1


# run as admin or with developer mode enabled

# install programs
winget install --id Microsoft.PowerShell --source winget
winget install Git.Git
winget install Neovim.Neovim
winget install glzr-io.glazewm

# link glazewm config
if (Test-Path "$env:USERPROFILE\.glzr") {
	Remove-Item "$env:USERPROFILE\.glzr" -Recurse -Force
}
New-Item -ItemType SymbolicLink `
	-Path "$env:USERPROFILE\.glzr" `
	-Target "$env:USERPROFILE\.config\glazewm"
