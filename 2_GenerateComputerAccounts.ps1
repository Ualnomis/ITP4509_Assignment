$ouWorstation = "OU=Workstation, DC=EndGame011, DC=com"
$ouTrainees = "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
$ouTrainers = "OU=Trainers, OU=Workstation, DC=EndGame011, DC=com"
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ouWorstation'") {
    Write-Host "$ouWorstation already exists."
}
else {
    New-ADOrganizationalUnit -Name "Workstation" -Path 'DC=EndGame011, DC=com'
}

if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ouTrainees'") {
    Write-Host "$ouTrainees already exists."
}
else {
    New-ADOrganizationalUnit -Name 'Trainees' -Path 'OU=Workstation, DC=EndGame011, DC=com'
}

if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ouTrainers'") {
    Write-Host "$ouTrainers already exists."
}
else {
    New-ADOrganizationalUnit -Name 'Trainers' -Path 'OU=Workstation, DC=EndGame011, DC=com'
}

try{
    $adGroupTrainer = Get-ADGroup -Identity 'OnlineTrainer'
    Write-Host $adGroupTrainer + 'is already exists'
}catch{
    New-ADGroup -Name "OnlineTrainer" -SamAccountName "OnlineTrainer" -GroupCategory Security -GroupScope Global -DisplayName "OnlineTrainer" -Path "CN=Users,DC=EndGame011 ,DC=com" -Description "OnlineTrainer"
}
try{
    $adGroupTrainees = Get-ADGroup -Identity 'Trainees'
    Write-Host $adGroupTrainees + 'is already exists'
}catch{
    New-ADGroup -Name "Trainees" -SamAccountName "Trainees" -GroupCategory Security -GroupScope Global -DisplayName "Trainees" -Path "CN=Users,DC=EndGame011 ,DC=com" -Description "Trainees"
}

# create trainees computer
for ($i = 1; $i -le 20; $i++) {
    if ($i -lt 10) {
        $name = "EG-A0" + $i
    }
    else {
        $name = "EG-A" + $i
    }
    New-ADComputer -Name $name -SAMAccountName $name -PATH "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
    
}

# create trainees computer
for ($i = 1; $i -le 20; $i++) {
    if ($i -lt 10) {
        $name = "EG-B0" + $i
    }
    else {
        $name = "EG-B" + $i
    }
    New-ADComputer -Name $name -SAMAccountName $name -PATH "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
    
}

# create trainers computer
for ($i = 1; $i -le 2; $i++) {
    $name = "EG-T0" + $i
    New-ADComputer -Name $name -SAMAccountName $name -PATH "OU=Trainers, OU=Workstation, DC=EndGame011, DC=com"
    
}

# display all created adcomputer start with EG
get-adcomputer -filter 'Name -Like "EG*"'