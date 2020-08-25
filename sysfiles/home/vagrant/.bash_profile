#!/bin/bash
# .bash_profile - This file is part of the Vagrant VM and should only
# contain scripts that should run for EVERY developer using a copy of this VM.
# For personal scripts, create a file .bash_profile_personal in this directory.
PATH_TO_PERSONAL_FILE=/home/vagrant/.bash_profile_personal
if [ -r $PATH_TO_PERSONAL_FILE ]; then
    source $PATH_TO_PERSONAL_FILE
fi

# Replaces a file with a softlink to the file at the same location under
# sysfiles/ in the Vagrant machine. Used in the Vagrantfile, but included here
# because it's very useful when testing adding new files to the VM.
replace_with_link() {
    PATH_TO_LINK=$1
    SYSFILES_ROOT=/vagrant/sysfiles
    rm -rf $PATH_TO_LINK
    CMD="ln -s $SYSFILES_ROOT$PATH_TO_LINK $PATH_TO_LINK"
    echo $CMD
    $CMD
}

# Just a prettified alias for apt-get install
function install_package(){
  echo "-------------------------------------------------------------------------"
  echo "--- Installing package '$1'"
  echo "-------------------------------------------------------------------------"
  apt-get -y --allow-unauthenticated install $1
  echo "-------------------------------------------------------------------------"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
}