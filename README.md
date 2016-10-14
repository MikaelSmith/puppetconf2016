# Build Vagrant box

## Setup

### Windows

Install Puppet

    start /wait msiexec.exe /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi

Install Modules

    puppet module install puppetlabs-chocolatey
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-hocon

### Mac

**In progress**

Install Puppet

    brew cask install puppet-agent

Install Modules

    puppet module install gildas-homebrew
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-hocon

## Usage

To create a Virtualbox image, run

    puppet apply vbox.pp

A Vagrant box has been created at `C:/temp/packer-templates/windowsNano-virtualbox.box`, with a `Vagrantfile` in the parent directory.

To use the box, run

    vagrant up

It may not finish, due to a bug in Vagrant's WinRM support. If it hangs, `Ctrl-C` twice to exit.

The box should still be usable. To connect, first enable Powershell remoting

    Enable-PSRemoting -Force
    Set-Item "wsman:\localhost\client\trustedhosts" -Value "localhost" -Force

Then use the password `vagrant` and run

    Enter-PSSession -ComputerName localhost -Port 55985 -Credential vagrant

# Hyper-V Demo

Download and extract Nano Server VHD from https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016

Install puppetlabs-dsc and puppetlabs-powershell. May need HEAD of both to get fixes for PowerShell 5.

    puppet apply hyperv.pp
