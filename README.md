# PuppetConf 2016 - Nano Server: Puppet + DSC Talk

## Hyper-V Demo

Download and extract Nano Server VHD to C:\VM from https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    # Restart if needed
    Install-Module xHyper-V
    .\SimpleVM.ps1
    Start-DscConfiguration -Wait -Force -Path SimpleVM -Verbose

Open Hyper-V Manager, Connect to VM, and set password.

    Enter-PSSession -VMName NanoVM -Credential Administrator

Cleanup

    .\RmSimpleVM.ps1
    Start-DscConfiguration -Wait -Force -Path RmSimpleVM -Verbose

## Build Vagrant box

### Setup

#### Windows

Install Puppet

    start /wait msiexec.exe /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi

Install Modules

    puppet module install puppetlabs-chocolatey
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-hocon

Switching between Hyper-V and VirtualBox: http://www.hanselman.com/blog/SwitchEasilyBetweenVirtualBoxAndHyperVWithABCDEditBootEntryInWindows81.aspx

#### Mac

**In progress**

Install Puppet

    brew cask install puppet-agent

Install Modules

    puppet module install gildas-homebrew
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-hocon

### Usage

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
