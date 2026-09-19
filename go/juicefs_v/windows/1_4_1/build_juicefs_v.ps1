git clone --depth 1 --branch v1.4.1 https://github.com/juicedata/juicefs.git project
Set-Location project
go build ./cmd/juicefs
