
$TEST_DIR = "$PSScriptRoot\test"
$MAKE_FILES = "$PSScriptRoot\build\src\make-files\make-files.exe"

mkdir $TEST_DIR 2>&1 | Out-Null
pushd $TEST_DIR

try
{
    $size0=0x00000001
    $size1=0x00400000
    $size2=0x00800000
    $size3=0x01000000
    $size4=0x02000000
    $size5=0x04000000
    $size6=0x08000000
    for ($i = 0; $i -lt 4194304; ++$i)
    {
        Write-Output "Iteration $i"

        # Generate a file of each size, for a total of 5 files
        Invoke-Expression "$MAKE_FILES $size0 $size1 $size2 $size3 $size4 $size5 $size6"
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to make test files"
        }

        # Pack all files into a single RAR file
        rar.exe a -ma4 -m5 test.rar file1 file2 file3 file4 file5 file6 file7 2>&1 | Out-Null
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
        for ($j = 1; $j -le 7; ++$j)
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
