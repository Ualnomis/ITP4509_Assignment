Import-module ActiveDirectory
Install-WindowsFeature -Name FS-Resource-Manager, RSAT-FSRM-Mgmt

#Create Home Folder Directory
$folderPath = "C:\DropAndPick"
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

New-SmbShare -Name "DropAndPick" -Path $folderPath -FullAccess "Authenticated Users"
$trainerAndTrainee = Get-ADUSER -filter 'Name -Like "*"'
foreach ($user in $trainerAndTrainee) {
    # Set-ADUser $user.Name -HomeDirectory "\\CENTRALSERVER\DropAndPick" -HomeDrive "G:"
}

# Copy-Item -Path ((split-path -parent $MyInvocation.MyCommand.Definition) + "\login.bat") -Destination \\CENTRALSERVER\NetLogon\ -PassThru
"net use G: \\CENTRALSERVER\DropAndPick" | Out-File \\CENTRALSERVER\NetLogon\login.bat -enc ascii
Get-ADUser -Filter * | Set-ADUser -ScriptPath "login.bat"

$allTrainers = Get-ADGroupMember -identity "OnlineTrainer" -Recursive 
foreach ($user in $allTrainers) {
    #Create User Home Folder
    $folderPath = "C:\DropAndPick\$($user.Name)"
    New-Item $folderPath -ItemType Directory

    #Set Permission
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

    Set-Acl $folderPath -AclObject $acl
    
    # $action = New-FsrmAction Event -EventType Information -Body "WARNING: You have only less than 2GB storage to use."
    # $Threshold = New-FsrmQuotaThreshold -Percentage 75 -Action $action
    # New-FsrmQuota -Path $folderPath -Size 8GB -Treshold $Threshold
    # New-FsrmQuotaTemplate -Name "HomeFolder_Quota" -Size 8GB -Threshold $Threshold
    New-FSRMQuota -Path $folderPath -Size 40GB
}