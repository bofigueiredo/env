$NEW_INSTALLER_LIST     = Join-Path $PSScriptRoot "\new-installer.conf"
$DEFAULT_INSTALLER      = Join-Path $PSScriptRoot "\new-installer.default"
$INSTALLER_URI_TEMPLATE = Join-Path $PSScriptRoot "\installers\<package>\<app>.ps1"

function Main {
	$installerList = Import-InstallerList

	$installerList | ForEach-Object {[PSCustomObject]$_} | 
        Format-Table 

	Write-Host "Leave blank to install all"
	$selected = ($installerList | Where-Object { $_.active })

	$response = Read-Host "Enter [pkg-name] or [rowid]"
	if ($response -ne "") {
		$selected = ($selected | Where-Object { ($_.rowid -eq $response) -or ($_.package -eq $response)})
	} 

	foreach($installer in $selected) {
		Invoke-Installer $installer
	}	
	Resolve-Installers $installerList
}

function Import-InstallerList {
	$rowid = 0
	$installerList = @()
	Write-Host $NEW_INSTALLER_LIST
	foreach($newInstaller in Get-Content $NEW_INSTALLER_LIST) {
		$package = $newInstaller.split(":")[0]
		$app     = $newInstaller.split(":")[1]

		$rowid += 1
		$uri    = $INSTALLER_URI_TEMPLATE.replace("<package>", $package).replace("<app>", $app)
		$exist  = Test-ExistURI $uri
		$active = $exist -and (Test-IsInstallerActive $uri)

		$installerList += ([pscustomobject]@{
			'rowid'   = $rowid;
			'package' = $package;
			'app'     = $app;
			'uri'     = $uri;
			'exist'   = $exist;
			'active'  = $active;
		})
	}

	return $installerList
}

function Initialize-Installer {
	param (
		[Parameter(Mandatory)]
		[string] $uri,
		[Parameter(Mandatory)]
		[string] $app
	)

	New-Item $uri | Out-Null
	Set-Content $uri (Get-Content $DEFAULT_INSTALLER).Replace("<app>", $app)
	Write-Host "[CREATED] $app" -ForegroundColor Yellow
}

function Resolve-Installers {
	param (
		[Parameter(Mandatory)]
		[pscustomobject[]] $installerList
	)

	Write-Host `n`t"[$($installerList.Count)] installer item"

	foreach ($installer in $installerList) {
		if (-not $installer.exist) {
			$response = Read-Host "$($installer.app) notfound, create y/[n]"
			if ($response -eq "y") {
				Initialize-Installer $installer.uri $installer.app
			}
		}
		if ($installer.active) {
			Write-Host "[OK]" $installer.app  -ForegroundColor Blue
		} else {
			Write-Host "[ERROR]" $installer.app "- NOT IMPLEMENTED" -ForegroundColor Red
		}
	}    
	
	
}

function Test-ExistURI{
	param (
		[Parameter(Mandatory)]
		[string] $uri
	)

	return Test-Path -Path $uri -PathType Leaf
}

function Test-IsInstallerActive {
	param (
		[Parameter(Mandatory)]
		[string] $uri
	)

	$installerFirstLine = Get-Content $uri -First 1
	return ($installerFirstLine -like '*true*')
}

Main