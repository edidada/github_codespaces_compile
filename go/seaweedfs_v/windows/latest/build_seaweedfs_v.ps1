git clone --depth 1 https://github.com/seaweedfs/seaweedfs.git project
Set-Location project
New-Item -ItemType Directory -Force build | Out-Null
go build -o build/weed ./weed
