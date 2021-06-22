#Powershell Setup Desktop
New-Variable -Name "gpg_key" -Value "56F783EF1D171748"
New-Variable -Name "git_dir" -Value "${HOME}/git"
New-Variable -Name "git_config_name" -Value "Sean McCabe"
New-Variable -Name "git_email" -Value "sean@ulation.com"
New-Variable -Name "github_user" -Value "SeanLeftBelow"
New-Variable -Name "github_org" -Value     # Leave Empty to Skip.

# Setup new SSH key.
echo "Making new SSH Key"
mkdir ~/.ssh
cd ~/.ssh
ssh-keygen

# Install Chocolatey
Set-ExecutionPolicy AllSigned
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco update
choco install packages.config

# Setup git
# echo "Setting up git"
# mkdir ~/git
# cd ~/git
# cat <<EOF > .gitconfig.temp
# [user]
    # name = $git_config_name
    # email = $git_email
    # username = $github_user
    # signingkey = $gpg_key
# EOF
# cat .gitconfig >> .gitconfig.temp
# printf "Copying .gitconfig and .gitignore to $HOME"
# cp {.gitconfig.temp,.gitignore} ${HOME}/
# rm .gitconfig.temp

# Install Python
choco install python
pip3 install virtualenv
python3 -m pip install jupyter

#Install Atom
echo "Atom Setup"
apm install --packages-file ./atomfile

# Enable Windows Subsystem Linux
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
