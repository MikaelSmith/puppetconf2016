Configuration FullHost {
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
    xVMHyperV FullHost {
      Ensure = 'Present'
      Name = 'FullHost'
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

FullHost -VhdPath 'C:/VM/NanoFullVM.vhd'
