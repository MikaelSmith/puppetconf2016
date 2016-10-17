Configuration DockerNAT {
  param (
    [string[]]$NodeName = 'localhost',
    [string]$AdapterName
  )
  Import-DscResource -ModuleName xHyper-V
  Node $NodeName {
    xVMSwitch nat {
      Ensure = 'Present'
      Name = 'nat'
      Type = 'External'
      NetAdapterName = $AdapterName
      AllowManagementOS = $True
    }
  }
}

DockerNAT -AdapterName 'Ethernet0'
