Param
(
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $CAname,
    [Parameter(Mandatory=$true)]
    $country = "DE",
    [Parameter(Mandatory=$true)]
    $state = "Berlin",
    [Parameter(Mandatory=$true)]
    $city = "Berlin",
    [Parameter(Mandatory=$true)]
    $organisation = "Malzahn Consulting",
    [Parameter(Mandatory=$true)]
    $department = "Testlab",
    [Parameter(Mandatory=$true)]
    $email = "matthias@malzahn.kim"
)
openssl req -new `            -x509 `            -extensions v3_ca `            -keyout private/cakey.pem `            -out cacert.pem `            -days 3650 `            -config openssl.cnf `
            -subj $("/C=DE/ST=Berlin/L=Berlin/O=Malzahn Consulting/emailAddress=matthias@malzahn.kim/OU=" + $OrgName + "/CN="+$Hostname) `

openssl req -new `
            -nodes `
            -extensions SAN `
            -reqexts SAN `
            -out $('.\requests\' + $Hostname + '-req.pem') `
            -keyout $($hostpath.FullName + '\' + $Hostname + "-key.pem") `
            -config $($hostpath.FullName + "\openssl.cnf") `
            -subj $("/C=DE/ST=Berlin/L=Berlin/O=Malzahn Consulting/emailAddress=matthias@malzahn.kim/OU=" + $OrgName + "/CN="+$Hostname) `
            -batch

git add *git commit -m $('ADD Cert for ' + $Hostname)