# Get Data via Txt file
$data = Get-Content ((split-path -parent $MyInvocation.MyCommand.Definition) + "\Trainers.txt")

# get trainers data and save to $trainers
$dictory = @() 
$trainers = @()

# read entire txt file
for ($i = 0; $i -lt $data.Length; $i++) {
    # read and split the row that have comma
    $rowData = $data[$i].Split(",")
    # if $rowData array has more than 1 element
    if (!($rowData.Length -eq 1)) {
        # Add the first row (Login Name,First Name,Last Name,Email,Telephone,HKID) to dictory array
        if ($dictory.Length -eq 0) {
            # remove space
            $rowData = $rowData.Replace(' ', '')
            # $rowData string array each string as $dict
            foreach ($dict in $rowData) {
                #  store $dict to $dictory
                $dictory += $dict
            }
  
        }
        else {
            # Add data associate the dictory
            # if the $rowData have same length with $dictory (Login Name,First Name,Last Name,Email,Telephone,HKID)
            if ($dictory.Length -eq $rowData.Length) {
                # reset trainer
                $trainer = $null
                
                
                for ($count = 0; $count -lt $dictory.Length; $count++) {
                    # combine $dictory (Login Name,First Name,Last Name,Email,Telephone,HKID) with value to $trainer
                    $trainer += @{$dictory[$count] = $rowData[$count] }
                }
                
                # add $trainer to trainers
                $trainers += $trainer

            }
            else {
                Write-Host "Data Row " + ($i + 1) + "Error" 
            }
        }
    }
}

try{
    # try to get the OnlineTrainer Group
    $adGroupTrainer = Get-ADGroup -Identity 'OnlineTrainer'

    # print OnlineTrainer is exist
    Write-Host $adGroupTrainer + 'is already exists'
}catch{
    # if the OnlineTrainer Group not exist create the OnlineTrainer Group
    New-ADGroup -Name "OnlineTrainer" -SamAccountName "OnlineTrainer" -GroupCategory Security -GroupScope Global -DisplayName "OnlineTrainer" -Path "CN=Users,DC=EndGame011 ,DC=com" -Description "OnlineTrainer"
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