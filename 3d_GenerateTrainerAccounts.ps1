# Get Data via Txt file
$data = Get-Content ((split-path -parent $MyInvocation.MyCommand.Definition) + "\Trainers.txt")

# get trainers data and save to $trainers
$dictory = @() 
$trainers = @()
for ($i = 0; $i -lt $data.Length; $i++) {
    $rowData = $data[$i].Split(",")
    if (!($rowData.Length -eq 1)) {
        # Add the first row to dictory array
        if ($dictory.Length -eq 0) {
            $rowData = $rowData.Replace(' ', '')
            foreach ($dict in $rowData) {
                $dictory += $dict
            }
  
        }
        else {
            # Add data associate the dictory
            if ($dictory.Length -eq $rowData.Length) {
                $trainer = $null
                for ($count = 0; $count -lt $dictory.Length; $count++) {
                    $trainer += @{$dictory[$count] = $rowData[$count] }
                }

                $trainers += $trainer

            }
            else {
                Write-Host "Data Row " + ($i + 1) + "Error" 
            }
        }
    }
}

# loop each trainees
foreach ($trainer in $trainers) {
    # set trainer as object
    $trainer = [Object]$trainer
    
    # default Password
    $defaultPwd = ($trainer.LastName).ToLower() + "$" + ($trainer.HKID).Substring(0, (($trainer.HKID).Length) - 3)

    # create ad user with the parameters in $trainer and set profile path to user
    New-ADUser -Name $trainer.LoginName -GivenName $trainer.FirstName -Surname $trainer.LastName -OfficePhone $trainer.Telephone -AccountPassword (ConvertTo-SecureString ($defaultPwd) -AsPlainText -Force) -Enabled $True -Description "Trainer" -ProfilePath "\\CENTRALSERVER\Profiles\$($trainer.LoginName)" -Path "OU=Trainers, OU=Workstation, DC=EndGame011 , DC=com"
    # set ad user trainer email address
    Set-ADUser -Identity $trainer.LoginName -EmailAddress $trainer.Email    
    
    # Add User to Group
    Add-ADGroupMember -Identity "OnlineTrainer" -Members $trainer.LoginName
}