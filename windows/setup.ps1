$URI_BASE = "https://raw.githubusercontent.com/bofigueiredo/env/main/windows"

$PACKAGE_LIST_URI          = $URI_BASE + "/package.conf"
$APP_LIST_URI_TEMPLATE     = $URI_BASE + "/<package>/.conf"
$INSTALLER_URI_TEMPLATE    = $URI_BASE + "/<package>/<app>.ps1"

$ESC = [char]27
$RESET = "$ESC[0m"

$GRAY_FG = "$ESC[30m"
$PINK_FG = "$ESC[35m"
$BLUE_BG = "$ESC[44m"
$PINK_BG = "$ESC[45m"


$ACTIVE_DATA_TEMPLATE   = "$PINK_FG<value>$RESET" 
$INACTIVE_DATA_TEMPLATE = "$GRAY_FG<value>$RESET" 

$PKG_TEMPLATE = "$PINK_BG <value> $RESET" 
$APP_TEMPLATE = "$BLUE_BG <value> $RESET" 

function Main {

	$installerList = Import-InstallerList

	$installerList | ForEach-Object {[PSCustomObject]$_} | 
        Format-Table @{Label = 'rowid';   Expression = { Format-DataByStatus $_.active $_.rowid "X" }; align='center'},
					 @{Label = 'package'; Expression = { Format-DataByStatus $_.active $_.package }},
					 @{Label = 'app';     Expression = { Format-DataByStatus $_.active $_.app  }; align='center'},
					 @{Label = 'active';  Expression = { Format-DataByStatus $_.active "Y" "N" }; align='center'} # -GroupBy active

	Write-Host "Leave blank to install all"
	$selected = ($installerList | Where-Object { $_.active })

	$response = Read-Host "Enter [pkg-name] or [rowid]"
	if ($response -ne "") {
		$selected = ($selected | Where-Object { ($_.rowid -eq $response) -or ($_.package -eq $response)})
	} 

	foreach($installer in $selected) {
		Invoke-Installer $installer
	}
}

function Format-DataByStatus {
	param (
		[Parameter(Mandatory)]
		[bool] $active,

		[Parameter(Mandatory)]
		[string] $data,

		[string] $dataSwitchInactive
	)

	if ($active) {
		$dataColored = $ACTIVE_DATA_TEMPLATE.Replace("<value>", $data)	
	} else {
		if ($dataSwitchInactive) {
			$data = $dataSwitchInactive
		}
		$dataColored = $INACTIVE_DATA_TEMPLATE.Replace("<value>", $data)	
	}
	return $dataColored
}

function Get-Lines {
	param (
		[Parameter(Mandatory)]
		[string] $string
	)

	return ($string -split "\r?\n|\r")
}

function Get-URIContent {
	param (
		[Parameter(Mandatory)]
		[string] $uri
	)

	try {
		return (Invoke-WebRequest -Uri $uri).Content
	} catch {
		Write-Host "ERROR: Can't Get-URIContent $uri" -ForegroundColor Red
	}
}

function Import-InstallerList {

	$rowid = 0
	$installerList = @()
	$packageList = Get-URIContent $PACKAGE_LIST_URI

	foreach($package in Get-Lines $packageList) {
		$appListURI = $APP_LIST_URI_TEMPLATE.Replace("<package>", $package)
		$appList = Get-URIContent $appListURI

		foreach($app in Get-Lines $appList) {
			$rowid += 1
			$uri    = $INSTALLER_URI_TEMPLATE.replace("<package>", $package).replace("<app>", $app)
			$script = Get-URIContent $uri
			$exist  = $null -ne $script
			$active = $exist -and (Test-IsInstallerActive $script)

			Write-Host $app $exist $active

			$installerList += ([pscustomobject]@{
				'rowid'   = $rowid;
				'package' = $package;
				'app'     = $app;
				'uri'     = $uri;
				'exist'   = $exist;
				'active'  = $active;				
				'script'  = $script;
			  })
		}
	}

	return $installerList	
}

function Invoke-Installer($installer) {
	$confirm = Read-Host $PKG_TEMPLATE.Replace("<value>", $installer.package) : $APP_TEMPLATE.Replace("<value>", $installer.app) "Confirm install ? [y]/n"
	if ($confirm -ne "n") {
		Write-Host $installer.uri -ForegroundColor Blue
		Invoke-Expression $installer.script
		Write-Host
	}
}

function Test-IsInstallerActive($content) {
	$firstLine = (Get-Lines $content)[0]
	return ($firstLine -like '*true*')
}

Main