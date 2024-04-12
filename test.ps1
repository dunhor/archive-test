
$TEST_DIR = "$PSScriptRoot\test"
$MAKE_FILES = "$PSScriptRoot\build\src\make-files\make-files.exe"

mkdir $TEST_DIR 2>&1 | Out-Null
pushd $TEST_DIR

try
{
    $count0=1
    $count1=4194305
    $count2=8388609
    $count3=12582913
    $count4=16777217
    for ($i = 0; $i -lt 4194304; ++$i)
    {
        Write-Output "Iteration $i"

        # Generate 5 files of each size, for a total of 25 files
        Invoke-Expression "$MAKE_FILES $count0 $count0 $count0 $count0 $count0 $count1 $count1 $count1 $count1 $count1 $count2 $count2 $count2 $count2 $count2 $count3 $count3 $count3 $count3 $count3 $count4 $count4 $count4 $count4 $count4"
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to make test files"
        }

        # Pack all files into a single RAR file
        rar.exe a -ma4 test.rar file1 file2 file3 file4 file5 file6 file7 file8 file9 file10 file11 file12 file13 file14 file15 file16 file17 file18 file19 file20 file21 file22 file23 file24 file25 | Out-Null
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to create test.rar"
        }

        # Unpack using bsdtar
        mkdir output 2>&1 | Out-Null
        tar -xf test.rar -C output
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to extract test.rar"
        }

        # Verify the contents
        for ($j = 1; $j -le 25; ++$j)
        {
            $HashExpect = (Get-FileHash -Algorithm MD5 "file$j").Hash
            $HashExtract = (Get-FileHash -Algorithm MD5 "output\file$j").Hash
            if ($HashExpect -ne $HashExtract)
            {
                throw "Contents of file$j incorrect; Expected hash $HashExpect, but got $HashExtract"
            }
        }

        Remove-Item * -Recurse -Force
    }
}
catch
{
    Write-Error $_
    Write-Error "Test execution has failed. Any generated files have been left on disk for you to investigate"
    throw $_
}
finally
{
    popd
}
