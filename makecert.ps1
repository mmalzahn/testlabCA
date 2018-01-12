Param
(
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $Hostname,
    $ip = "192.168.178.151",
    $OrgName = "Testlab"
)
$hostpath = New-Item -Path .\hostcerts -Name $Hostname -ItemType directory

$txt = "`n[SAN]`nsubjectAltName=DNS:" + $Hostname + ".fritz.box,DNS:" + $Hostname + ".mm.intra"

if($ip)
{
    $txt = $txt + ",IP:" + $ip
}

Copy-Item .\openssl.cnf $hostpath.FullName
Add-Content -Path $($hostpath.FullName + "\openssl.cnf") -Value $txt

openssl req -new `
            -nodes `
            -extensions SAN `
            -reqexts SAN `
            -out $('.\requests\' + $Hostname + '-req.pem') `
            -keyout $($hostpath.FullName + '\' + $Hostname + "-key.pem") `
            -config $($hostpath.FullName + "\openssl.cnf") `
            -subj $("/C=DE/ST=Berlin/L=Berlin/O=Malzahn Consulting/emailAddress=matthias@malzahn.kim/OU=" + $OrgName + "/CN="+$Hostname) `
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

Compress-Archive -Path $($certpath.FullName + '\*') `                 -DestinationPath $($hostpath.FullName + '\certpack.zip') `                 -CompressionLevel Optimalgit add *git commit -m $('ADD Cert for ' + $Hostname)