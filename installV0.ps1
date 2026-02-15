# simple install script
# run as admin or with developer mode enabled
# (by egnrse)
param(
	[switch]$Verbose
)

## CONSTANTS ########################################
$Esc = [char]27
$Reset = "${Esc}[0m"

## FUNCTIONS ########################################

function Write-Header {
	param(
		[string]$Text
	)
	Write-Host "${Text}" -ForegroundColor Green
}

function skip {
	[CmdletBinding()]
	param(
			# text to display
			[string]$text,
			# set default answer to 'no'
			[Alias("n")]
			[switch]$not
		 )
	if (!($PSBoundParameters.ContainsKey('text'))) {
		$text = "continue [y] or skip [n]"
	}

	if ($not) {
		switch -Regex ((Read-Host "$text (y|N)").ToLower()) {
			default 		{ return $true }
			'(^n.*$|^$)'	{ return $false  }
		}
	}
	else {
		switch -Regex ((Read-Host "$text (Y|n)").ToLower()) {
			'(^y.*$|^$)'	{ return $true  }
			default 		{ return $false }
		}
	}
}

# install a program with winget
function install {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory)]
			[string[]]$ProgramList
		 )

	foreach ($prog in $ProgramList) {
		Write-Verbose "installing '$prog'"
		winget install --id $prog
	}
}

# creates a link at $Path, linking to $Source
# (backups previous files, deletes links)
function link-config {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory)]
			[string]$Path,
			[Parameter(Mandatory)]
			[string]$Source
		 )
	if (!(Test-Path "$Source")) {
		throw "source does not exist: '$Source'"
	}
	if (Test-Path "$Path") {
		$item = Get-Item -LiteralPath $Path -Force
		if ($item.LinkType -ne $null) {
			Remove-Item -LiteralPath "$Path" -Force 
			Write-Verbose "deleting symlink: '$Path'"
		}
		else {
			# backup the file/folder
			$PathClean = $Path -replace '\\+$','' # remove trailing ''\'
			$backup = "${PathClean}.bak_$(Get-Date -Format yyyyMMdd_HHmmss)"
			Move-Item $Path $backup
			Write-Verbose "created backup at: '$backup'"
		}
	}
	$fullSource = (Resolve-Path $Source).Path
	
	$Dir = Split-Path -parent $Path
	if (!(Test-Path -Path $Dir)) {
		Write-Verbose "create parent directory: '$Dir'"
		New-Item -ItemType Directory -Path $Dir | Out-Null
	}
	New-Item -ItemType SymbolicLink `
		-Path "$Path" `
		-Target "$fullSource" `
		| Out-Null
	Write-Verbose "linked: '$Path' -> '$Source'"
}

function ask-link {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory)]
			[string]$Path,
			[Parameter(Mandatory)]
			[string]$Source,
			[string]$text
		 )
	if (!($PSBoundParameters.ContainsKey('text'))) {
		$text = "link '$Path'"
	}
	if (skip "$text") {
		link-config "$Path" "$Source"
	}
}

# add an import statement to $file which imports $import
function add-import {
	[CmdletBinding()]
	param(
			[string]$file,
			[string]$import,
			# dont change $import, but use it directly
			[Alias("c")]
			[switch]$clean
		 )
	if(!${clean}){
		$import = (Resolve-Path $import).Path
		$importLine = ". $import"
	}
	else {
		$importLine = $import
	}
	$saveImportLine = [regex]::Escape($importLine)
	
	if (Get-Content $file | Select-String -Pattern $saveImportLine) {
		Write-Verbose "Skipping: already sourced in '$file'"
	} else {
		Add-Content -Path $file -Value $importLine
		Write-Verbose "Added '$importLine' to $file"
	}
}

# adds $Source to the user startup folder
# by creating a '.lnk' link
function add-startup {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory)]
			[string]$Source,
			# delete the link
			[Alias("del","d")]
			[switch]$delete,
			[string]$Name
		 )
	$Source = (Resolve-Path $Source).Path
	$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"	

	# make sure the startup folder exists
	$dir = Split-Path -parent $startup
	if (!(Test-Path -Path $dir)) {
		Write-Verbose "create parent directory: '$dir'"
		New-Item -ItemType Directory -Path $dir | Out-Null
	}

	if (!($PSBoundParameters.ContainsKey('Name'))) {
		$Name = [System.IO.Path]::GetFileNameWithoutExtension($Source)
	}

	$linkPath = "${startup}\${Name}.lnk"
	if (Test-Path $linkPath) {
		Remove-Item $linkPath -Force
		Write-Verbose "deleted old link: '$linkPath'"
	}
	if (!($delete)) {
		$ws = New-Object -ComObject WScript.Shell
		$shortcut = $ws.CreateShortcut("$linkPath")
		#$shortcut.TargetPath = "$Source"	# deprecated direct source
		$shortcut.TargetPath = "pwsh.exe"
		$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Source`""
		$shortcut.WindowStyle = 7	# 7 = minimized, 3 = maximized, 1 = normal
		$shortcut.Save()
		Write-Verbose "created link: '$linkPath'"
	}
}

## SCRIPT ENTRY ########################################

# handle verbosity
if ($Verbose) {
	$VerbosePreference = "Continue"
}

# go to the script direcory (to nicely resolve local paths)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
cd $ScriptDir

## install programs
Write-Header "# installing programs"
if (skip) {
	install Microsoft.PowerShell,ajeetdsouza.zoxide,junegunn.fzf,Git.Git
	install Neovim.Neovim,Python.Python.3.14,BurntSushi.ripgrep.GNU
	install glzr-io.glazewm,AutoHotkey.AutoHotkey
	install JesseDuffield.lazygit,GnuPG.GnuPG,UniversalCtags.Ctags
	Write-Output ""
	Write-Output "You might need to restart this shell, if you just installed new programs."
}
Write-Output ""

## link configs/files
Write-Header "# linking configs/files"
if (skip) {
	$psDir = Split-Path -Parent $profile
	ask-link "$psDir\alias.ps1" ".\PowerShell\alias.ps1"
	# programs
	ask-link "$env:USERPROFILE\Documents\ahk\" ".\AutoHotkey\"
	ask-link "$env:USERPROFILE\Documents\PowerToys\" ".\other\PowerToys\"
	ask-link "$env:HOMEPATH\.gitconfig_custom" ".\configs-linux\other\.gitconfig_custom"
	ask-link "$env:HOMEPATH\.gitignore_global" ".\configs-linux\other\.gitignore_global"
	ask-link "$env:USERPROFILE\.glzr\glazewm" ".\glazewm\" 
	ask-link "$env:LOCALAPPDATA\lazygit" ".\configs-linux\lazygit\"
	ask-link "$env:LOCALAPPDATA\nvim" ".\configs-linux\nvim\"
}
Write-Output ""

## source files
Write-Header "# source files and stuff"
if(skip) {
	if(skip "source alias.ps1") { add-import "$profile" ".\PowerShell\\alias.ps1" }
	if(skip "load zoxide as jd") {
		add-import "$profile" "Invoke-Expression (& { (zoxide init --cmd jd powershell | Out-String) })" -clean
	}
	if(skip "source '.gitconfig_custom'") {
		$file = "$env:HOMEPATH\.gitconfig"
	$importLine = @"
[include]
	path = ~/.gitconfig_custom
"@
		$searchLine = "path = ~/.gitconfig_custom"
		$saveSearchLine = [regex]::Escape($searchLine)
		if (Get-Content $file | Select-String -Pattern $saveSearchLine) {
			Write-Verbose "Skipping: already sourced in '$file'"
		}
		else {
			Add-Content -Path $file -Value $importLine
			Write-Verbose "Added '$importLine' to $file"
		}
	}
}
Write-Output ""

## other
Write-Header "# other stuff"
if (skip "autostart AutoHotkey script") {
	add-startup ".\AutoHotkey\start-ahk-scripts.ps1"
}
if (skip -n "generate a new gpg key") {
	gpg --full-generate-key
	Write-Output "add it to git with 'git config --global user.signingkey <ID>'"
	Write-Output "(get the id with 'gpg --list-secret-keys')"
}
## set standart editor ($env:editor)?
## auto start?
# glazewm.exe start

Write-Output ""
Write-Header "execute '.\installAdmin.ps1' to setup admin things"
