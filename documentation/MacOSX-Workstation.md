# Mac OS X Workstation Setup with chef

Note: it is very important to run the bootstrap steps in the order they are
given below. Otherwise random things will break.

## User Account
After booting Mac OS X for the first time a wizard will setup the first user
account. This is the Developers' personal account. The credentials should be
obtained from the Welcome Sheet for new employees if applicable.

## Admin Account (optional)

For recovery and emergency purposes an administrative account needs to be
created:

 * Open User Management in System Settings
 * System Settings -> Users & Groups
 * Click on the "+"-button to create a new user with the following data:
 * New Account: Administrator
 * Full Name: Administrator
 * Accountname: administrator
 * Password: ask the Head of Security
 * Password Hint: leave empty

## Activate FileVault Disk Encryption

The filesystem needs to be encrypted and you need to activate decryption for
the Administrator account:

 * Open security settings
 * System Settings -> Security & Privacy -> FileVault
 * Turn On FileVault
 * Enable User ...
 * Enter the Administrator Password
 * Continue and do not store the Recovery Key with Apple
 * Reboot in order to start the encryption process

The encryption process will take about one hour but bootstrapping can be done
simultaneously.

## Install XCode & Command Line Tools

You need to install XCode from the App Store:

 * Start App Store
 * Search for Xcode
 * Install using the iTunes credentials from the Keyring page

As soon as XCode has been installed you need to install the Command Line Tools from within XCode:

 * Start XCode
 * Install the necessary Frameworks if you are prompted to do so
 * Go to Preferences -> Downloads
 * Install Command Line Tools
 * Wait for the installation to finish
 * Quit XCode

## Install XQuartz

On Mountain Lion Apple does not ship an X11 implementation anymore. In order to
compile packages which depend on X11 you need to install XQuartz from
http://xquartz.macosforge.org/landing/

## Chef Bootstrap

Homebrew and a bunch of basic shell utilities can be bootstrapped using Chef.

 * Open Terminal
 * git clone https://github.com/zenops/cookbooks ~/chef && cd ~/chef
   * If you want to use the same configuration on multiple machines you should
     create a private fork of this repository.
 * ./scripts/bootstrap-mac
   * You will be prompted to install Java. Do it!
   * After chef has bootstrapped you will be prompted to install the Menlo for
     Powerline font. Do it!
 * iTerm will open and tell you that the Solarized Dark color scheme has been
   imported.
   * Go to Preferences -> Profiles
   * Click on Load Presets and select Solarized Dark
   * Go to the Font tab and set Menlo for Powerline
