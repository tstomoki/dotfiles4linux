#!/bin/bash
if [ $# -ne 1 ]; then
  echo "指定された引数は$#個です。" 1>&2
  echo "実行するには1個の引数が必要です。e.g. ./init.sh Linux" 1>&2
  exit 1
fi

os_str=`echo $1 | tr '[:upper:]' '[:lower:]'`

# save current dir
root_dir=$PWD

if [ "linux" = $os_str ]; then
    echo "Set up as Linux"
    # install requisite packages
    sudo yum -y groupinstall "Development Tools"
    sudo yum -y install readline-devel zlib-devel bzip2-devel sqlite-devel openssl-devel
    # install tmux
    sudo yum -y install tmux
    # install zsh
    sudo yum -y install zsh
    # change bash to zsh
    sudo usermod -s /bin/zsh `whoami`

    # install tig
    if [ -e $root_dir/lib ]; then
    # 存在する場合
	echo "lib dir already exists"
    else
    # 存在しない場合
	mkdir lib
    fi
    cd lib
    
    if [ -e tig-2.1.tar.gz ]; then
	# 存在する場合
	echo "file already exists"
    else
	# 存在しない場合
	wget http://jonas.nitro.dk/tig/releases/tig-2.1.tar.gz
    fi
    tar xvzf tig-2.1.tar.gz
    cd tig-2.1
    ./configure
    make 
    sudo make install
    
    # install emacs 24.5
    wget http://ftp.jaist.ac.jp/pub/GNU/emacs/emacs-24.5.tar.gz
    tar xzvf emacs-24.5.tar.gz
    cd emacs-24.5
    ./configure --without-x
    make
    sudo make install

elif [ "mac" = $os_str ]; then
    echo "Set up as Mac"
    # Command Line Tools for Xcode
    xcode-select --install
    # install Homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    # install wget
    brew install wget
    # install rbenv
    brew install rbenv ruby-build rbenv-gemset rbenv-gem-rehash
    # install coreutil
    brew install coreutils
fi

# locate .zshrc from zsh/zshrc
ln -s $root_dir/zsh/zshrc_$os_str ~/.zshrc
source ~/.zshrc    

# install python with pyenv
git clone https://github.com/yyuu/pyenv.git ~/.pyenv

# install rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv

# config git
git config --global user.name "tstomoki"
git config --global user.email tstomoki4@gmail.com
git config --global core.editor emacs
git config --global color.ui true

# locate .emacs from emacs/emacs
ln -fs $root_dir/emacs/emacs.d/init.el $HOME/.emacs
cp -rf $root_dir/emacs/emacs.d $HOME/.emacs.d

# set dotfiles
cp -r $root_dir $HOME/.dotfiles

# update submodules
git submodule update --init --recursive
