# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.3] Release

Restructured CI/CD with reusable workflows for build, test, and deployment

Implemented automated GitHub release creation and PowerShell Gallery publishing workflow

Added Dependabot configuration for automated dependency updates (github-actions ecosystem)

Added CodeQL security scanning workflow for vulnerability detection

Updated GitHub Actions to latest versions: checkout@v6, cache@v5, UpdatePWSHAction@v1.0.3

Enhanced documentation publishing workflow with proper GitHub environment variables and Docker MkDocs deployment

Added build process improvements with initialization script appending and function export management

Updated PowerShell build dependencies to match production standards (PowerShellBuild 0.7.3, PSScriptAnalyzer 1.24.0, psake 4.9.1)

Ensured Datto.DBPool.API dependency version 0.2.3 minimum for KB5074596 Windows PowerShell 5.1 compatibility

## [0.2.2] Unreleased

Adds documentation link in scheduled task details

Aliases for `Sync-DBPoolContainer` function: 'Refresh-DBPoolContainer', 'Refresh-DBPool', 'Sync-DBPool'

Hidden parameter switch for `Copy-DBPoolParentContainer` function `-AllowBeta` cloning DBPool containers matching 'BETA' name

Verbose output for confirmation prompt with container name in `Sync-DBPoolContainer` function

## [0.1.6.1] Release

Fix minor typo in release module settings

## [0.1.6] Release

Bump pwsh installer version 7.5.0, added loop during DBPool API status check (30 second wait, default 3600 second timeout)

Add $RefreshDBPool_VerbosePreference module setting environment variable

Remove pre-release module tag

## [0.1.5] Prerelease

Fix install script, update module skipPublisher check

## [0.1.4] Prerelease

Update module version to 0.1.4, remove DBPool API Prerelease, and hide output DBPool API Key secure string variable being retireved from secret vault

## [0.1.3] Unreleased

PsStucco Module devlopment, GH pages deply, and monolithic module
