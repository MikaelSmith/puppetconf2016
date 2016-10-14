# Prep:
# - Install Puppet
#    start /wait msiexec.exe /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet-agent-1.7.0-x64.msi
#    $env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin\"
# - Install Modules
#    puppet module install puppetlabs-chocolatey puppetlabs-vcsrepo puppetlabs-hocon

class { 'chocolatey':
  chocolatey_version => '0.10.3',
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

package { 'git':
  ensure => latest,
}

$packer_templates = 'C:/temp/packer-templates'
vcsrepo { $packer_templates:
  ensure => present,
  provider => git,
  source => 'https://github.com/mwrock/packer-templates.git',
  revision => 'b46ec4e1c3eafcaa64042f32ceab7de2d3789dba',
  require => Package['git'],
}

# This is a hack needed with Packer 0.10.1, see https://github.com/mitchellh/packer/issues/2401
hocon_setting { 'headless':
  ensure => present,
  path => "${packer_templates}/vbox-nano.json",
  setting => 'variables.headless',
  value => 'true',
  require => Vcsrepo[$packer_templates],
}

# TODO: run packer to generate vbox, lay down Vagrantfile, print instructions to connect it