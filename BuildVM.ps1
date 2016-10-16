Configuration BuildVM {
  param (
    [string[]]$NodeName = 'localhost',
    [string]$VhdPath
  )
  Import-DscResource -ModuleName xHyper-V
  Node $NodeName {
    xVMSwitch nat {
      Ensure = 'Present'
      Name = 'nat'
      Type = 'Internal'
    }
    xVMHyperV NanoVM {
      Ensure = 'Present'
      Name = 'NanoVM'
      VhdPath = $VhdPath
      SwitchName = 'nat'
      State = 'Running'
      Generation = 1
      StartupMemory = 512MB
      ProcessorCount = 1
      DependsOn = '[xVMSwitch]nat'
    }
  }
}

BuildVM -VhdPath 'C:/VM/NanoServerDataCenter.vhd'
