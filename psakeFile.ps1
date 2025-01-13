properties {
    $PSBPreference.General.SrcRootDir = 'src'
    $PSBPreference.General.ModuleName = 'Datto.DBPool.Refresh'
    $PSBPreference.Build.OutDir = $projectRoot
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $true
    $PSBPreference.Build.CopyDirectories = @('scripts')
    $PSBPreference.Build.CompileScriptHeader = [System.Environment]::NewLine + '#Region'
    $PSBPreference.Build.CompileScriptFooter = "#EndRegion"
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Test.ImportModule = $true
    $PSBPreference.Docs.RootDir = "./docs/generated"
}

task Default -depends Test

Task UpdateFunctionsToExport -depends StageFiles {
    Write-Host 'Updating module manifest to update FunctionsToExport section'

    $exportDirectory = 'Public', 'Private'
    $allFunctions = New-Object System.Collections.ArrayList

    foreach ($directory in $exportDirectory) {
        $directoryPath = Join-Path -Path $env:BHPSModulePath -ChildPath $directory
        $pattern = Join-Path -Path $directoryPath -ChildPath '*.ps1'
        $functions = Get-ChildItem -Path $pattern -Recurse -ErrorAction SilentlyContinue
        $allFunctions.AddRange($functions) | Out-Null
    }

    if ($allFunctions) {
        $modulePath_Built = Join-Path -Path $env:BHBuildOutput -ChildPath $( $env:BHProjectName + '.psd1' )

        # Update FunctionsToExport with all functions in the module
        Update-Metadata -Path $modulePath_Built -PropertyName FunctionsToExport -Value $allFunctions.BaseName

        Write-Host 'Module manifest updated successfully'
    }
}


Task Build -FromModule PowerShellBuild -depends @('StageFiles', 'UpdateFunctionsToExport', 'BuildHelp')

task Test -FromModule PowerShellBuild -minimumVersion '0.6.1'

task PublishDocs -depends Build {
    exec {
        docker run -v "$($psake.build_script_dir)`:/docs" -e 'CI=true' --entrypoint 'sh' squidfunk/mkdocs-material:9 -c 'pip install -r requirements.txt && mkdocs gh-deploy --force'
    }
}
