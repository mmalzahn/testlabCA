Param
(
    [Parameter(Mandatory=$true)]
    $CAname,
    [Parameter(Mandatory=$true)]
    $country,
    [Parameter(Mandatory=$true)]
    $state,
    [Parameter(Mandatory=$true)]
    $city,
    [Parameter(Mandatory=$true)]
    $organisation,
    [Parameter(Mandatory=$true)]
    $department,
    [Parameter(Mandatory=$false)]
    $email
)
$subjStr = "/C=" + $country + `           "/ST="+$state + `           "/L=" + $city + `           "/O="+ $organisation + `           "/emailAddress="+ $email +`           "/OU=" + $department + `           "/CN=" + $CAname

openssl req -new `            -x509 `            -extensions v3_ca `            -keyout private/cakey.pem `            -out cacert.pem `            -days 3650 `            -config openssl.cnf `
            -subj $subjStr