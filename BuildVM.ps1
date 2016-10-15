Configuration SetupVM {
  param (
    [string]$VhdPath,
    [string]$DriveLetter
  )
  Import-DscResource -ModuleName xStorage
  xMountImage VHD {
    Ensure = 'Present'
    Name = 'NanoServerDataCenter.vhd'
    ImagePath = $VhdPath
    DriveLetter = $DriveLetter
  }
}

Configuration BuildVM {
  param (
    [string[]]$NodeName = 'localhost',
    [string]$VhdPath,
    [string]$DriveLetter
  )
  Import-DscResource -ModuleName xStorage
  xMountImage VHD {
    Ensure = 'Absent'
    Name = 'NanoServerDataCenter.vhd'
    ImagePath = $VhdPath
    DriveLetter = $DriveLetter
  }

  Import-DscResource –ModuleName xHyper-V
  Node $NodeName {
    xVMSwitch nat {
      Ensure = 'Present'
      Name = 'nat'
      Type = 'Internal'
    }
    xVMHyperV NanoVM {
      Ensure = 'Present'
      Name = 'NanoVM'
      DependsOn = '[xVMSwitch]nat'
      VhdPath = $VhdPath
      SwitchName = 'nat'
      State = 'Running'
      Generation = 1
      StartupMemory = 1GB
      ProcessorCount = 1
    }
  }
}

$VhdPath = 'C:/Windows Server 2016 DataCenter Nano VHD/NanoServerDataCenter.vhd'
$DriveLetter = 's:'
SetupVM -VhdPath $VhdPath -DriveLetter $DriveLetter
#BuildVM -VhdPath $VhdPath -DriveLetter $DriveLetter
