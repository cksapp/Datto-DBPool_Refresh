properties {
    $PSBPreference.General.SrcRootDir = 'src'
    $PSBPreference.General.ModuleName = 'Datto.DBPool.Refresh'
    $PSBPreference.Build.OutDir = "$projectRoot"
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $true
    $PSBPreference.Build.CopyDirectories = @('scripts')
    $PSBPreference.Build.CompileScriptHeader = '#Region' + [System.Environment]::NewLine
    $PSBPreference.Build.CompileScriptFooter = [System.Environment]::NewLine + '#EndRegion'
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Test.ImportModule = $true
    $PSBPreference.Docs.RootDir = "./docs/generated"
}

Task Default -Depends Test

# Custom task to update functions export
Task UpdateFunctionsToExport -Depends StageFiles {
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

# Custom task to remove nested modules - run after StageFiles but before GenerateMarkdown
Task RemoveNestedModules -Depends UpdateFunctionsToExport {
    $modulePath_Built = Join-Path -Path $env:BHBuildOutput -ChildPath $( $env:BHProjectName + '.psd1' )

    Write-Host 'Updating module manifest to remove NestedModules section'
    # Replace & comment out NestedModules from built module
    Update-Metadata -Path $modulePath_Built -PropertyName NestedModules -Value @()
    (Get-Content -Path $modulePath_Built -Raw) -replace 'NestedModules = @\(\)', '# NestedModules = @()' | Set-Content -Path $modulePath_Built
    Write-Host 'Module manifest updated successfully'
}

# Override GenerateMarkdown to depend on RemoveNestedModules
Task GenerateMarkdown -FromModule PowerShellBuild -Depends RemoveNestedModules

# Override Build to include your custom dependencies
Task Build -FromModule PowerShellBuild -Depends @('GenerateMarkdown', 'BuildHelp')

# Test task inherits from PowerShellBuild and will depend on Build
Task Test -FromModule PowerShellBuild -MinimumVersion '0.6.1' -Depends Build

Task PublishDocs -Depends Build {
    Exec {
        docker run -v "$($psake.build_script_dir)`:/docs" -e "CI=true" -e "GITHUB_TOKEN=$env:GITHUB_TOKEN" -e "GITHUB_REPOSITORY=$env:GITHUB_REPOSITORY" -e "GITHUB_ACTOR=$env:GITHUB_ACTOR" --entrypoint 'sh' squidfunk/mkdocs-material:9 -c 'set -e; python -m venv /tmp/venv && . /tmp/venv/bin/activate && pip install -r requirements.txt && if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPOSITORY" ]; then echo "GITHUB_TOKEN and GITHUB_REPOSITORY are required for gh-deploy"; exit 1; fi; git config --global user.email "${GITHUB_ACTOR:-github-actions[bot]}@users.noreply.github.com"; git config --global user.name "${GITHUB_ACTOR:-github-actions[bot]}"; git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"; mkdocs gh-deploy --force'
    }
}
