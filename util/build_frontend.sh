#!/bin/bash

# Navigate to the frontend directory
cd ./frontend

# Assuming gox is a custom script/tool, replace this with the correct command
# If gox is not executable or found, you might need to adjust this line
./gox ./

# Set environment variables for WASM build
export GOOS="js"
export GOARCH="wasm"

# Build the WASM file
go build -o ../public/app/app.wasm
