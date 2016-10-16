Configuration SimpleVM {
  param (
    [string[]]$NodeName = 'localhost',
    [string]$VhdPath
  )
  Import-DscResource -ModuleName xHyper-V
  Node $NodeName {
    xVMSwitch internal {
      Ensure = 'Present'
      Name = 'internal'
      Type = 'Internal'
    }
    xVMHyperV SimpleVM {
      Ensure = 'Present'
      Name = 'SimpleVM'
      VhdPath = $VhdPath
      SwitchName = 'internal'
      State = 'Running'
      Generation = 1
      StartupMemory = 512MB
      ProcessorCount = 1
      DependsOn = '[xVMSwitch]internal'
    }
  }
}

SimpleVM -VhdPath 'C:/VM/NanoServerDataCenter.vhd'
