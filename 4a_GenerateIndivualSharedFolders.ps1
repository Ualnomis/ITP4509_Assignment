Install-WindowsFeature -Name FS-Resource-Manager, RSAT-FSRM-Mgmt

#Create Home Folder Directory
$folderPath = "C:\personal"
New-Item $folderPath -ItemType Directory

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

Set-Acl $folderPath -AclObject $acl

New-SmbShare -Name "Personal" -Path $folderPath -FullAccess "Authenticated Users"

#Create New Quota Template
$trainerAndTrainee = Get-ADUSER -filter 'Name -Like "*"'
foreach ($username in $trainerAndTrainee) { 
    Set-ADUser $username.Name -HomeDirectory "\\CENTRALSERVER\personal\$($username.Name)" -HomeDrive "F:"

    #Create User Home Folder
    $folderPath = "C:\personal\$($username.Name)"
    New-Item $folderPath -ItemType Directory

    #Set Permission
    $acl = Get-Acl $folderPath
    $acl.SetAccessRuleProtection($True, $False)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.SetAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit, ObjectInherit","None", "Allow" )
    $acl.AddAccessRule($ace)
    $ace = New-Object System.Security.AccessControl.FileSystemAccessRule(($username.Name), "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
    $acl.AddAccessRule($ace)

    Set-Acl $folderPath -AclObject $acl
    
    $action = New-FsrmAction Event -EventType Information -Body "WARNING: You have only less than 2GB storage to use."
    $Threshold = New-FsrmQuotaThreshold -Percentage 75 -Action $action
    New-FsrmQuota -Path $folderPath -Size 8GB -Threshold $Threshold
    #New-FsrmQuotaTemplate -Name "HomeFolder_Quota" -Size 8GB -Threshold $Threshold
}