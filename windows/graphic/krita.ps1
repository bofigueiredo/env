$active = $true
if (-not $active) {
	Write-Host "[Error] Installer <NOT-IMPLEMENTED> or <UNDER-MAINTENANCE>"`n -ForegroundColor Red
	break
} 

### Put the installer and setup after the line below
Write-Host "[krita] SETUP INITIATED" -ForegroundColor Magenta
winget install --exact --id BlenderFoundation.Blender --silent