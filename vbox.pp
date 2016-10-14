# Prep:
# - Install Puppet
#    start /wait msiexec.exe /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet-agent-1.7.0-x64.msi
#    $env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin\"
# - Install Modules
#    puppet module install puppetlabs-chocolatey

class { 'chocolatey':
  chocolatey_version => '0.10.1',
}

Package {
  provider => chocolatey,
}

file { 'C:/temp/puppet-staging':
  ensure => directory,
  recurse => true,
  purge => true,
}

$virtualbox_pkg = 'C:/temp/puppet-staging/VirtualBox-5.1.6-110634-Win.exe'
file { $virtualbox_pkg:
  source => 'http://download.virtualbox.org/virtualbox/5.1.6/VirtualBox-5.1.6-110634-Win.exe'
}

package { 'virtualbox':
  ensure => '5.1.6.110634',
  source => $virtualbox_pkg,
  provider => windows,
  install_options => [ '--silent' ],
}

package { 'vagrant':
  ensure => '1.8.5',
}

package { 'packer':
  ensure => '0.10.1',
}
