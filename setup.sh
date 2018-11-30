#!/bin/bash

#TODO: Makup: https://github.com/lra/mackup


#TODO: GPG Key
#gpg_key=

#Apps Installed via Brew Cask
apps=(
  dropbox
  evernote
  google-chrome
  atom
  steam
  iterm2
  vlc
  transmission
  keepassxc
  cakebrew
  gpgtools
)

# Brew Apps
brew=(
  tmux
  git 
  "vim --with-override-system-vi"
  wget
  bash
  pick
  aspell
  bash-completion
  tree
  trash
  awscli
  git-extras
  htop
)

# Brew Setup
echo "Installing xcode"
xcode-select --install

echo "Installing Homebrew"
if test ! $(which brew); then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update
brew install caskroom/cask/brew-cask

echo "Instlal Home Brew Packages"
brew install  ${brew[@]}
brew cleanup

brew tap caskroom/versions
brew cask install --appdir="/Applications" ${apps[@]}
brew cask cleanup

# SSH Setup
echo "Create new SSH Key"
gpg --keyserver hkp://pgp.mit.edu --recv ${gpg_key}
prompt "Export key to Github"
ssh-keygen -t rsa -b 4096 -C ${git_email}
pbcopy < ~/.ssh/id_rsa.pub
open https://github.com/settings/ssh/new

# Git Setup
echo "Git setup"
prompt "Set git defaults"
for config in "${git_configs[@]}"
do
  git config --global ${config}
done

cp .gitconfig ~/
cp .gitignore ~/

echo "Vim setup"
cp .vimrc ~/

cp .bash_profile ~/

#Python:
brew install python python3
curl https://bootstrap.pypa.io/get-pip.py -o ~/Downloads/get-pip.py
python ~/Downloads/get-pip.py --user

pip install virtualenv virtualenvwrapper --user
source /Users/$USER/Library/Python/2.7/bin/virtualenvwrapper.sh

cat ~/.virtualenvs/postactivate << EOF

project_name=$(basename $VIRTUAL_ENV)
GIT_REPOS="~/path/to/projects"
cd ${GIT_REPOS}/$project_name
if  [ -f requirements.txt ]; then
    pip install -r requirements.txt
elif [[ -d requirements && -f requirements/development.txt ]]; then
    pip install -r requirements/development.txt
fi
EOF

# OSX Stuff
# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
# Disable 'natural' (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# Dont automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false
# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
# Disable auto corrections
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false      # Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false    # Disable smart dashes
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false  # Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false   # Disable smart quotes
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false  # Disable auto-correct
# Finder:
# allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true
# Set Desktop as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
defaults write com.apple.finder AppleShowAllFiles -bool true        # Finder: Show hidden files by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true     # Finder: Show all filename extensions
defaults write com.apple.finder ShowStatusBar -bool true            # Finder: Show status bar
defaults write com.apple.finder ShowPathbar -bool true              # Finder: Show path bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true  # Finder: Display full POSIX path as window title
defaults write com.apple.finder _FXSortFoldersFirst -bool true      # Finder: Keep folders on top when sorting by name
chflags nohidden ~/Library     # Show the ~/Library folder
sudo chflags nohidden /Volumes # Show the /Volumes folder
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Transmission Stuff
# Use `~/Downloads/Incomplete` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"
# Don't prompt for confirmation before downloading
defaults write org.m0k.transmission DownloadAsk -bool false
# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false
# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false




echo "Done!"

# Sources:
#  https://gist.github.com/bradp/bea76b16d3325f5c47d4
#  https://github.com/pathikrit/mac-setup-script/blob/master/install.sh
#  https://github.com/donnemartin/dev-setup
