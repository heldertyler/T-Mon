<#
    .SYNOPSIS
        T-Mon Port Monitoring

    .DESCRIPTION
        Probe used to check common ports are open. Eventually this will store the data in a sql table and the data may be used in other probes for discovering services to scan 

    .PARAMETER Port
        Specify a port or several ports to check against. Depending on your firewall rules, if they are very strict, this may or may not be useful

	.PARAMETER SQLInstance
        Parameter that allows the user to specify what sql instance to use for connection.

    .PARAMETER SQLDatabase
        Allows user to specify database on a specified instance to import the results to. Invoke-Sqlcmd use's the permissions of the user who executed the command to connect to the database.

    .EXAMPLE


    .NOTES
        In furture releases this will be turned into a fuction that will run against assetList table in SQL as well as on the fly for one of runs.
        Logic will also be added for in-depth checks for certain services if found to be open as well as storing all data in SQL

        This one is very early stages
#>


. E:\Documents\WindowsPowerShell\T-Mon\T-Mon_Configuration.ps1

$Ports = @('20','21','23','25','53','80','109','110','161','162','389','443','515','567','990','1433','3389')
$Computers = @('192.168.1.117')
$ErrorActionPreference = 'SilentlyContinue'

foreach ($Computer in $Computers)
{
    foreach ($Port in $Ports)
    {
        $Socket = New-Object Net.Sockets.TcpClient
        $Socket.Connect("$Computer","$Port")

        if ($Socket.Connected) 
        {
            Write-Host "$Computer : $Port is Open"
                $Socket.Close()
        }

        else
        {
            Write-Host "$Computer : $Port is Closed or Filtered"
                $Socket.Close()
        }


    $Socket.Dispose()

    }
}