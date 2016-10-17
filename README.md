# PuppetConf 2016 - Nano Server: Puppet + DSC Talk

## Hyper-V Demo

Download and extract Nano Server VHD to C:\VM from https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016.

All the following commands are run As Administrator, as required to manage Hyper-V instances.

Enable Hyper-V

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Restart-Computer -Force

Start Nano Server

    Install-Module xHyper-V
    .\SimpleVM.ps1
    Start-DscConfiguration -Wait -Force -Path SimpleVM -Verbose

Open Hyper-V Manager, Connect to VM, and set password.

Connect via PowerShell ISE

    Enter-PSSession -VMName SimpleVM -Credential Administrator
    echo hello > hello.txt
    psedit hello.txt

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
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:ProgramFiles\Docker", [EnvironmentVariableTarget]::Machine)
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

## Packaging Demo

First install the Windows 10 SDK from https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk

Create the package

    # Set publisher CN to match your signing key
    cp .\AppxManifest.xml 'C:\Program Files\Puppet Labs\Puppet\'
    cp .\logo.png 'C:\Program Files\Puppet Labs\Puppet\'
    & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\makeappx.exe' pack /d 'C:\Program Files\Puppet Labs\Puppet' /p puppet-agent.appx

Sign the package (https://msdn.microsoft.com/en-us/library/windows/desktop/jj835832(v=vs.85).aspx)

    & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe' /n "CN=Michael, O=Michael, C=US" /r /h 0 /eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" /e "01/01/2017" /sv MyKey.pvk MyKey.cer
    & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\pvk2pfx.exe' /pvk MyKey.pvk /spc MyKey.cer /pfx MyKey.pfx
    & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\signtool.exe' sign /fd SHA256 /a /f MyKey.pfx puppet-agent.appx

Add to the Hyper-V image

    Mount-DiskImage -ImagePath C:\VM\NanoServerDataCenter.vhd
    cp puppet-agent.appx E:\
    cp MyKey.cer E:\
    Dismount-DiskImage -ImagePath C:\VM\NanoServerDataCenter.vhd

Start VM

    Start-DscConfiguration -Wait -Force -Path SimpleVM -Verbose
    Enter-PSSession -VMName SimpleVM -Credential Administrator

Install the app

    Import-Certificate -FilePath C:\MyKey.cer -CertStoreLocation Cert:\LocalMachine\Root
    Add-AppxPackage C:\puppet-agent.appx
    Get-AppxPackage puppet-agent
    # Show contents installed at InstallLocation
    Remove-AppxPackage puppet-agent

Cleanup

    Start-DscConfiguration -Wait -Force -Path RmSimpleVM -Verbose

Note that the service probably isn't working yet.

## Debugging Problems Demo

First install the Windows 10 SDK from https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk

Setup NanoServerApiScan

    mkdir "$env:ProgramFiles\NanoApiScan"
    Invoke-WebRequest "https://msdnshared.blob.core.windows.net/media/2016/04/NanoServerApiScan.zip" -OutFile "$env:TEMP\NanoServerApiScan.zip"
    Expand-Archive -Path "$env:TEMP\NanoServerApiScan.zip" -DestinationPath "$env:ProgramFiles\NanoApiScan"
    Mount-DiskImage -ImagePath C:\VM\NanoServerDataCenter.vhd
    cp -r E:\Windows\System32\forwarders\* "$env:ProgramFiles\NanoApiScan"
    Dismount-DiskImage -ImagePath C:\VM\NanoServerDataCenter.vhd

Scan nano.exe

    Invoke-WebRequest https://www.nano-editor.org/dist/v2.5/NT/nano-2.5.3.zip -OutFile "$env:TEMP\nano-2.5.3.zip" -UseBasicParsing
    Expand-Archive -Path "$env:TEMP\nano-2.5.3.zip" -DestinationPath "$env:ProgramFiles"
    & 'C:\Program Files\NanoApiScan\NanoServerApiScan.exe' /BinaryPath:'C:\Program Files\nano-2.5.3-win32' /WindowsKitsPath:'C:\Program Files (x86)\Windows Kits'

Try vim

    choco install -y vim-x64
    & 'C:\Program Files\Vim\vim80\vim.exe'
    pushd 'C:\Program Files\NanoApiScan'
    & .\NanoServerApiScan.exe /BinaryPath:'C:\Program Files\Vim\vim80' /WindowsKitsPath:'C:\Program Files (x86)\Windows Kits'
    popd
