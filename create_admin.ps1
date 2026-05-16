# PowerShell wrapper to create admin using local XAMPP PHP
# Usage: .\create_admin.ps1 -Username admin -Password admin123 -Email admin@example.com
param(
    [Parameter(Mandatory=$true)][string]$Username,
    [Parameter(Mandatory=$true)][string]$Password,
    [string]$Email = "admin@example.com"
)

$php = "C:\xampp\php\php.exe"
if (-not (Test-Path $php)) {
    Write-Error "PHP CLI not found at $php; adjust create_admin.ps1 to point to your php.exe"
    exit 2
}

$script = Join-Path -Path (Get-Location) -ChildPath "admin\create_admin.php"
& $php $script --username=$Username --password=$Password --email=$Email
