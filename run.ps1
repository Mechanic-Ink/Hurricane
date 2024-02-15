$airInstalled = Get-Command air -ErrorAction SilentlyContinue
if ($null -eq $airInstalled) {
    Write-Host "air is not installed. Installing..."
    go install github.com/cosmtrek/air@latest
    $env:Path += ";$(go env GOPATH)\bin"
}

$frontendAirCommand = "air -c util/air-frontend-win.toml"
$frontendProcess = Start-Process -FilePath "powershell" -ArgumentList "-Command", $frontendAirCommand -PassThru -NoNewWindow
$frontendPID = $frontendProcess.Id
Write-Host "Frontend air running with PID: $frontendPID"

Register-ObjectEvent -InputObject $frontendProcess -EventName Exited -Action {
	Stop-Process -Id $backendPID -Force
	Write-Host "Frontend air process exited. Backend air process terminated."
}

$backendAirCommand = "air -c util/air-backend-win.toml"
$backendProcess = Start-Process -FilePath "powershell" -ArgumentList "-Command", $backendAirCommand -PassThru -NoNewWindow
$backendPID = $backendProcess.Id
Write-Host "Backend air running with PID: $backendPID"

Register-ObjectEvent -InputObject $backendProcess -EventName Exited -Action {
	Stop-Process -Id $frontendPID -Force
	Write-Host "Backend air process exited. Frontend air process terminated."
}

Wait-Event