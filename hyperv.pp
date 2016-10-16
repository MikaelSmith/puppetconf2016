dsc_xVMSwitch { 'nat':
  dsc_ensure => 'present',
  dsc_name => 'nat',
  dsc_type => 'Internal',
}

dsc_xVMHyperV { 'NanoVM':
  dsc_ensure => present,
  dsc_name => 'NanoVM',
  dsc_vhdpath => 'C:/VM/NanoServerDataCenter.vhd',
  dsc_switchname => 'nat',
  dsc_state => 'running',
  dsc_generation => 1,
  dsc_startupmemory => 536870912,
  dsc_processorcount => 1,
  require => Dsc_XVMSwitch['nat'],
}
