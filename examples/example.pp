file {'temp':
  ensure => directory,
  path => 'C:/temp',
}

file {'foo':
  ensure => file,
  path => 'C:/temp/foo',
  content => 'hello',
}

file {'web':
  ensure => file,
  path => 'C:/temp/web',
  source => 'https://raw.githubusercontent.com/MikaelSmith/puppetconf2016/master/AppxManifest.xml',
}

$username  = 'vagrant'
$password  = 'vagrant'
$groupname = 'puppet'

exec { 'puppet group':
  command  => "New-LocalGroup -Name ${groupname}",
  unless   => "Get-LocalGroup -Name ${groupname}",
  provider => powershell,
}

exec { 'vagrant user':
  command  => "New-LocalUser -Name ${username} -Password (ConvertTo-SecureString -AsPlainText \"${password}\" -Force)",
  unless   => "Get-LocalUser -Name ${username}",
  provider => powershell,
}

exec { 'vagrant user in puppet group':
  command  => "Add-LocalGroupMember -Group ${groupname} -Member ${username}",
  unless   => "Get-LocalGroupMember -Group ${groupname} -Member ${username}",
  provider => powershell,
  require  => [Exec['puppet group'], Exec['vagrant user']],
}
