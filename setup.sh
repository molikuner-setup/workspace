#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ "$1" ]; then
  [ "${1^^}" = "-Y" ]
  OVERWRITE=$?
fi

printResult() {
  [ $? = 0 ] && echo "${GREEN}OKAY${NC}" || (echo "${RED}FAILED${NC}" && exit 1)
}

advancedRead() {
  read -p "$1" -i "$2" result
  result=${result:-"$2"} # pre bash 4.0
  [ "$3" ] && eval $3=\$result
}

simpleRead() {
  advancedRead "$1 [Y/n]: " "Y" $2
}

simpleQuestion() {
  [ "$OVERWRITE" ] && return $OVERWRITE
  simpleRead "$1"
  [ "${result^}" = "Y" ]
  return $?
}

simpleQuestion "please be aware, that I never tested this script" || exit 0

INSTALL_LIST_APT=""
PURGE_LIST_APT=""
addInstallApt() {
  INSTALL_LIST_APT="$INSTALL_LIST_APT $1"
}
addPurgeApt() {
  PURGE_LIST_APT="$PURGE_LIST_APT $1"
}
simpleInstallApt() {
  if simpleQuestion "install '$1'"; then
    echo -e "${GREEN}putting$NC '$1' into list\n"
    addInstallApt "$1"
    return 0
  else
    echo -e "${RED}not$NC installing '$1'\n"
    return 1
  fi
}
simplePurgeApt() {
  if simpleQuestion "purge '$1'"; then
    echo -e "${GREEN}putting$NC '$1' into list\n"
    addPurgeApt "$1"
    return 0
  else
    echo -e "${RED}not$NC purging '$1'\n"
    return 1
  fi
}
aptPurge() {
  sudo apt purge $*
}
aptInstall() {
  sudo apt install $*
}
applyProgramUpdatesApt() {
  echo -ne "updating apt sources ...\b\b\b"
  sudo apt update &>/dev/null; printResult
  if [ "$PURGE_LIST_APT" ]; then
    echo "purging: $PURGE_LIST_APT"
    aptPurge $PURGE_LIST_APT
  else
    echo "nothing to purge"
  fi
  if [ "$INSTALL_LIST_APT" ]; then
    echo "installing: $INSTALL_LIST_APT"
    aptInstall $INSTALL_LIST_APT
  else
    echo "nothing to install"
  fi
  sudo apt autoremove
  sudo apt upgrade
  sudo apt clean
  sudo apt autoclean
}

simpleInstallApt "tmux"
simpleInstallApt "htop"
simpleInstallApt "dirmngr"
simpleInstallApt "zsh"
simpleInstallApt "curl"
simpleInstallApt "git"
simpleInstallApt "apt-transport-https"
simpleInstallApt "build-essential"
simpleInstallApt "flatpak"
simpleInstallApt "hostapd"
simpleInstallApt "gnome-software-plugin-flatpak"
simpleInstallApt "pavucontrol"
simpleInstallApt "filezilla"
if simpleInstallApt "gnome-core"; then
  if simplePurgeApt "gnome"; then
    simplePurgeApt "brasero" || addInstallApt "brasero"
    simplePurgeApt "cheese" || addInstallApt "cheese"
    simplePurgeApt "polari" || addInstallApt "polari"
    simplePurgeApt "gnome-games" || addInstallApt "gnome-games"
    simplePurgeApt "gnome-music" || addInstallApt "gnome-music"
    simplePurgeApt "gnome-maps" || addInstallApt "gnome-maps"
    simplePurgeApt "gnome-dictionary" || addInstallApt "gnome-dictionary"
    simplePurgeApt "gnome-weather" || addInstallApt "gnome-weather"
    simplePurgeApt "gnome-sound-recorder" || addInstallApt "gnome-sound-recorder"
    simplePurgeApt "gnome-getting-started-docs" || addInstallApt "gnome-getting-started-docs"
    simplePurgeApt "gnome-clocks" || addInstallApt "gnome-clocks"
    simplePurgeApt "transmission-gtk" || addInstallApt "transmission-gtk"
  fi
fi
simplePurgeApt "synaptic"
if simplePurgeApt "libreoffice"; then
  simpleInstallApt "libreoffice-writer"
  simpleInstallApt "libreoffice-calc"
  simpleInstallApt "libreoffice-impress"
fi

applyProgramUpdatesApt

simpleQuestion "disable gnome animations" && gsettings set org.gnome.desktop.interface enable-animations false

simpleQuestion "disable sudo password for $(whoami)" && echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null

simpleGitClone() {
  if ! [ -d "$2/.git" ]; then
    echo -ne "cloning $1 repo ...\b\b\b"
    git clone git@github.com:$1 $2 &>/dev/null; printResult
  fi
}

if type "git" &>/dev/null && simpleQuestion "setup workspace"; then
  advancedRead "workspace path [~/workspace]: " "~/workspace" WORKSPACE_PATH
  simpleGitClone "molikuner-setup/workspace" "$WORKSPACE_PATH"
  simpleGitClone "molikuner-setup/config" "$WORKSPACE_PATH/config"
  simpleGitClone "robbyrussell/oh-my-zsh" "$WORKSPACE_PATH/oh-my-zsh"
  if simpleQuestion "copy configs into ~"; then
    sed -i s/MOLIKUNER_CONF_DIR=\$HOME\/workspace/MOLIKUNER_CONF_DIR=$WORKSPACE_PATH/g $WORKSPACE_PATH/config/zsh/.zshrc
    cp $WORKSPACE_PATH/config/zsh/.zshrc ~
    cp $WORKSPACE_PATH/config/tmux/.tmux.conf ~
  fi
fi

INSTALL_LIST_FLATPAK=""
addInstallFlatpak() {
  INSTALL_LIST_FLATPAK="$INSTALL_LIST_FLATPAK $@"
}
flatpakInstall() {
  sudo flatpak install flathub $*
}
applyProgramUpdatesFlatpak() {
  echo -ne "adding flathub ...\b\b\b"
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &>/dev/null; printResult
  if [ "$INSTALL_LIST_FLATPAK" ]; then
    echo "installing: $INSTALL_LIST_FLATPAK"
    flatpakInstall $INSTALL_LIST_FLATPAK
  else
    echo "nothing to install"
  fi
}
simpleInstallFlatpak() {
  if simpleQuestion "install '$1'"; then
    echo -e "${GREEN}putting$NC '$1' into list\n"
    addInstallFlatpak "$2"
    return 0
  else
    echo -e "${RED}not$NC installing '$1'\n"
    return 1
  fi
}

if type "flatpak" &>/dev/null; then
  simpleInstallFlatpak "spotify" "com.spotify.Client"
  simpleInstallFlatpak "sublime text 3" "com.sublimetext.three"
  simpleInstallFlatpak "authenticator" "com.github.bilelmoussaoui.Authenticator"
  simpleInstallFlatpak "passwordSafe" "org.gnome.PasswordSafe"
  simpleInstallFlatpak "postman" "com.getpostman.Postman"
  simpleInstallFlatpak "wireshark" "org.wireshark.Wireshark"

  applyProgramUpdatesFlatpak
fi

echo "please reboot to complete setup"
