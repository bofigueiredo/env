$NEW_INSTALLER_LIST         = Join-Path $PSScriptRoot "\new-installer.conf"
$APP_LIST_URI_TEMPLATE      = Join-Path $PSScriptRoot "\<package>\.conf"
$INSTALLER_URI_TEMPLATE     = Join-Path $PSScriptRoot "\<package>\<app>.ps1"
$DEFAULT_INSTALLER_TEMPLATE = Join-Path $PSScriptRoot "\default.installer"

function Main {
	$installerList = Import-InstallerList
	Resolve-Installers $installerList
}

function Import-InstallerList {
	$rowid = 0
	$installerList = @()
	foreach($package in Get-Content $NEW_INSTALLER_LIST) {
		$appListUri = $APP_LIST_URI_TEMPLATE.Replace("<package>", $package)
		foreach($app in Get-Content $appListUri) {
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
	Set-Content $uri (Get-Content $DEFAULT_INSTALLER_TEMPLATE).Replace("<app>", $app)
	Write-Host "[CREATED] $app" -ForegroundColor Yellow
}

function Resolve-Installers {
	param (
		[Parameter(Mandatory)]
		[pscustomobject[]] $installerList
	)

	foreach ($installer in $installerList) {
		if (-not $installer.exist) {
			$response = Read-Host "${$installer.app} notfound, create y/[n]"
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
	
	Write-Host `n`t"[$($installerList.Count)] installer item"
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