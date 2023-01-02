$active = $true
if (-not $active) {
	Write-Host "[Error] Installer <NOT-IMPLEMENTED> or <UNDER-MAINTENANCE>"`n -ForegroundColor Red
	break
} 

### Put the installer and setup after the line below
Write-Host "[k-lite-codec-pack] SETUP INITIATED" -ForegroundColor Magenta

$URI_RES = "https://raw.githubusercontent.com/bofigueiredo/bofigueiredo/main/env/resources"

$URI_RES_INSTALLER    = $URI_RES + "/k-lite-codec-pack"
$UNATTENDED_FILE_NAME = "/klcp_standard_unattended.ini"
$OUTPUT_PATH          = $env:temp

$expression = "winget install --exact --id CodecGuide.K-LiteCodecPack.Standard "
try {
	$uri    = $URI_RES_INSTALLER + $UNATTENDED_FILE_NAME
	$output = Join-Path $OUTPUT_PATH $UNATTENDED_FILE_NAME
	Invoke-WebRequest -Uri $uri -OutFile $output 
	$expression += "--silent --override '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES /LOADINF=" + $output + "'"
} catch {
	Write-Host "[Error] Failure in download resource in $uri" -ForegroundColor Red
	Write-Host "[Info] Switching for manual installer" -ForegroundColor Yellow
	$expression += "--interactive"
}

Invoke-Expression $expression