. E:\Documents\WindowsPowerShell\T-Mon\T-Mon_Configuration.ps1

<#
    .SYNOPSIS
        Availability monitoring workflow

    .DESCRIPTION
        T-Mon Availability Monitoring Checks a Specified Asset(s) if they are up or down and updates a SQL table with the information. 

    .PARAMETER Assets
        This parameter all you to specify a string or array of strings to run the checks against. You could pull from a SQL asset table or csv and then feed into workflow.

	.PARAMETER SQLInstance
        Parameter that allows the user to specify what sql instance to use for connection.

    .PARAMETER SQLDatabase
        Allows user to specify database on a specified instance to import the results to. Invoke-Sqlcmd use's the permissions of the user who executed the command to connect to the database.

    .EXAMPLE
        The assets parameter accepts a string or array of strings
		Check-Hosts -Assets $Assets -SQLInstance $SQLInstance -SQLDatabase $SQLDatabase

    .NOTES
        A workflow was used to take advantage of foreach parallel loops. Allows processing of several assets at once instead of one by one with a standard foreach loop.
#>


Workflow Check-HostStatus
    {
        param
            (
                [String[]]$Assets,
                [String]$SQLInstance,
                [String]$SQLDatabase 
            )

        foreach -parallel ($Asset in $Assets)
            {
                if (Test-Connection -ComputerName $Asset -Count 2 -ErrorAction SilentlyContinue)
                    {
                        Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -Query "UPDATE assetList SET Status = '1' WHERE IP_Address = '$Asset'"
                    }
                else
                    {
                        Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -Query "UPDATE assetList SET Status = '0' WHERE IP_Address = '$Asset'"
                    }
            }
    }


Check-Hosts -Assets $Assets -SQLInstance $SQLInstance -SQLDatabase $SQLDatabase