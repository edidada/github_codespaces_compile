git clone --depth 1 --branch 12.2.0 https://github.com/fmtlib/fmt.git project
Set-Location project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel
