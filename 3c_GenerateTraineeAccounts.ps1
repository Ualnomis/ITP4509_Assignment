# csv file path
$CsvPath = ((split-path -parent $MyInvocation.MyCommand.Definition) + "\StudentList2021.csv")
$trainees = Import-Csv -Path $CsvPath

# output the path
Write-Output $trainees

# loop throught each trainee in trainees
foreach ($trainee in $trainees) {
    # set trainee as Object
    $trainee = [Object]$trainee

    # check password
    if ($trainee.Password -match ".{8,}" -and $trainee.Password -match "[^a-zA-Z0-9]" -and $trainee.Password -match "\d" -and $trainee.Password -match "[a-zA-Z]" ) {
        New-ADUser -Name $trainee.LoginID -GivenName $trainee.FirstName -Surname $trainee.LastName -EmailAddress $trainee.Email -OfficePhone $trainee.Telephone -AccountPassword (ConvertTo-SecureString ($trainee.Password) -AsPlainText -Force) -Enabled $true -Description "Traniee" -ProfilePath "%LogonServer%\Profiles\%username%" -Path "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
        Add-ADGroupMember -Identity "Trainees" -Members $trainee.LoginID
    }
    else {
        # if not match
        Write-Host $trainee.LoginID + " password not meet requirement"
    }
}
