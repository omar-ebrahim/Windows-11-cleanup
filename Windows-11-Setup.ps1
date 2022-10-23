
Write-Warning "*** This script carries absolutely no warranty whatsoever ***
*** I carry no responsibility for the outcome, good or bad from running this script ***
*** Only run this script if you are confident you know what you're doing. ***"


# Brings back the old right-click menu

$BASE_PATH = "HKCU:\HKEY_CURRENT_USER\Software\Classes\CLSID"
$REG_KEY = "{86CA1AA0-34AA-4E8B-A509-50C905BAE2A2}"

$OldContextMenu = -1

while (($OldContextMenu -ne 0) -and ($OldContextMenu -ne 1) -and ($OldContextMenu -ne 2))
{
    $OldContextMenu = Read-Host "Would you like the new or old right-click menu? [0] = new, [1] = old, [2] = skip"
}

if($OldContextMenu -eq 1)
{
    Write-Host "Adding setting..."
    if (!(Test-Path "$BASE_PATH\$REG_KEY") -and !(Test-Path "$BASE_PATH\$REG_KEY\InprocServer32")) # We have neither
    {
        New-Item "$BASE_PATH\$REG_KEY" -Force | Out-Null # Create parent
        New-Item "$BASE_PATH\$REG_KEY\InprocServer32" -Force | Out-Null # Create child
    }
    elseif ((Test-Path "$BASE_PATH\$REG_KEY") -and !(Test-Path "$BASE_PATH\$REG_KEY\InprocServer32")) # Parent key exists ONLY
    {
        New-Item "$BASE_PATH\$REG_KEY\InprocServer32" -Force | Out-Null # Create the child key and set the value
    }
    Set-ItemProperty "$BASE_PATH\$REG_KEY\InprocServer32" -Name "(Default)" -Value '' | Out-Null # Set the value, regardless of what it was
    Write-Host "Restarting Windows Explorer..."
    Stop-Process -Name explorer -Force
    Write-Host "Done!"

}
elseif ($OldContextMenu -eq 0)
{
    if (Test-Path "$BASE_PATH\$REG_KEY")
    {
        Remove-Item "$BASE_PATH\$REG_KEY" -Force -Recurse | Out-Null
        Write-Host "Restarting Windows Explorer..."
        Stop-Process -Name explorer -Force
        Write-Host "Done!"
    }
}
else
{
    Write-Host "Skipping the setup of the right-click menu."
}

$StopTelemetry = -1

while (($StopTelemetry -ne 0) -and ($StopTelemetry -ne 1) -and ($StopTelemetry -ne 2))
{
    $StopTelemetry = Read-Host "Would you like to stop telemetry? [0] = no, [1] = yes, [2] = skip"
}

if ($StopTelemetry -eq 1)
{
    Write-Host "Stopping telemetry..."
    Get-Service -Name DiagTrack | Stop-Service -Force
    Set-Service -Name DiagTrack -StartupType Disabled -Status Stopped
    Write-Host "Done! Stopped telemetry."
}
elseif ($StopTelemetry -eq 0)
{
    Write-Host "Starting telemetry service as per out-of-box..."
    Get-Service -Name DiagTrack | Start-Service
    Set-Service -Name DiagTrack -StartupType Automatic -Status Running
    Write-Host "Done! Started telemetry."
}
else
{
    Write-Host "Skipping setup of telemetry."
}

Write-Host "Done!"