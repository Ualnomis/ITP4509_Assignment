# set the profiles folder path
$folderPath = "C:\Profiles"
# create the folder to $folderPath
New-Item $folderPath -ItemType Directory

# set file system access rules
$acl = Get-Acl $folderPath
$acl.SetAccessRuleProtection($True, $False)

# set permission
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
$acl.SetAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow" )
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","ContainerInherit","None","Allow")
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","ObjectInherit","None","Allow")
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("Trainees", "ReadData,AppendData", "None", "None", "Allow" )
$acl.AddAccessRule($ace)
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule("OnlineTrainer", "ReadData,AppendData", "None", "None", "Allow" )
$acl.AddAccessRule($ace)

# apply permission
Set-Acl $folderPath -AclObject $acl

# share to network
New-SmbShare -Name "Profiles" -Path $folderPath -FullAccess "Authenticated Users"