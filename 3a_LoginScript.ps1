# get all Trainees AD computer name
$computers = get-adcomputer -filter 'name -like "EG-A*" -or name -like "EG-B*"' | Select-Object -ExpandProperty Name

# combine computer names with comma
$computerlist = $computers -join ","

# select all trainees account
$allTrainees = Get-ADGroupMember -identity "Trainees" -Recursive 

# for each trainees account
foreach($t in $allTrainees){
    # set trainee only can login into the computer name in $computerList
    Set-ADUser ($t.Name) -LogonWorkstations $computerList
}