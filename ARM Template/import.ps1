#$myModuleRoot = $env:PSModulePath -split ';' -like "*$env:userprofile*" | Select-Object -First 1
$myModuleRoot = "c:\whatif" #

Import-Module "$myModuleRoot\Az.Accounts"
Import-Module "$myModuleRoot\Az.Resources"

#Push-Location $myModuleRoot

$ModuleVersion = 0.1
$moduleName = "AZ.Resources.WhatIf"
$requiredModules = @('AZ.Accounts','AZ.Resources')
$moduleRoot = Join-Path $myModuleRoot $moduleName
if (-not (Test-Path $moduleRoot)) {
    $createdFile = New-Item -ItemType Directory -Path $moduleRoot
    if (-not $createdFile) { return } 
}


@"
@{
    ModuleVersion = "$ModuleVersion"
    RootModule = "$moduleName.psm1"
    RequiredModules = $(if ($requiredModules) {@("'$($requiredModules -join "','")'") })
}
"@ |
    Set-Content -Path (Join-Path $moduleRoot "$ModuleName.psd1") -Encoding UTF8


'foreach ($scriptFile in Get-ChildItem $psScriptRoot -Filter *-*.ps1) {
    . $scriptFile.Fullname
}' | Set-Content -Path (Join-Path $moduleRoot "$moduleName.psm1") -Encoding UTF8

$functions = @{
    'New-AzResourceGroupDeploymentWhatIf' = {
    <#
    .Synopsis
        Shows what would happen if an Azure Resource Group was deployed
    .Description
        Shows what would happen if an Azure Resource Group was deployed with a given template 
    .Link
        New-AzDeploymentWhatIf        
    #>
    [CmdletBinding()]
    param (
    # The resource group name
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName=$true)]
    [Alias('ResourceGroup')]
    [string]
    $ResourceGroupName,

    # The template URI
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName=$true)]
    [Alias("TemplateFile")]
    [string]
    $TemplateUri
    )

    process {

        $DeleteStart = "^$([char]27)\[38;5;208m"
        $CreateStart = "^$([char]27)\[38;5;77m"
        $ModifyStart = "^$([char]27)\[38;5;141m"
        $DeployStart = "^$([char]27)\[38;5;39m"
        $IgnoreStart = "^$([char]27)\[38;5;246m"
        $NoChangeStart = "^$([char]27)\[0m"
        $Reset = "^$([char]27)\[0m"

        $whatIfResult = New-AzDeploymentWhatIf -ScopeType ResourceGroup `
            -ResourceGroupName $ResourceGroupName `
            -TemplateUri $TemplateUri | Out-String

        $shouldRender = $True
        $filteredResult = [Text.StringBuilder]::new()

        foreach ($line in $($whatIfResult -split "`r`n")) {
            if ($line -Match "($DeleteStart|$ModifyStart|$DeployStart|$IgnoreStart|$NoChangeStart)") {
                $shouldRender = $False
                continue
            }

            if ((-Not $shouldRender) -And ($line -Match $Reset)) {
                continue
            }

            if ((-Not $shouldRender) -And ($line -Match "^[^ ]+")) {
                $shouldRender = $True
            }

            if ((-Not $shouldRender) -And ($line -Match "$CreateStart")) {
                $shouldRender = $True
            }

            if ($shouldRender) {
                $null = $filteredResult.AppendLine("$line")
            }
        }

        $filteredResult.ToString()
    }
}
}

foreach ($kv in $functions.GetEnumerator()) {
    
    $fileName = Join-Path $moduleRoot "$($kv.Key).ps1"
    "function $($kv.Key) {$($kv.Value)}" |
        Set-Content -Path $fileName -Encoding UTF8     
} 


Import-Module "$myModuleRoot\$moduleName.psd1"
