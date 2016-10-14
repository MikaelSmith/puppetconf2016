# Setup

## Windows

Install Puppet

    start /wait msiexec.exe /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet-agent-1.7.0-x64.msi

Install Modules

    puppet module install puppetlabs-chocolatey
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-hocon

## Mac

**In progress**

Install Puppet

    brew cask install puppet-agent

Install Modules

    puppet module install gildas-homebrew
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-hocon

# Usage

To create a Virtualbox image, run

    puppet apply vbox.pp
