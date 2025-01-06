
#Section 1
#######################
# Configure the variables below
#######################
# Remote SQL named instance using SQL server login
$RemoteSQLInstance = "SQLserver.constoso.com"
##############################################
# Invoke-SqlCmd is stupid and doesn't accept a SecureString password so Get-Credential won't work
# Must type password at a plaintext Read-Host prompt or convert back from SecureString if using SQL Login
##############################################
$UseSQLLogin = $FALSE
#$RemoteSQLUser = "AdminUser"
#$RemoteSQLPassword = ""


#Section 2
##############################################
# Checking to see if the SqlServer module is already installed, if not installing it for the current user
##############################################
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($null -eq $SQLModuleCheck) {
    write-host "SqlServer Module Not Found - Installing"
    # Not installed, trusting PS Gallery to remove prompt on install
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    # Installing module
    Install-Module -Name SqlServer –Scope CurrentUser -Confirm:$false -AllowClobber
}
##############################################
# Importing the SqlServer module
##############################################
Import-Module SqlServer


#Section 3
##############################################
# Creating SQL Query
##############################################
# Change this to whatever you want to test, but this is a good one to start with!
$SQLQuery = "SELECT *
            FROM IAMSVC.dbo.IdentityMgmt
            WHERE status = 'PENDING' or username = 'jsmith'"

# Running the SQL Query and outputting of the results for you to see
Invoke-SQL
"SQLInstance: $RemoteSQLInstance"
"SQLQueryResult: $SQLQuerySuccess"
"SQLQueryOutput:"
$SQLResult
$SQLResult | Export-Csv C:\temp\SQLExport.csv -Delimiter '|' -Force -NoTypeInformation


#Section 4
#Define SQL Query Function
function Invoke-SQL {
    # Running the SQL Query, setting result of query to $False if any errors caaught
    Try {
        # Setting to null first to prevent seeing previous query results
        $script:SQLResult = $null
        # Running the query
        If ($UseSQLLogin -eq $TRUE) {
            $script:SQLResult = Invoke-SqlCmd -Query $SQLQuery -ServerInstance $RemoteSQLInstance -Username $RemoteSQLUser -Password $RemoteSQLPassword
        }
        Else {
            $script:SQLResult = Invoke-SqlCmd -Query $SQLQuery -ServerInstance $RemoteSQLInstance -TrustServerCertificate
        }
        # Setting the query result
        $script:SQLQuerySuccess = $TRUE
    }
    Catch {
        # Overwriting result if it failed
        $script:SQLQuerySuccess = $FALSE
    }
    
}
