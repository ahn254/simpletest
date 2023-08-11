param(
    [String] [Parameter (Mandatory)] $agentSpec,
    [String] $TestName
)

$validAgentSpec = [string]::IsNullOrEmpty($(@("macos", "ubuntu", "windows") | Where-Object { $_ -match $agentSpec.Split("-")[0] }))

if ($validAgentSpec) {
    throw "Unsupported Agent Spec was provided. `nSupported Agent Specs for standard runners: macos-11, macos-12, macos-13, ubuntu-20.04, ubuntu-22.04, windows-2019, windows-2022. `nSupported Agent Specs for custom large runners should start from `"macos`", `"ubuntu`", or `"windows`"."
}

$AllowedCanaryTests = Get-Content -Path ./_canary.json -Raw | ConvertFrom-Json -Depth 9 `
| Where-Object { ($_.labels -eq "all") -or ($_.labels -eq $agentSpec) -or `
    ($_.labels -eq $agentSpec.Split("-")[0]) }

$SelectedCanaryTests = @()
if ($TestName) {
    $TestName.Split(",") | ForEach-Object {
        $name = $_.Trim()
        if ( -Not ($AllowedCanaryTests | Select-Object -ExpandProperty name).contains($name)) {
            Throw "Test with name '$name' doesn't exist or is not active"
        }
        $SelectedCanaryTests += $name
    }
}

$matrixArray = @()

foreach ($test in $AllowedCanaryTests) {

    if ( $TestName -And -Not ($SelectedCanaryTests.contains($test.name))) {
        Continue
    }

    $testPath = './.github/actions/' + $test.templates
    $testName = $test.name
    if ([string]::IsNullOrEmpty($test.matrix)) {
        $matrixArray += @([pscustomobject]@{actions=$testPath;testName=$testName;parameter=$null})
    } else {
        foreach ($matrixItem in $test.matrix.$agentSpec) {
            $tempNmae = $testName + ($matrixItem.Split(":")[-1]).replace('"','')
            $formatedMatrixItem = """{0}"": ""{1}""" -f $($matrixItem.Split(":")[0].trim()), $($matrixItem.Split(":")[-1].trim())
            $matrixArray += @([pscustomobject]@{actions=$testPath;testName=$tempNmae;parameter=$formatedMatrixItem})
        }
    }
}
[pscustomobject]$matrix = @{
    include = $matrixArray
}

"matrix=$($matrix | ConvertTo-Json -Compress)" | Out-File -Append -FilePath $env:GITHUB_OUTPUT