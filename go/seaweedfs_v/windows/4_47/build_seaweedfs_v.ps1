git clone --depth 1 --branch 4.47 https://github.com/seaweedfs/seaweedfs.git project
Set-Location project
New-Item -ItemType Directory -Force build | Out-Null
go build -o build/weed ./weed
