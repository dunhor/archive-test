@echo off
setlocal
setlocal EnableDelayedExpansion

set BUILD_DIR=%~dp0\build

mkdir %BUILD_DIR% > NUL
pushd %BUILD_DIR%

cmake .. -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

popd
