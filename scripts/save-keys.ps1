# Saves each VM's Terraform-generated private key to ~/.ssh/<vm-name>.
# Run AFTER a deploy (reads the remote state — read-only, not an apply).
#
# Prereqs (same session):
#   $env:AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY  (OCI Customer Secret Keys)
#   $env:AWS_REQUEST_CHECKSUM_CALCULATION="when_required"
#   $env:AWS_RESPONSE_CHECKSUM_VALIDATION="when_required"
#
# Usage (from repo root):
#   .\scripts\save-keys.ps1            # defaults to dev
#   .\scripts\save-keys.ps1 -Env prod

param(
  [string]$Env = "dev"
)
$ErrorActionPreference = "Stop"

$sshDir = Join-Path $HOME ".ssh"
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null

Write-Host "Reading private keys from '$Env' state..." -ForegroundColor Cyan
$raw = terraform -chdir="envs/$Env" output -json instance_private_keys
if (-not $raw) {
  Write-Host "No keys found (no instances with generate_ssh_key?)." -ForegroundColor Yellow
  exit 0
}

$keys = $raw | ConvertFrom-Json
foreach ($vm in $keys.PSObject.Properties) {
  $path = Join-Path $sshDir $vm.Name
  # write with LF line endings so ssh accepts the key
  [System.IO.File]::WriteAllText($path, ($vm.Value -replace "`r`n", "`n"))

  # lock down permissions (Windows OpenSSH needs this)
  icacls $path /inheritance:r /grant:r "$($env:USERNAME):(R)" | Out-Null

  Write-Host ("Saved: {0}" -f $path) -ForegroundColor Green
}
Write-Host "Done. SSH e.g.:  ssh -i `$HOME\.ssh\dev-app-01 opc@<public-ip>" -ForegroundColor Cyan
