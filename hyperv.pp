dsc_xVMSwitch { 'nat':
  dsc_ensure => 'present',
  dsc_name => 'nat',
  dsc_type => 'Internal',
}

dsc_xVMHyperV { 'NanoVM':
  dsc_ensure => present,
  dsc_name => 'NanoVM',
  dsc_vhdpath => 'C:/Windows Server 2016 DataCenter Nano VHD/NanoServerDataCenter.vhd',
  dsc_switchname => 'nat',
  dsc_state => 'running',
  dsc_generation => 1,
  dsc_startupmemory => 1073741824,
  dsc_processorcount => 1,
  require => Dsc_XVMSwitch['nat'],
}
