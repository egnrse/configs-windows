# parts of the install script that need admin rights
# (by egnrse)
param(
	[switch]$Verbose
)


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
			$backup = "$Path.bak_$(Get-Date -Format yyyyMMdd_HHmmss)"
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
# ask link, but harden the permissions on the source files
function ask-link-root {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory)]
			[string]$Path,
			[Parameter(Mandatory)]
			[string]$Source,
			[string]$text
		 )
	if ($PSBoundParameters.ContainsKey('text')) {
		ask-link $Path $Source $text
	} else {ask-link $Path $Source}

	if ($Verbose) {
		icacls .\other\sshd_config /inheritance:r /grant:r "SYSTEM:(F)" "*S-1-5-32-544:(F)" "*S-1-5-32-545:(R)"
		# Administrators(F) / Users(R) (lang independant)
	}
	else {
		icacls .\other\sshd_config /inheritance:r /Q /C *> $null
		icacls .\other\sshd_config /grant:r "SYSTEM:(F)" "*S-1-5-32-544:(F)" "*S-1-5-32-545:(R)" /Q /C *> $null
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

ask-link-root "$env:windir\v.bat" ".\PowerShell\\v.bat"

if (skip "setup ssh-agent") {
	if ((Get-Service ssh-agent).status -ne "Running") {
		Set-Service ssh-agent -StartupType Automatic
	}
	$sshCommand = (Get-Command ssh).source
	git config --global core.sshCommand "'$sshCommand'"
	Write-Output "add an sshkey with 'ssh-add $env:USERPROFILE\.ssh\'"
}
if (skip "setup sshd") {
	# install and activate sshd
	$cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
	if ($cap.State -ne 'Installed') {
		Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
	}
	Start-Service sshd
	if (-not $?) {Write-Output 'See a more detailed error with: & "$env:WINDIR\System32\OpenSSH\sshd.exe" -t'}
	Set-Service -Name sshd -StartupType 'Automatic'

	# setup/check firewall rule
	if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
		Write-Verbose "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
			New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
	} else {
		Write-Verbose "Firewall rule 'OpenSSH-Server-In-TCP' exists."
	}
	ask-link-root "$env:PROGRAMDATA\ssh\sshd_config" ".\other\sshd_config"
	Restart-Service sshd
	if (-not $?) {Write-Output 'See a more detailed error with: & "$env:WINDIR\System32\OpenSSH\sshd.exe" -t'}
	Write-Output "Add your sshkeys to '~\.ssh\authorized_keys'"
}
if (skip "setup python for nvim") {
	python -m pip install --upgrade pip
	python -m pip install pynvim
}
if (skip "launch debloater (ChrisTitusTech/winutil)") {
	iwr -useb https://christitus.com/win | iex
}
