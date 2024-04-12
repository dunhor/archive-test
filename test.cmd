@echo off
setlocal
setlocal EnableDelayedExpansion

set TEST_DIR=%~dp0\test
set MAKE_FILES=..\build\src\make-files\make-files.exe

mkdir %TEST_DIR% > NUL 2>&1
pushd %TEST_DIR%

set count0=1
set count1=4194305
set count2=8388609
set count3=12582913
set count4=16777217

for /L %%i in (1, 1, 4194304) do (
    echo Iteration %%i

    :: 5 of each size, for a total of 25 files
    %MAKE_FILES% !count0! !count0! !count0! !count0! !count0! !count1! !count1! !count1! !count1! !count1! !count2! !count2! !count2! !count2! !count2! !count3! !count3! !count3! !count3! !count3! !count4! !count4! !count4! !count4! !count4!
    if !ERRORLEVEL! NEQ 0 (
        echo ERROR: Failed to make test files
        goto :failure
    )

    :: Pack all into a single RAR file
    rar.exe a -ma4 test.rar file1 file2 file3 file4 file5 file6 file7 file8 file9 file10 file11 file12 file13 file14 file15 file16 file17 file18 file19 file20 file21 file22 file23 file24 file25 > NUL
    if !ERRORLEVEL! NEQ 0 (
        echo ERROR: Failed to make test.rar
        goto :failure
    )

    :: Unpack using bsdtar
    mkdir output > NUL 2>&1
    tar -xf test.rar -C output
    if !ERRORLEVEL! NEQ 0 (
        echo ERROR: Failed to extract test.rar
        goto :failure
    )

    :: Verify the contents
    for /L %%j in (1, 1, 25) do (
        fc /b file%%j output\file%%j > NUL
        if !ERRORLEVEL! NEQ 0 (
            echo ERROR: Contents of file%%j incorrect
            goto :failure
        )
    )

    rmdir /s /q . > NUL 2>&1
    set /a count0=!count0! + 1
    set /a count1=!count1! + 1
    set /a count2=!count2! + 1
    set /a count3=!count3! + 1
    set /a count4=!count4! + 1
)

goto :done

:failure
    echo ERROR: Execution of the tests has failed. Any generated files have been left on disk for you to investigate

:done
    popd
