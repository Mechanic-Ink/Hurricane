#!/bin/bash

# Set environment variables
export GOARCH="amd64"
export GOOS="linux"

# Define the server executable path
serverExePath="../tmp/server"

# Check if server is already running and stop it
pid=$(pgrep -f "$serverExePath")
if [ ! -z "$pid" ]; then
	kill -9 $pid
fi

# Navigate to the backend directory
cd ./backend

# Build the backend
go build -o $serverExePath
