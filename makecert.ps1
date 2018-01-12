Param
(
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $Hostname,
    $IPs = @(),
    [Parameter(Mandatory=$true)]
    $country = "DE",
    [Parameter(Mandatory=$true)]
    $state,
    [Parameter(Mandatory=$true)]
    $city,
    [Parameter(Mandatory=$true)]
    $organisation,
    [Parameter(Mandatory=$true)]
    $department,
    [Parameter(Mandatory=$true)]
    $email,
    $dnsprefix = @()
)
$hostpath = New-Item -Path .\hostcerts -Name $Hostname -ItemType directory

if(($IPs.count -gt 0) -or ($dnsprefix.count -gt 0))
{
    $txt = "`n[SAN]`nsubjectAltName="
    $firstrun = $true

    foreach ($pref in $dnsprefix)
    {
        if(-not $firstrun)
        {
            $txt +=','
        }

        $txt += 'DNS:' + $Hostname + '.' + $pref
    }

    foreach ($ip in $IPs)
    {
        if(-not $firstrun)
        {
            $txt +=','
        }

        $txt += 'IP:' + $ip
    }
}


Copy-Item .\openssl.cnf $hostpath.FullName
Add-Content -Path $($hostpath.FullName + "\openssl.cnf") -Value $txt

$subjStr = "/C=" + $country + `           "/ST="+$state + `           "/L=" + $city + `           "/O="+ $organisation + `           "/emailAddress="+ $email +`           "/OU=" + $department + `           "/CN="+$Hostname

openssl req -new `
            -nodes `
            -extensions SAN `
            -reqexts SAN `
            -out $('.\requests\' + $Hostname + '-req.pem') `
            -keyout $($hostpath.FullName + '\' + $Hostname + "-key.pem") `
            -config $($hostpath.FullName + "\openssl.cnf") `
            -subj $subjStr `
            -batch

openssl ca -out $($hostpath.FullName + '\' + $Hostname + '-tmp.pem') `
            -batch `
            -extensions SAN `
            -config $($hostpath.FullName + "\openssl.cnf") `
            -infiles $('.\requests\' + $Hostname + '-req.pem')

openssl x509 -in $($hostpath.FullName + '\' + $Hostname + '-tmp.pem') `             -out $($hostpath.FullName + '\' + $Hostname + ".pem")

Remove-Item -Path $($hostpath.FullName + '\' + $Hostname + '-tmp.pem')
#Move-Item $('openssl-'+$hostname+'.cnf') $($hostpath.FullName + '\openssl-'+$hostname+'.cnf')

$certpath = New-Item -Path $hostpath.FullName -Name certpack -ItemType directory
Copy-Item -Path $($hostpath.FullName + '\' + $Hostname + ".pem") -Destination $($certpath.FullName + '\cert.pem')
Copy-Item .\cacert.pem $($certpath.FullName + '\cacert.pem')
Copy-Item -Path $($hostpath.FullName + '\' + $Hostname + "-key.pem") -Destination $($certpath.FullName + '\key.pem')

Compress-Archive -Path $($certpath.FullName + '\*') `                 -DestinationPath $('clientpacks\'+$Hostname+'.zip') `                 -CompressionLevel Optimal