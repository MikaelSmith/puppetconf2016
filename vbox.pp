include 'chocolatey'

Package {
  provider => chocolatey,
}

package { 'virtualbox':
  ensure => '5.1.6.110634',
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

$box_url = "${packer_templates}/windowsNano-virtualbox.box"
exec { 'run packer':
  command => 'C:/ProgramData/chocolatey/bin/packer.exe build -only=virtualbox-iso -force vbox-nano.json',
  timeout => 3000,
  cwd => $packer_templates,
  creates => $box_url,
  require => Hocon_Setting['headless'],
}

$vagrantfile_template = @("STOP")
Vagrant.configure(2) do |config|
  config.vm.guest = :windows
  config.vm.communicator = 'winrm'
  config.vm.box = 'nano-rtm'
  config.vm.box_url = "$box_url"

  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--hardwareuuid', '02f110e7-369a-4bbc-bbe6-6f0b6864ccb6']
    vb.gui = true
    vb.memory = '1024'
  end

  config.vm.provider 'hyperv' do |hv|
    hv.ip_address_timeout = 240
  end
end
STOP

file { 'vagrantfile':
  ensure => file,
  path => "${packer_templates}/Vagrantfile",
  content => $vagrantfile_template,
  require => Vcsrepo[$packer_templates],
}

$instructions = @("END")
A Vagrant box has been created at $box_url, with a Vagrantfile in the parent directory.
To use the box, run
  vagrant up
It may not finish, due to a bug in Vagrant's WinRM support. If it hangs, Ctrl-C twice to exit.
The box should still be usable. To connect, first enable Powershell remoting
  Enable-PSRemoting -Force
  Set-Item "wsman:\localhost\client\trustedhosts" -Value "localhost" -Force
Then use the password 'vagrant' and run
  Enter-PSSession -ComputerName localhost -Port 55985 -Credential vagrant
END

notify { 'using the box':
  message => $instructions,
  require => [File['vagrantfile'], Exec['run packer']],
}
