# Datto.DBPool.Refresh

This PowerShell module is used to `Refresh` all child containers in Datto (Kaseya) DBPool.

This can be combined with Scheduled Tasks in Windows or a similar Cron job to automate the refresh script on a set interval.
The recommendation is ~30 - 60 minutes prior to the start of your shift.

## Overview

This section will detail parts of the PowerShell script and give a high-level overview of the logic.

If you would like to make any suggestions, Pull Requests are always welcome. 😄

### API Key

You will need to get your personal API key, which will be needed by the module to refresh your containers.
First login to the web-portal [https://dbpool.datto.net](https://dbpool.datto.net)

1. Select your **User Profile** at the top-right, select **My profile** from the drop-down
   ![profile_Settings](./docs/site/assets/ApiKey/profile_Settings.png)
2. Under **Profile** → **Metadata** → **API key**, listed is your personal API key
   Make a record of this in a safe-place.
   ![personal_ApiKey](./docs/site/assets/ApiKey/personal_ApiKey.png)
3. Use `Set-RefreshDBPoolApiKey` to add the API key to module secret store

### Environment Override

The script is configured to check for an environment override file in the User `$HOME` directory or where specified by `Export-RefreshDBPoolModuleSetting`.

Default location in Windows is "`$HOME\RefreshDBPool`"

### Automating

The module handles automation by creating schedule task in Windows to run refresh script daily.

## Installation

Install from Powershell Gallery

## Examples
