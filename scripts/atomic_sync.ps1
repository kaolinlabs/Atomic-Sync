param (
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter(Mandatory=$true)]
    [ValidateSet("COMMIT", "ACQUIRE", "RELEASE")]
    [string]$Action,
    [string]$Data
)

$lockFile = "$Path.lock"
# Uses the current script directory to find the python auditor
$auditScript = Join-Path $PSScriptRoot "audit_logic.py"

switch ($Action) {
    "ACQUIRE" {
        $timeout = 10
        $elapsed = 0
        while (Test-Path $lockFile) {
            if ($elapsed -ge $timeout) {
                Write-Error "LOCK TIMEOUT: Could not acquire lock for $Path"
                exit 1
            }
            Start-Sleep -Milliseconds 200
            $elapsed += 0.2
        }
        New-Item -Path $lockFile -ItemType File -Force | Out-Null
        Write-Host "LOCK ACQUIRED: $Path"
    }

    "RELEASE" {
        if (Test-Path $lockFile) {
            Remove-Item $lockFile -Force
            Write-Host "LOCK RELEASED: $Path"
        }
    }

    "COMMIT" {
        while (Test-Path $lockFile) { Start-Sleep -Milliseconds 200 }
        New-Item -Path $lockFile -ItemType File -Force | Out-Null

        try {
            $env:OC_SYNC_DATA = $Data
            python $auditScript $Path "COMMIT"

            if ($LASTEXITCODE -ne 0) {
                Write-Error "GOVERNANCE REJECTED: State update violates business rules."
                exit 1
            }

            $Data | Out-File -FilePath $Path -Encoding utf8 -Force
            Write-Host "AUTHORIZED: State updated successfully."
        }
        finally {
            Remove-Item $lockFile -Force
            $env:OC_SYNC_DATA = $null
        }
    }
}
