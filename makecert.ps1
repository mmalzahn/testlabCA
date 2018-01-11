Param
(
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $Hostname,
    $OrgName = "Testlab"
)
$hostpath = New-Item -Path .\hostcerts -Name $Hostname -ItemType directory

openssl req -new -nodes -out $('.\requests\' + $Hostname + '-req.pem') -keyout $($hostpath.FullName + '\' + $Hostname + "-key.pem") -config .\openssl.cnf -subj $("/C=DE/ST=Berlin/L=Berlin/O=Malzahn Consulting/OU=" + $OrgName + "/CN="+$Hostname) -batch
openssl ca -out $($hostpath.FullName + '\' + $Hostname + '-tmp.pem') -batch -config .\openssl.cnf -infiles $('.\requests\' + $Hostname + '-req.pem')
openssl x509 -in $($hostpath.FullName + '\' + $Hostname + '-tmp.pem') -out $($hostpath.FullName + '\' + $Hostname + ".pem")
Copy-Item .\cacert.pem $($hostpath.FullName + '\cacert.pem')
Remove-Item -Path $($hostpath.FullName + '\' + $Hostname + '-tmp.pem')
