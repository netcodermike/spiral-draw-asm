param(
    [string] $Nasm = 'nasm'
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'src/spiral.asm'
$outputDirectory = Join-Path $PSScriptRoot 'dist'
$executable = Join-Path $outputDirectory 'SPIRAL.COM'

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
& $Nasm -f bin $source -o $executable
if ($LASTEXITCODE -ne 0) {
    throw "NASM exited with code $LASTEXITCODE."
}

Get-Item -LiteralPath $executable
