$active = $true
if (-not $active) {
	Write-Host "[Error] Installer <NOT-IMPLEMENTED> or <UNDER-MAINTENANCE>"`n -ForegroundColor Red
	break
} 

### Put the installer and setup after the line below
Write-Host "[windows-settings] SETUP INITIATED" -ForegroundColor Magenta

$NA = "Write-Host 'Not Applied!' -ForegroundColor Yellow"

$commandList = @()
$commandList += ([pscustomobject]@{'Where' = "Windows Explorer: Expand to current folder?";
    'True'  = "REG ADD 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V NavPaneExpandToCurrentFolder /T REG_DWORD /D 00000001' /F";
    'False' = "REG ADD 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V NavPaneExpandToCurrentFolder /T REG_DWORD /D 00000000' /F";
})

$commandList += ([pscustomobject]@{'Where' = "Windows Explorer: Show file extension?";
    'True'  = "REG ADD 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0' /F";
    'False' = "REG ADD 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 1' /F";
})  

$commandList += ([pscustomobject]@{'Where' = "Windows Explorer: Use old context menu?";
    'True'  = "REG ADD 'HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' /F";
    'False' = "REG DELETE 'HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' /F";
})  

$commandList += ([pscustomobject]@{'Where' = "Energy: Turn off hibernation?";
    'True'  = "powercfg -h off";
    'False' = $NA;
}) 

$commandList += ([pscustomobject]@{'Where' = "Security: Set Set-ExecutionPolicy as RemoteSigned?";
    'True'  = "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser";
    'False' = $NA;
}) 

function Main {
            
    foreach($cmd in $commandList) {
        $confirm = Read-Host ($cmd.Where + "[y]/n")
        if ($confirm -ne "n") {
            Invoke-Expression $cmd.True
        } else {
            Invoke-Expression $cmd.False
        }
    }

    Restart-Explorer
}

function Restart-Explorer {
    taskkill /f /im explorer.exe
    Start-Process explorer.exe
}


Main