#!/usr/bin/env bash
set -e
install_vbox() {
	if [ ! -d /Applications/VirtualBox.app/ ]; then
		echo "Installing Virtual Box:"
		wget -c http://download.virtualbox.org/virtualbox/4.2.16/VirtualBox-4.2.16-86992-OSX.dmg
		disk=$(hdiutil attach VirtualBox-4.2.16-86992-OSX.dmg | grep "/Volumes/VirtualBox" | awk '{print $1}') 2>&1 > /dev/null
		osascript -e "do shell script \"installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /\" with administrator privileges"
		hdiutil detach "$disk"
		rm -f VirtualBox-4.2.16-86992-OSX.dmg
		echo -ne "\nVirtual Box - installed\n"
	else
		echo "Virtual Box already installed"
	fi
}

install_vagrant() {
	if [ ! -x /usr/bin/vagrant ]; then
		echo "Installing Vagrant:"
		wget -c http://files.vagrantup.com/packages/7ec0ee1d00a916f80b109a298bab08e391945243/Vagrant-1.2.7.dmg
		disk=$(hdiutil attach Vagrant-1.2.7.dmg | grep "/Volumes/Vagrant" | awk '{print $1}') 2>&1 > /dev/null
		osascript -e "do shell script \"installer -pkg /Volumes/Vagrant/Vagrant.pkg -target /\" with administrator privileges"
		hdiutil detach "$disk"
		rm -f Vagrant-1.2.7.dmg
		echo -ne "\nVagrant - installed\n"
	else
		echo "Vagrant already installed"
		exit 0
	fi
}

if [ `uname` != "Darwin" ]; then
	echo "We're not on Mac OS X, bye"
	exit 1
else
	install_vbox
	install_vagrant
fi
