param(
    [String] [Parameter (Mandatory)] $agentSpec
)

$AllowedCanaryTests =  Get-Content -Path ./_canary.json -Raw | ConvertFrom-Json -Depth 9
$matrixArray = @()
foreach ($test in $AllowedCanaryTests) {
    if (-not [string]::IsNullOrEmpty($($test | Where-Object {$_.supportedOSes -match $agentSpec}).name)) {
        if ($test.templates.Count -eq 1 ) {
            $testPath = './.github/actions/' + $test.templates
            $testNmae = $test.name
        } else {
            switch -Exact -Regex ($agentSpec)
            {
                "ubuntu" {$suffix = "-ubnt"}
                "win" {$suffix = "-win"}
                "mac" {$suffix = "-mac"}
            }
            $testPath = './.github/actions/' + $($test.templates | Where-Object {$_ -match $suffix})
            $testNmae = $test.name
        }

        if ([string]::IsNullOrEmpty($test.matrix)) {
            $matrixArray += @([pscustomobject]@{actions=$testPath;testNmae=$testNmae;parameter=$null})
        } else {
            foreach ($matrixItem in $test.matrix.$agentSpec) {
                $tempNmae = $testNmae + ($matrixItem.Split(":")[-1]).replace('"','')
                $matrixArray += @([pscustomobject]@{actions=$testPath;testNmae=$tempNmae;parameter=$matrixItem})
            }
        }
    }
}
[pscustomobject]$matrix = @{
include = $matrixArray
}

write-host $($matrix | ConvertTo-Json -Compress)

"matrix=$($matrix | ConvertTo-Json -Compress)" | Out-File -Append -FilePath $env:GITHUB_OUTPUT