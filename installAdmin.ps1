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

## SCRIPT ENTRY ########################################

# handle verbosity
if ($Verbose) {
	$VerbosePreference = "Continue"
}

# go to the script direcory (to nicely resolve local paths)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
cd $ScriptDir

ask-link "$env:windir\v.bat" ".\v.bat"

if (skip "setup ssh-agent") {
	if ((Get-Service ssh-agent).status -ne "Running") {
		Set-Service ssh-agent -StartupType Automatic
	}
	$sshCommand = (Get-Command ssh).source
	git config --global core.sshCommand "'$sshCommand'"
	Write-Output "add an sshkey with 'ssh-add \$env:USERPROFILE\.ssh'"
}
