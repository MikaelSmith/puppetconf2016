Configuration RmVM {
  param (
    [string[]]$NodeName = 'localhost',
    [string]$VhdPath
  )
  Import-DscResource -ModuleName xHyper-V
  Node $NodeName {
    xVMHyperV NanoVM {
      Ensure = 'Absent'
      Name = 'NanoVM'
      VhdPath = $VhdPath
      SwitchName = 'nat'
      State = 'Running'
      Generation = 1
      StartupMemory = 512MB
      ProcessorCount = 1
    }
    xVMSwitch nat {
      Ensure = 'Absent'
      Name = 'nat'
      Type = 'Internal'
      DependsOn = '[xVMHyperV]NanoVM'
    }
  }
}

RmVM -VhdPath 'C:/VM/NanoServerDataCenter.vhd'
