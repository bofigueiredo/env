$GITHUB_USER       = "bofigueiredo"
$GITHUB_REPOSITORY = "env"

$ESC = [char]27
$FOREGROUND_COLOR_GRAY = "$ESC[30m"
$FOREGROUND_COLOR_PINK = "$ESC[35m"
$BACKGROUND_COLOR_BLUE = "$ESC[44m"
$BACKGROUND_COLOR_PINK = "$ESC[45m"
$COLOR_RESET = "$ESC[0m"

$BASE_DIR_URI          = "https://github.com/$GITHUB_USER/$GITHUB_REPOSITORY/tree/main/windows/"
$BASE_RAW_URI_TEMPLATE = "https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPOSITORY/main/windows/<PACKAGE>/<APP>"

function Main {

	$installerList = Import-InstallerList

	$installerList | ForEach-Object {[PSCustomObject]$_} | 
        Format-Table @{Label = 'rowid';   Expression = { Write-DataByStatus $_.active $_.rowid "X" }; Align='center'; Width = 8},
					 @{Label = 'package'; Expression = { Write-DataByStatus $_.active $_.package }; Width = 20},
					 @{Label = 'app';     Expression = { Write-DataByStatus $_.active $_.app  }; Width = 20},
					 @{Label = 'active';  Expression = { Write-DataByStatus $_.active "Y" "N" }; Align='center'; Width = 8}

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

function Write-DataByStatus {
	param (
		[Parameter(Mandatory)]
		[bool] $active,

		[Parameter(Mandatory)]
		[string] $data,

		[string] $dataSwitchIfInactive
	)

	$STATUS_ACTIVE_TEMPLATE   = "$FOREGROUND_COLOR_PINK<value>$COLOR_RESET" 
	$STATUS_INACTIVE_TEMPLATE = "$FOREGROUND_COLOR_GRAY<value>$COLOR_RESET" 

	if ($active) {
		$dataColored = $STATUS_ACTIVE_TEMPLATE.Replace("<value>", $data)	
	} else {
		if ($dataSwitchIfInactive) {
			$data = $dataSwitchIfInactive
		}
		$dataColored = $STATUS_INACTIVE_TEMPLATE.Replace("<value>", $data)	
	}
	return $dataColored
}

function Import-InstallerList {
	Write-Progress -Activity "Discovering Installers..." -Status "Please Wait!"

	$rowid = 0
	$installerList = @()
	$packageList = Import-PackageList
	foreach($package in $packageList) {

		$appList = Import-AppList $package
		foreach($app in $appList) {
			$rowid  += 1
			$appname = $app.split(".")[0]
			$uri     = $BASE_RAW_URI_TEMPLATE.replace("<PACKAGE>", $package).replace("<APP>", $app)
			$ProgressPreference = "SilentlyContinue"
			$script  = (Invoke-WebRequest -Uri $uri).Content
			$exist   = $null -ne $script
			$active  = $exist -and (Test-IsInstallerActive $script)

			$installerList += ([pscustomobject]@{
				'rowid'   = $rowid;
				'package' = $package;
				'app'     = $appname;
				'uri'     = $uri;
				'exist'   = $exist;
				'active'  = $active;				
				'script'  = $script;
			  })
		}
	}

	return $installerList	
}

function Import-PackageList {
	$ProgressPreference = "SilentlyContinue"
	return (Invoke-WebRequest $BASE_DIR_URI).links | Where-Object {$_.href -like "/*/tree/main/windows/*"} | Select-Object -ExpandProperty title
}

function Import-AppList {
	param (
		[Parameter(Mandatory)]
		[string] $package
	)
	$ProgressPreference = "SilentlyContinue"
	$packageURI = $BASE_DIR_URI + $package
	return (Invoke-WebRequest $packageURI).links | Where-Object {$_.href -like "*.ps1"} | Select-Object -ExpandProperty title
}

function Invoke-Installer($installer) {
	$PKG_TEMPLATE = "$BACKGROUND_COLOR_PINK <value> $COLOR_RESET" 
	$APP_TEMPLATE = "$BACKGROUND_COLOR_BLUE <value> $COLOR_RESET" 

	$confirm = Read-Host $PKG_TEMPLATE.Replace("<value>", $installer.package) : $APP_TEMPLATE.Replace("<value>", $installer.app) "Confirm install ? [y]/n"
	if ($confirm -ne "n") {
		Write-Host $installer.uri -ForegroundColor Blue
		Invoke-Expression $installer.script
		Write-Host
	}
}

function Test-IsInstallerActive($content) {
	$firstLine = ($content -split "\r?\n|\r")[0]
	return ($firstLine -like '*true*')
}

Main