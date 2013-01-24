# VADAR - Vigilant Active Directory AuditoR

When run, this script will query Active Directory for all currently active user accounts.  If the Active Directory record doesn't have an email address, the script will print an error.

The script will then, query the BluePages API at http://bluepages.ibm.com/BpHttpApisv3/slaphapi with the account's email address.

If a BluePages account with the specified email address does not exist, the script will print an error.  If the email address is associated with more than one account, the script will print an error.

## Output
    [acline@cline vadar]$ ruby vadar.rb 
    No Email address in AD for CN=Administrator,OU=Service Accounts,DC=corp,DC=vivisimo,DC=com
    No active account in BluePages for email sharepointservice@vivisimo.com for user CN=SharePoint Administrator,CN=Managed Service Accounts,DC=corp,DC=vivisimo,DC=com

## To Do:
* Send an email to the BigData Lab SysAdmins

## Note
_The file 'env_vars.rb' contains the required AD bind credentials and is not tracked in git._

Created by Alex Cline
