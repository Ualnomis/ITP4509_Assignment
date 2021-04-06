$computers = get-adcomputer -filter 'name -like "EG-A*" -or name -like "EG-B*"' | Select-Object -ExpandProperty Name
$computerlist = $computers -join ","
$allTrainees = Get-ADGroupMember -identity "Trainees" -Recursive 

foreach($t in $allTrainees){
    Set-ADUser ($t.Name) -LogonWorkstations $computerList
}