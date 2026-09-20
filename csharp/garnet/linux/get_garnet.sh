#! /bin/bash
cd "$(dirname "$0")"
git clone -b v1.0.3 https://github.com/microsoft/garnet.git
cd garnet
dotnet restore
dotnet format
dotnet build
dotnet test
