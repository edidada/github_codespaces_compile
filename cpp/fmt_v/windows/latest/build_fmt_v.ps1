git clone --depth 1  https://github.com/fmtlib/fmt.git project
Set-Location project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel
