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
        $confirm = $(Write-Host $cmd.Where "[y]/n" -ForegroundColor Blue -NoNewLine; Read-Host)
        if ($confirm -ne "n") {
            Invoke-Expression $cmd.True
        } else {
            Invoke-Expression $cmd.False
        }
    }
    Set-HightPerformancePowerConfig
    Install-NerdFonts
    Restart-Explorer
}

function Install-NerdFonts {
    $confirm = Read-Host ("Install Nerd Fonts [y]/n")
    if ($confirm -ne "n") {
        $HASKLUG_NERD_FONT_FULLPATH = Join-Path $env:temp "\windows-settings\fonts\"

        # Create a Shell Application Object
        # https://learn.microsoft.com/pt-br/windows/win32/shell/shell
        $shellAppObj = New-Object -ComObject Shell.Application

        # https://learn.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants
        $ssfFONTS = 0x14 
        
        # Returns a Folder Object
        # https://learn.microsoft.com/en-us/windows/win32/shell/folder
        $fontsFolder = $shellAppObj.Namespace($ssfFONTS)

        # Install font
        Get-ChildItem -Path $HASKLUG_NERD_FONT_FULLPATH | ForEach-Object {$fontsFolder.CopyHere($_.FullName)}
    }
}

function Set-HightPerformancePowerConfig {
    # https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options
    
    $HIGHT_PERFORMANCE_PLAN = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    
    powercfg /list
    $confirm = Read-Host ("Set hight performance energy plan? [y]/n")
    if ($confirm -ne "n") {
        powercfg /setactive $HIGHT_PERFORMANCE_PLAN
        powercfg /change standby-timeout-dc 10
        Write-Host "       Standby: never      [AC]" -ForegroundColor Yellow
        Write-Host "                10 minutes [DC]" -ForegroundColor Yellow
        powercfg /change monitor-timeout-ac 60
        powercfg /change monitor-timeout-dc 8
        Write-Host "   Monitor Off:  1 hour    [AC]" -ForegroundColor Yellow
        Write-Host "                 8 minutes [DC]" -ForegroundColor Yellow
        powercfg /change disk-timeout-ac 0
        Write-Host "        HD Off: never      [AC]" -ForegroundColor Yellow
        Write-Host "                20 minutes [DC]" -ForegroundColor Yellow
    }
}



function Restart-Explorer {
    taskkill /f /im explorer.exe
    Start-Process explorer.exe
}


Main