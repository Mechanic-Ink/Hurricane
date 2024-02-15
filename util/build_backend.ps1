$Env:GOARCH = "amd64"
$Env:GOOS = "windows"

# Define the server executable path
$serverExePath = "../tmp/server.exe"

# Check if server.exe is already running and stop it
Get-Process | Where-Object { $_.Path -eq $serverExePath } | Stop-Process -Force

# Navigate to the backend directory
Set-Location -Path "./backend"

# Build the backend
go build -o $serverExePath