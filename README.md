# PuppetConf 2016 - Nano Server: Puppet + DSC Talk

## Hyper-V Demo

Download and extract Nano Server VHD to C:\VM from https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016.

Enable Hyper-V

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Restart-Computer -Force

Start Nano Server

    Install-Module xHyper-V
    .\SimpleVM.ps1
    Start-DscConfiguration -Wait -Force -Path SimpleVM -Verbose

Open Hyper-V Manager, Connect to VM, and set password.

Connect via PowerShell

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

## Docker Demo

Full instructions for Docker on Windows 10 are at https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_windows_10. The demo requires Windows 10 with `winver` showing build 14393.222 or later.

Enable Hyper-V and Windows 10 Container support

    Enable-WindowsOptionalFeature -Online -FeatureName containers -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Restart-Computer -Force

Get Docker

    Invoke-WebRequest "https://master.dockerproject.org/windows/amd64/docker-1.13.0-dev.zip" -OutFile "$env:TEMP\docker-1.13.0-dev.zip" -UseBasicParsing
    Expand-Archive -Path "$env:TEMP\docker-1.13.0-dev.zip" -DestinationPath $env:ProgramFiles
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)
    $env:PATH = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)

Setup the Docker switch with external access and start Docker
    .\DockerNAT.ps1
    Start-DscConfiguration -Wait -Force -Path DockerNAT -Verbose
    dockerd -D

Start a Nano Server container

    docker pull microsoft/nanoserver
    # Create a link to installed Puppet, because I can't figure out paths with spaces
    cmd /c mklink /D C:\puppet 'C:\Program Files\Puppet Labs\Puppet\'
    docker run -it -v C:\puppet:C:\puppet microsoft/nanoserver powershell

Try some Puppet things

    C:\puppet\bin\facter.bat os
    C:\puppet\bin\puppet.bat apply -e "notify {'Hello World!':}"
