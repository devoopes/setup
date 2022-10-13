#!/bin/bash
#set -x
//TODO: Makup: https://github.com/lra/mackup

gpg_key="56F783EF1D171748"
git_dir="${HOME}/git"
git_config_name="Sean McCabe"
git_email="sean@ulation.com"
github_user="SeanLeftBelow"
github_org=  # Leave Empty to Skip.

# Brew Setup
echo -n "Install Homebrew? (y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  printf "Installing xcode"
  xcode-select --install
  printf "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  printf "Skipping Homebrew"
fi

brew update && brew upgrade
brew bundle
brew cleanup

# Oh my ZSH
echo -n "Install Oh My ZSH shell? (y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  printf "Skipping Zsh"
fi

# SSH Setup
echo "\n"
echo -n "Create new SSH Key? (y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  #ssh-keygen -t rsa -b 4096 -C ${git_email}
  ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C ${git_email}
  cat ./ssh/id_ed25519.pub >> ssh.pub
else
  printf "Skipping ssh-keygen"
fi

# Git Setup
printf "Git/Github Setup"

cat <<EOF > .gitconfig.temp
[user]
    name = $git_config_name
    email = $git_email
    username = $github_user
    signingkey = $gpg_key
EOF
cat .gitconfig >> .gitconfig.temp

printf "Copying .gitconfig and .gitignore to $HOME"
cp {.gitconfig.temp,.gitignore} ${HOME}/
rm .gitconfig.temp

echo -n "Add the new SSH key to github."
gh ssh-key add key-file
gh ssh-key add key-file --title "personal laptop"
gh ssh-key add ~/.ssh/id_ed25519.pub

printf "\n"
printf "\n"
cat ${HOME}/.ssh/id_rsa.pub
printf "\n"

# Copy Git Repos:
printf "Would you like to clone all your GitHub repos to $git_dir/$github_user? New SSH key GitHub setup is required."
if [ "$answer" != "${answer#[Yy]}" ] ;then
  mkdir -p $git_dir/$github_user && (cd $git_dir/$github_user || exit;
  curl "https://api.github.com/users/$github_user/repos?per_page=1000" | grep -o 'git@[^"]*' | xargs -L1 git clone)
  if [ -z "$github_org" ]
    then
      printf "\$github_org is not set."
    else
      mkdir $git_dir/$github_org && (cd $git_dir/$github_org || exit;
      curl "https://api.github.com/orgs/$github_org/repos?per_page=1000" | grep -o 'git@[^"]*' | xargs -L1 git clone)
  fi
fi

# Setup VIM
printf "VIM Setup"

printf "Copying ..vimrc and .bash_profile to $HOME"
cp {.vimrc,.bash_profile} ${HOME}/

# Setup Atom CLI
printf "Atom Setup"
ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom
apm install --packages-file ./atomfile
# Gen current packages:
# mv atomfile atomfile.old; apm list --installed --bare | grep '^[^@]\+' -o > atomfile

# Python:
printf "Python3 Setup"
brew install python python3
curl https://bootstrap.pypa.io/get-pip.py -o ~/Downloads/get-pip.py
python ~/Downloads/get-pip.py --user
rm ~/Downloads/get-pip.py

pip3 install virtualenv

# Install Jupyter:
python3 -m pip install jupyter

printf "OSX Changes"
# OSX Default Changes
sudo chflags nohidden /Volumes # Show the /Volumes folder
sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true #Enable Dark Mode
chflags nohidden ~/Library     # Show the ~/Library folder
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
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Transmission Configs
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

printf "Done!"
