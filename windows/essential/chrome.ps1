$active = $true
if (-not $active) {
	Write-Host "[Error] Installer <NOT-IMPLEMENTED> or <UNDER-MAINTENANCE>"`n -ForegroundColor Red
	break
} 

### Put the installer and setup after the line below
Write-Host "[chrome] SETUP INITIATED" -ForegroundColor Magenta
winget install --exact --id Google.Chrome --silent

$chromePath = Join-Path $env:ProgramFiles "\Google\Chrome\Application\chrome.exe"

Write-Host " - Sincronize your account" -ForegroundColor Blue
Write-Host "   <Press any key to open chrome>"
[Console]::ReadKey() | Out-Null	
Start-Process $chromePath

$siteList = @()
$siteList += "https://drive.google.com/"
$siteList += "https://mail.google.com/"
$siteList += "https://docs.google.com/document/"
$siteList += "https://docs.google.com/spreadsheets/"
$siteList += "https://www.youtube.com/"
$siteList += "https://translate.google.com.br/"
$siteList += "https://www.deepl.com/translator"
$siteList += "https://www.linguee.com/ingles-portugues/"
$siteList += "https://conjugator.reverso.net/conjugation-english-verb-be.html"
$siteList += "https://www.thesaurus.com/browse/synonym"
$siteList += "https://www.notion.so/bofigueiredo/"
$siteList += "https://feedly.com/i/my"
$siteList += "https://github.com/bofigueiredo"
$siteList += "https://codepen.io/your-work"

Write-Host " - Create shortcuts for sites [...] -> More tools -> Create shortcut" -ForegroundColor Blue
Write-Host "   <Press any key to open all site list>"
[Console]::ReadKey() | Out-Null	
foreach($site in $siteList) {
	Start-Process $chromePath $site
}