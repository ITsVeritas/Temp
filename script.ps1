# Import Modules
Check-LoadedModule ActiveDirectory

# Set Date Variables #
$FormatDate = Get-Date -Format dd-MM-yyyy
$Date = (Get-Date).AddDays(-30)

# Set $ErrorActionPreference to SilentlyContinue to bypass Get-ADUser Errors
$ErrorActionPreference = "SilentlyContinue"

# Import all VHD(X) files into $VHDs variable
$VHDs = Get-ChildItem -Recurse -Path \\contoso.com\share\CTXProfiles\Win10Profiles\FSLogix | Where-Object {$_.Name -like "*.vhdx"} | Select-Object Name,Length,FullName,CreationTime,LastWriteTime

# Run through the loop and report on the activity of the FSLogix profiles
ForEach($VHD in $VHDs){ 
    If($VHD.LastWriteTime -lt $Date){
        $VHDLWT = Get-Date $VHD.LastWriteTime -Format "dd-MM-yyyy"
        $VHDCT = Get-Date $VHD.CreationTime -Format "dd-MM-yyyy"
        $Username = ($VHD.Name).Split('_')[1] | ForEach{$_.SubString(0,$_.length-5)}
        $Profile = ($VHD.Length | Measure-Object -Sum).Sum /1GB | Out-String
        $ProfileSize = $Profile | ForEach{$_.SubString(0,$_.Length-8)<#+"GB"#>}
        $UserDetails = Get-ADUser -Identity $Username -Properties DisplayName,Mail | Select SamAccountName,DisplayName,Mail -ErrorAction SilentlyContinue
        $Report = New-Object PSObject # Creates a Custom Report #
        $Report | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $UserDetails.DisplayName
        $Report | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $UserDetails.SamAccountName
        $Report | Add-Member -MemberType NoteProperty -Name "Email" -Value $UserDetails.Mail
        $Report | Add-Member -MemberType NoteProperty -Name "ProfileName" -Value $VHD.Name
        $Report | Add-Member -MemberType NoteProperty -Name "ProfileSize(GB)" -Value $ProfileSize
        $Report | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $VHDCT
        $Report | Add-Member -MemberType NoteProperty -Name "LastWriteTime" -Value $VHDLWT
        $Report | Add-Member -MemberType NoteProperty -Name "ProfilePath" -Value $VHD.FullName
        $Report | Export-Csv -Append -NoTypeInformation ('\\contoso.com\share\CTXProfiles\Inactive_FSLogix_Profiles_Report_'+$FormatDate+'.csv')
        Remove-Item -Path $VHD.FullName -Force -Confirm:$false
    }
}

# Calculate utilized space
$TotalSize = (($csv | Measure-Object 'ProfileSize' -Sum).Sum).ToString($_)+"GB"
$csv = Import-Csv ('\\contoso.com\share\CTXProfiles\Inactive_FSLogix_Profiles_Report_'+$FormatDate+'.csv')


# Build Email
$Recipient = "Administrators@contoso.com"
$Sender = "FSLogix_Alerts@contoso.com"
$SMTP = "0.0.0.0"
$Subject = ('FSLogix Inactive Profile Report for '+$FormatDate)
$Attachment = ('\\contoso.com\share\CTXProfiles\Inactive_FSLogix_Profiles_Report_'+$FormatDate+'.csv')
$Body = 
('To Administrator,
 
Attached, please find the Inactive FSLogix Profiles Report for '+$FormatDate+'. This report contains a list of FSLogix Profiles that have not been accessed for 30 or more days.
 
PLEASE DO NOT REPLY TO THIS EMAIL.
 
Regards,
EUC Engineering')
Send-MailMessage -To $Recipient -From $Sender -Subject $Subject -Body $Body -Attachments $Attachment -SmtpServer $SMTP

# Check if Modules are loaded and if not, load them
function Check-LoadedModule
{
  Param( [parameter(Mandatory = $true)][alias("Module")][string]$ModuleName)
  $LoadedModules = Get-Module | Select Name
  if (!$LoadedModules -like "*$ModuleName*") {Import-Module -Name $ModuleName}
}
