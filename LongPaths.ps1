Configuration LongPaths {
  Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
  Registry RegistryExample
  {
    Ensure      = "Present"
    Key         = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Policies"
    ValueName   = "LongPathsEnabled"
    ValueData   = "1"
    ValueType   = "Dword"
  }
}
LongPaths
