# setup.ps1

# download and install Chocolatey
Write-Output "Downloading and installing Chocolatey"
Invoke-WebRequest -useb community.chocolatey.org/install.ps1 | Invoke-Expression

# download and install core python packages
Write-Output "Installing Chocolatey Packages"
choco install -y powershell-core
choco install -y vscode
choco install -y git --package-parameters="/NoAutoCrlf /NoShellIntegration"
choco install -y pyenv-win

# installation of oh-my-posh, posh-git, and zlocation
winget install JanDeDobbeleer.OhMyPosh -s winget
Install-Module posh-git -Scope CurrentUser
Import-Module posh-git
Install-Module ZLocation -Scope CurrentUser
Import-Module ZLocation

# add posh-git, zlocation, and oh-my-posh to the profile
New-Item -Force $PROFILE
Add-Content -Value "`r`n`r`nImport-Module posh-git`r`n" -Encoding utf8 -Path $PROFILE.CurrentUserAllHosts
Add-Content -Value "`r`n`r`nImport-Module ZLocation`r`n" -Encoding utf8 -Path $PROFILE.CurrentUserAllHosts
Add-Content -Value "`r`n`r`noh-my-posh init pwsh --config '$pwd\json.omp.json | Invoke-Expression`r`n" -Encoding utf8 -Path $PROFILE.CurrentUserAllHosts


refreshenv

# The refreshenv command usually doesn't work on first install.
# This is a way to make sure that the Path gets updated for the following
# operations that require Path to be refreshed.
# Source: https://stackoverflow.com/a/22670892/10445017
foreach ($level in "Machine", "User") {
    [Environment]::GetEnvironmentVariables($level).GetEnumerator() |
    ForEach-Object {
        if ($_.Name -match 'Path$') {
            $combined_path = (Get-Content "Env:$($_.Name)") + ";$($_.Value)"
            $_.Value = (
                ($combined_path -split ';' | Select-Object -unique) -join ';'
            )
        }
        $_
    } | Set-Content -Path { "Env:$($_.Name)" }
}

Write-Output "Setting up pyenv and installing Python"
pyenv update
pyenv install --quiet 3.13.3 3.12.0 3.11.5 3.10.5
pyenv global 3.13.3

Write-Output "Generating SSH key"
ssh-keygen -C charmillion@gmail.com -P '""' -f "$HOME/.ssh/id_ed25519"
cat $HOME/.ssh/id_ed25519.pub | clip

Write-Output "Your SSH key has been copied to the clipboard"