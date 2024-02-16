cd .\frontend\

gox ./

$env:GOOS = "js"
$env:GOARCH = "wasm"
go build -o ../public/app/app.wasm