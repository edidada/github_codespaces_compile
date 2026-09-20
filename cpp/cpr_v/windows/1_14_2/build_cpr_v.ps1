git clone --depth 1 --branch 1.14.2 https://github.com/libcpr/cpr.git project
Set-Location project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel
