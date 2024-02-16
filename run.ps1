$airInstalled = Get-Command air -ErrorAction SilentlyContinue
if ($null -eq $airInstalled) {
	Write-Host "air is not installed. Installing..."
	go install github.com/cosmtrek/air@latest
	$env:Path += ";$(go env GOPATH)\bin"
	Ensure-GoBinPathInPath
}

$goxInstalled = Get-Command gox -ErrorAction SilentlyContinue
if ($null -eq $goxInstalled) {
	Write-Host "gox is not installed. Installing..."
	go install github.com/8byt/gox@latest
	Ensure-GoBinPathInPath
}

function Ensure-GoBinPathInPath {
	$goBinPath = "$(go env GOPATH)\bin"
	$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Process)

	if ($currentPath -notcontains $goBinPath) {
		Write-Host "Adding Go bin path to PATH..."
		$newPath = $currentPath + ";" + $goBinPath
		[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Process)
		Write-Host "Go bin path added to PATH."
	} else {
		Write-Host "Go bin path is already in PATH."
	}
}

# Delete .go files in frontend/common and frontend/components recursively
$pathsToDeleteFrom = @("frontend/common", "frontend/components")
foreach ($path in $pathsToDeleteFrom) {
	Get-ChildItem -Path $path -Recurse -Filter *.go | Remove-Item -Force
	Write-Host "Deleted .go files from $path"
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