$packages_dir = 'C:\\NanoServer\\Packages'

$unattend = @("END")
<?xml version="1.0" encoding="utf-8"?>
    <unattend xmlns="urn:schemas-microsoft-com:unattend">
    <servicing>
        <package action="install">
            <assemblyIdentity name="Microsoft-NanoServer-IIS-Package" version="10.0.14393.0" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" />
            <source location="${packages_dir}\Microsoft-NanoServer-IIS-Package.cab" />
        </package>
        <package action="install">
            <assemblyIdentity name="Microsoft-NanoServer-IIS-Package" version="10.0.14393.0" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="en-US" />
            <source location="${packages_dir}\en-us\Microsoft-NanoServer-IIS-Package_en-us.cab" />
        </package>
    </servicing>
    <cpi:offlineImage cpi:source="" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>
END

$tempdir = 'C:/temp'

file { 'temp':
  ensure => directory,
  path => $tempdir,
}

file { 'iis unattend':
  ensure => file,
  content => $unattend,
  path => "$tempdir/unattend.xml",
}

# When puppetlabs-powershell is fixed, this should work.
exec { 'enable iis':
  command => "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command dism /online /apply-unattend:$tempdir/unattend.xml",
  unless => 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command & { if (dism /online /get-packages | Select-String -Pattern "Microsoft-NanoServer-IIS-Package") { exit 0 } else { exit 1 } }',
  notify => Service['w3svc'],
  require => File['iis unattend'],
}

service { 'w3svc':
  ensure => running,
}
