#!/bin/bash

# Check if air is installed, if not install it
if ! command -v air &> /dev/null
then
	echo "air could not be found, installing..."
	curl -sSfL https://raw.githubusercontent.com/cosmtrek/air/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
	echo "air installed successfully."
fi

if ! command -v gox &> /dev/null; then
	echo "gox could not be found, installing..."
	go install github.com/8byt/gox@latest
	echo "gox installed successfully."
fi

# Function to kill both air processes when exiting
cleanup() {
	echo "Shutting down Air instances..."
	kill $PID_FRONTEND $PID_BACKEND
}

# Trap EXIT signal to gracefully handle script termination
trap cleanup EXIT

# Start the first Air instance for the frontend
$(go env GOPATH)/bin/air -c util/air-frontend-linux.toml &
PID_FRONTEND=$!
echo "Started Air frontend with PID: $PID_FRONTEND"

# Start the second Air instance for the backend
$(go env GOPATH)/bin/air -c util/air-backend-linux.toml &
PID_BACKEND=$!
echo "Started Air backend with PID: $PID_BACKEND"

# Wait for both processes to exit
wait $PID_FRONTEND $PID_BACKEND