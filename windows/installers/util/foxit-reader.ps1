$active = $true
if (-not $active) {
	Write-Host "[Error] Installer <NOT-IMPLEMENTED> or <UNDER-MAINTENANCE>"`n -ForegroundColor Red
	break
} 

### Put the installer and setup after the line below
Write-Host "[foxit-reader] SETUP INITIATED" -ForegroundColor Magenta

# Reference https://kb.foxit.com/hc/en-us/articles/360042663971
# pdfviewer - Foxit PDF Viewer and its components
# ffSpellCheck - Spell check tool 
# ffse - Plugins for Windows Explorer allow thumbnails
winget install --exact --id Foxit.FoxitReader --silent --override '/COMPONENTS="pdfviewer,ffSpellCheck,ffse" /TASKS="setDefaultReader" /clean /verysilent'