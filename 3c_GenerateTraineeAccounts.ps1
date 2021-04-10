# csv file path
# (split-path -parent $MyInvocation.MyCommand.Definition) is current script path
$CsvPath = ((split-path -parent $MyInvocation.MyCommand.Definition) + "\StudentList2021.csv")

# import csv from $CsvPath to $trainees
$trainees = Import-Csv -Path $CsvPath

# output the path
Write-Output $trainees

# loop each trainee in trainees
foreach ($trainee in $trainees) {
    # set trainee as Object
    $trainee = [Object]$trainee

    # check The password need to follow the policy of minimum 8 characters with at least 1 numeric and 1 special character. 
    if ($trainee.Password -match ".{8,}" -and $trainee.Password -match "[^a-zA-Z0-9]" -and $trainee.Password -match "\d" -and $trainee.Password -match "[a-zA-Z]" ) {
	# create ad user with the parameters in $trainee
        New-ADUser -Name $trainee.LoginID -GivenName $trainee.FirstName -Surname $trainee.LastName -EmailAddress $trainee.Email -OfficePhone $trainee.Telephone -AccountPassword (ConvertTo-SecureString ($trainee.Password) -AsPlainText -Force) -Enabled $true -Description "Trainee" -ProfilePath "%LogonServer%\Profiles\%username%" -Path "OU=Trainees, OU=Workstation, DC=EndGame011, DC=com"
        # Add User to ADGroup "Trainees"
        Add-ADGroupMember -Identity "Trainees" -Members $trainee.LoginID
    }
    else {
        # if not match
        Write-Host $trainee.LoginID + " password not meet requirement"
    }
}
