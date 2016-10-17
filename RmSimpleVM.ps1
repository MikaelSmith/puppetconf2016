Configuration RmSimpleVM {
  param (
    [string[]]$NodeName = 'localhost',
    [string]$VhdPath
  )
  Import-DscResource -ModuleName xHyper-V
  Node $NodeName {
    xVMHyperV SimpleVM {
      Ensure = 'Absent'
      Name = 'SimpleVM'
      VhdPath = $VhdPath
      SwitchName = 'internal'
      State = 'Running'
      Generation = 1
      StartupMemory = 512MB
      ProcessorCount = 1
    }
    xVMSwitch internal {
      Ensure = 'Absent'
      Name = 'internal'
      Type = 'Internal'
      DependsOn = '[xVMHyperV]SimpleVM'
    }
  }
}

RmSimpleVM -VhdPath 'C:/VM/NanoServerDataCenter.vhd'
