param (
    [Parameter(Mandatory)]
    [string] $folder,

    [Parameter(Mandatory)]
    [string] $filename
)

$BASE_URI    = "https://raw.githubusercontent.com/bofigueiredo/env/main/resources/"
$OUTPUT_PATH = $env:temp

$resourceFolderURI = $BASE_URI + $folder
$resourceFileURI   = $resourceFolderURI + "/" + $filename
$outputFile        = Join-Path $OUTPUT_PATH $filename

try {
    Invoke-WebRequest -Uri $resourceFileURI -OutFile $outputFile 
} catch {
    Write-Host "[Error] Failure in download resource in $resourceFileURI" -ForegroundColor Red
}