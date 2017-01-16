#Load Variable Parameters
. .\InstallDir\T-Mon_Parameters.ps1

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
		Check-Hosts -assetList $assetList -SQLInstance $sqlInstance -SQLDatabase $sqlInstance

    .NOTES
        A workflow was used to take advantage of foreach parallel loops. Allows processing of several assets at once instead of one by one with a standard foreach loop.

        This is an early release. This will be updated soon to include alerting functoinality.
#>

Workflow Check-Services
    {
        param
            (
                [String[]]$assetList,
                [String]$sqlInstance,
                [String]$sqlDatabase 
            )


        foreach -parallel ($asset in $assetList)
            {
                $serviceInfo = Get-CimInstance -ClassName Win32_Service -ComputerName $asset | Select Name, DisplayName, StartMode, State, Status, ProcessID, ExitCode, PSComputerName

                foreach ($service in $serviceInfo)
                    {
                        $sName = $service.Name
                        $sDisplayName = $service.DisplayName
                        $sStartMode = $service.StartMode
                        $sState = $service.State
                        $sStatus = $service.Status
                        $sProcessID = $service.ProcessID
                        $sExitCode = $service.ExitCode
                        $sPSCompName = $Service.PSComputerName

                        if ((Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $sqlDatabase -DisableVariables -Query "select serviceName, PSComputerName from serviceList;") -eq "$sPSCompName")
                            {
                                Write-Output "Entry for this service already exists, updating informaton in assetServiceInfo table"
                                Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $sqlDatabase -DisableVariables -Query "update assetServiceInfo set Name='$sName', DisplayName='$sDisplayName', StartMode='$sStartMode', State='$sState', Status='$sStatus', ProcessID='$sProcessID', ExitCode='$sExitCode', PSComputerName='$sPSCompName' there Name = '$sName' and PSComputerName = '$sPSCompName';"
                            }

                        else
                            {
                                Write-Output "Entry for this service doesn't exist, inserting new entry in assetServiceInfo table"
                                Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $sqlDatabase -DisableVariables -Query "insert into assetServiceInfo (Name,DisplayName,StartMode,Status,ProcessID, ExitCode,PSComputerName) VALUES ('$sName','$sDisplayName','$sStartMode','$sState','$sStatus','$sProcessID','$sExitCode','$sPSCompName');"
                            }
                            
                    }
            }
                
    }


Get-CimInstance -ClassName Win32_Service -ComputerName $env:COMPUTERNAME | Select Name, DisplayName, StartMode, State, Status, ProcessID, ExitCode, PSComputerName



foreach ($Service in $ServiceList)
    {
        $Name = $Service.Name
        $PSComputerName = $Service.PSComputerName

        if ((Get-Service -Name $Name -ComputerName $PSComputerName).Status -eq "Stopped")
            {
                if (Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "SELECT ServiceName, PSComputername FROM ServiceList WHERE ServiceName = '$Name' -and PSComputerName = '$PSComputerName'")
                Write-Output "Updating Table: Service Still Down!"
                    Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "UPDATE AssetServiceInfo SET IsActive = '1' WHERE Name='$Name' and PSComputerName='$PSComputerName'"
            }
        ELSE
            {
                Write-Output "Updating Table: Issue Resolved!"
                    Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "UPDATE AssetServiceInfo SET IsActive = '0' WHERE Name = '$Name' and PSComputerName = '$PSComputerName'"
            }
    }