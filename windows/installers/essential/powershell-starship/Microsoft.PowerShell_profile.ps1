New-Alias g goto

function gp { Set-Location -Path "$HOME/projects" }


$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
$ENV:STARSHIP_DISTRO = "者 xcad"
Invoke-Expression (&starship init powershell)