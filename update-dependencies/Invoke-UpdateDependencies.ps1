# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

[cmdletbinding()]
param(
    [string]$UpdateDependenciesParams,
    [switch]$CleanupDocker
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$imageName = "update-dependencies"

try {
    & docker build -t $imageName -f $PSScriptRoot\Dockerfile --pull $PSScriptRoot
    if ($LastExitCode -ne 0) {
        throw "Failed to build the update dependencies tool"
    }

    $repoRoot = Split-Path -Path "$PSScriptRoot" -Parent
    Invoke-Expression "docker run --rm -v ${repoRoot}:C:\repo -w /repo --user ContainerAdministrator $imageName $UpdateDependenciesParams"
    if ($LastExitCode -ne 0) {
        throw "Failed to update dependencies"
    }
}
finally {
    if ($CleanupDocker) {
        & docker rmi -f $imageName
        & docker system prune -f
    }
}