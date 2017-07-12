#!/usr/bin/env bash

if [ -z "$PS1" ]; then
  echo -e "${COLOR_RED}You should source this file, not run it; e.g. source ./`basename $0`${COLOR_NC}"
else

  symlink (){
    if [ -e $1 ]; then
      # delete with confirmation (to avoid cursing)
      if [ -e $2 ]; then
        rm -i $2
      fi

      # create symlink only if target doesn't exist (e.g. if the user declined deletion)
      if [ ! -e $2 ]; then
        ln -is $1 $2
      fi
    fi
  }

  # create symlinks in a configuration-independent manner
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # submodules
  git submodule init
  git submodule update

  # binaries
  symlink $DIR/bin ~/.bin

  # bash
  symlink $DIR/etc/bash_profile ~/.bash_profile
  symlink $DIR/etc/bashrc ~/.bashrc
  symlink $DIR/etc/bashrc_help ~/.bashrc_help
  symlink $DIR/etc/bashrc_app_specific ~/.bashrc_app_specific
  if [ ! -f ~/.bashrc_local ]; then
    # never overwrite an existing .bashrc_local file with the example!
    cp $DIR/etc/bashrc_local_example ~/.bashrc_local
  fi

  # git
  symlink $DIR/etc/gitconfig ~/.gitconfig
  symlink $DIR/etc/gitignore ~/.gitignore
  symlink $DIR/etc/gitattributes ~/.gitattributes

  # git aliases
  while true; do
    echo "Do you wish to install custom Git aliases? [y/n]: "
    read -p "> " yn
    case $yn in
      [Yy]* ) source $DIR/etc/gitaliases; break;;
      * ) break;;
    esac
  done

  # git-completion (register that module with your installation of bash_completion)
  # ${BASH_COMPLETION_DIR} is bash_completion's configuration directory
  if [ -d ${BASH_COMPLETION_DIR} ] && [ ! -f ${BASH_COMPLETION_DIR}/git-completion.bash ]; then
    # you have bash_completion installed
    # -AND-
    # the git-completion.bash module is not registered with bash_completion

    # 1. look for your git installation's "git-completion.bash" file...
    # 1a. vomit-inducing way that only works with homebrew-installed git...
    # GIT_COMPLETION_FILE="$(which git)"
    # GIT_COMPLETION_FILE="${GIT_COMPLETION_FILE/bin\/git/}share/git-core/git-completion.bash"

    # 1b. find-based method...
    GIT_COMPLETION_FILE_LIST=""
    if [ "`uname -s | sed -e 's/  */-/g;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`" = "darwin" ]; then
      # this is a macintosh system
      # compile a list of all possible git-completion.bash files (could be multiple git installations)
      GIT_COMPLETION_FILE_LIST="$(mdfind -name 'git-completion.bash')"
    fi
    if [ "`uname -s | sed -e 's/  */-/g;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`" = "linux" ]; then
      # this is a linux system
      # compile a list of all possible git-completion.bash files (could be multiple git installations)
      GIT_COMPLETION_FILE_LIST="$(find /usr /bin /etc /opt -type f -name '*git-completion.bash' 2>/dev/null)"
    fi
    GIT_COMPLETION_FILE="$(echo ${GIT_COMPLETION_FILE_LIST} | grep $(git --version | awk '{print $3}') | grep 'bash_completion.d' | head -n1)"

    # did we find GIT_COMPLETION_FILE ?
    if [ -f ${GIT_COMPLETION_FILE} ]; then
      # 2. create a symbolic link inside your bash_completion.d dir for your git
      #    installation's "git-completion.bash" file
      symlink ${GIT_COMPLETION_FILE} ${BASH_COMPLETION_DIR}/git-completion.bash
    else
      # 3. vomit on the user (try to avoid this step...)
      echo "Failed to inject git-completion into your system's bash_completion.d directory!"
      echo "You may wish to manually setup git-completion!"
      echo "BASH_COMPLETION_DIR: '${BASH_COMPLETION_DIR}'"
      echo "GIT_COMPLETION_FILE: '${GIT_COMPLETION_FILE}'"
    fi
  fi

  # vim
  symlink $DIR/etc/vim/vimrc ~/.vimrc
  symlink $DIR/etc/vim/gvimrc ~/.gvimrc
  symlink $DIR/etc/vim ~/.vim

  # misc
  symlink $DIR/etc/subversion ~/.subversion
  symlink $DIR/etc/autotest ~/.autotest
  symlink $DIR/etc/irbrc ~/.irbrc
  # symlink $DIR/etc/ssh_config ~/.ssh/config

  # powerline shell prompt
  symlink $DIR/etc/powerline/shell/powerline-shell.py ~/.powerline-shell.py

  # increase mac system open file and proc limits
  if [ -e /Library/LaunchDaemons ]; then
  echo "About to install LaunchDaemons..."
    sudo cp $DIR/etc/LaunchDaemons/limit.maxfiles.plist /Library/LaunchDaemons/
  sudo launchctl load /Library/LaunchDaemons/limit.maxfiles.plist
    sudo cp $DIR/etc/LaunchDaemons/limit.maxproc.plist /Library/LaunchDaemons/
  sudo launchctl load /Library/LaunchDaemons/limit.maxproc.plist
  fi

  echo "Your home directory's symbolic links now point to the files in \"$DIR/etc\""
  echo "You should re-run this script if \"$DIR\" is ever moved"

  source ~/.bash_profile
fi
