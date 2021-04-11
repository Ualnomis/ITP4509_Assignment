# set up path of the New-ADOrganizationalUnit
$ouWorstation = "OU=Workstation, DC=EndGame011, DC=com"
$ouTrainees = "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
$ouTrainers = "OU=Trainers, OU=Workstation, DC=EndGame011, DC=com"


# check if the path exist or not
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ouWorstation'") {
    Write-Host "$ouWorstation already exists."
}
else { # create if not exist
    New-ADOrganizationalUnit -Name "Workstation" -Path 'DC=EndGame011, DC=com'
}

# check if the path exist or not
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ouTrainees'") {
    Write-Host "$ouTrainees already exists."
}
else { # create if not exist
    New-ADOrganizationalUnit -Name 'Trainees' -Path 'OU=Workstation, DC=EndGame011, DC=com'
}

# check if the path exist or not
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ouTrainers'") {
    Write-Host "$ouTrainers already exists."
}
else { # create if not exist
    New-ADOrganizationalUnit -Name 'Trainers' -Path 'OU=Workstation, DC=EndGame011, DC=com'
}


# create trainees computer FROM EG-A01 to EG-A20
for ($i = 1; $i -le 20; $i++) {
    if ($i -lt 10) {
        $name = "EG-A0" + $i
    }
    else {
        $name = "EG-A" + $i
    }
    New-ADComputer -Name $name -SAMAccountName $name -PATH "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
    
}

# create trainees computer FROM EG-B01 to EG-B20
for ($i = 1; $i -le 20; $i++) {
    if ($i -lt 10) {
        $name = "EG-B0" + $i
    }
    else {
        $name = "EG-B" + $i
    }
    New-ADComputer -Name $name -SAMAccountName $name -PATH "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
    
}

# create trainers computer FROM FROM EG-T01 to EG-T02
for ($i = 1; $i -le 2; $i++) {
    $name = "EG-T0" + $i
    New-ADComputer -Name $name -SAMAccountName $name -PATH "OU=Trainers, OU=Workstation, DC=EndGame011, DC=com"
    
}

# display all created adcomputer start with EG
get-adcomputer -filter 'Name -Like "EG*"'