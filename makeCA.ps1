﻿Param
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
    $email,
    [Parameter(Mandatory=$false)]
    $removePassword = $false
)
$subjStr = "/C=" + $country + `

openssl req -new `
            -subj $subjStr

if($removePassword)
{
openssl rsa -in private/cakey.pem `