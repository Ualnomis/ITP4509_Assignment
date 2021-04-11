Install-WindowsFeature -Name FS-Resource-Manager, RSAT-FSRM-Mgmt

#Create Home Folder Directory
$folderPath = "C:\personal"
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

# apply permission
Set-Acl $folderPath -AclObject $acl

# share to network
New-SmbShare -Name "Personal" -Path $folderPath -FullAccess "Authenticated Users"

# get all trainer And Trainee
$trainerAndTrainee = Get-ADGroupMember "Trainees"
$trainerAndTrainee += Get-ADGroupMember "OnlineTrainer"

foreach ($user in $trainerAndTrainee) { 
    # The shared folder is automatically mapped as F: drive after the user login
    Set-ADUser $user.Name -HomeDirectory "\\CENTRALSERVER\personal\$($user.Name)" -HomeDrive "F:"

    #Create User Home Folder
    $folderPath = "C:\personal\$($user.Name)"
    New-Item $folderPath -ItemType Directory

    #Set Permission
    $acl = Get-Acl $folderPath
    $acl.SetAccessRuleProtection($True, $False)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.SetAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit, ObjectInherit","None", "Allow" )
    $acl.AddAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule(($user.Name), "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.AddAccessRule($ace)

    # apply permission
    Set-Acl $folderPath -AclObject $acl
    
    # each user will have a quota of 8GB at a warning level of 6GB.
    $action = New-FsrmAction Event -EventType Information -Body "WARNING: You have only less than 2GB storage to use."
    $Threshold = New-FsrmQuotaThreshold -Percentage 75 -Action $action
    New-FsrmQuota -Path $folderPath -Size 8GB -Threshold $Threshold
}