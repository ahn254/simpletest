param(
    [String] [Parameter (Mandatory)] $agentSpec
)

$AllowedCanaryTests =  Get-Content -Path ./_canary.json -Raw | ConvertFrom-Json -Depth 9 `
                | Where-Object { ($_.labels -eq "all") -or ($_.labels -eq $agentSpec) -or `
                ($_.labels -eq $agentSpec.Split("-")[0]) }
$matrixArray = @()

foreach ($test in $AllowedCanaryTests) {

    $testPath = './.github/actions/' + $test.templates
    $testNmae = $test.name
    if ([string]::IsNullOrEmpty($test.matrix)) {
        $matrixArray += @([pscustomobject]@{actions=$testPath;testNmae=$testNmae;parameter=$null})
    } else {
        foreach ($matrixItem in $test.matrix.$agentSpec) {
            $tempNmae = $testNmae + ($matrixItem.Split(":")[-1]).replace('"','')
            $matrixArray += @([pscustomobject]@{actions=$testPath;testNmae=$tempNmae;parameter=$matrixItem})
        }
    }
}
[pscustomobject]$matrix = @{
    include = $matrixArray
}

"matrix=$($matrix | ConvertTo-Json -Compress)" | Out-File -Append -FilePath $env:GITHUB_OUTPUT
