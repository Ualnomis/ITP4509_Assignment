Import-module ActiveDirectory
Install-WindowsFeature -Name FS-Resource-Manager, RSAT-FSRM-Mgmt

#Create Home Folder Directory
$folderPath = "C:\DropAndPick"
New-Item $folderPath -ItemType Directory

# set permission
$acl = Get-Acl $folderPath
$acl.SetAccessRuleProtection($True, $False)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
$acl.SetAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "None", "None", "Allow" )
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Trainees", "ReadData", "None", "None", "Allow" )
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("OnlineTrainer", "ReadData", "None", "None", "Allow" )
$acl.AddAccessRule($ace)

# apply permission folder
Set-Acl $folderPath -AclObject $acl

# share to newwork
New-SmbShare -Name "DropAndPick" -Path $folderPath -FullAccess "Authenticated Users"

# get ad user
$trainerAndTrainee = Get-ADUSER -filter 'Name -Like "*"'
foreach ($user in $trainerAndTrainee) {
    # Set-ADUser $user.Name -HomeDirectory "\\CENTRALSERVER\DropAndPick" -HomeDrive "G:"
}

# create a bat to map G: drive
"net use G: \\CENTRALSERVER\DropAndPick" | Out-File \\CENTRALSERVER\NetLogon\login.bat -enc ascii
# set user login script to map G: drive
Get-ADUser -Filter * | Set-ADUser -ScriptPath "login.bat"

# Get all user in OnlineTrainer Group
$allTrainers = Get-ADGroupMember -identity "OnlineTrainer" -Recursive 
foreach ($user in $allTrainers) {
    #Create User Home Folder
    $folderPath = "C:\DropAndPick\$($user.Name)"
    New-Item $folderPath -ItemType Directory

    # Set Permission
    $acl = Get-Acl $folderPath
    $acl.SetAccessRuleProtection($True, $False)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.SetAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "None", "None", "Allow" )
    $acl.AddAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule($user.Name, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.AddAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Trainees", "ListDirectory, CreateDirectories, CreateFiles", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.AddAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("OnlineTrainer", "ListDirectory, CreateDirectories, CreateFiles", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.AddAccessRule($ace)

    # apply permission setting
    Set-Acl $folderPath -AclObject $acl
    
    # set Quota for the folder
    New-FSRMQuota -Path $folderPath -Size 40GB
}