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

  # git bash completion
  if [ -n $BASH_COMPLETION_DIR ] && [ ! -f $BASH_COMPLETION_DIR/git-completion.bash ]; then
    GIT_PATH=`which git`
    if [ -n $GIT_PATH ]; then
      GIT_PATH="${GIT_PATH/bin\/git/}"
      GIT_COMPLETION_FILE="$GIT_PATH""share/git-core/git-completion.bash"
    fi
		if [ ! -f $GIT_COMPLETION_FILE ] && [ "$OS" = "darwin" ]; then
			# do something
			GIT_COMPLETION_FILE="`mdfind -name 'git-completion.bash'`"
			GIT_COMPLETION_FILE="${GIT_COMPLETION_FILE##*$'\n'}"
		fi
    # symlink git-completion.bash into the bash_completion.d directory
    if [-n $BASH_COMPLETION_DIR ] && [ -d $BASH_COMPLETION_DIR ] && [ -w $BASH_COMPLETION_DIR ] && [ -f $GIT_COMPLETION_FILE ]; then
      symlink $GIT_COMPLETION_FILE $BASH_COMPLETION_DIR/git-completion.bash
    else
      echo "Automatic symlinking of \"git-completion.bash\" into your \"bash_completion.d\" directory failed"
      if [ -d $BASH_COMPLETION_DIR ] && [ -n $GIT_COMPLETION_FILE ]; then
        echo "Please run this command (as sudo) to create the necessary symlink:"
        echo "  sudo ln -s $GIT_COMPLETION_FILE $BASH_COMPLETION_DIR"
      else
        echo "Please ensure that both \"bash_completion\" & \"git\" are installed & then manually create this symlink to avoid error messages"
      fi
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

  echo "Your home directory's symbolic links now point to the files in \"$DIR/etc\""
  echo "You should re-run this script if \"$DIR\" is ever moved"

  source ~/.bash_profile
fi
