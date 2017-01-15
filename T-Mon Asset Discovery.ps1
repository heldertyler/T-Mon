<#
    .SYNOPSIS
        T-Mon E-Discovery Probe

    .DESCRIPTION
        T-Mon E-Discovery probe iterates through ip addresses and performs the following checks:
            - Runs a ping check against the IP to determine if there is a device associated with the IP address
            - Examines the time to live vaule on the ping to make an attempt in identifing the operating system (Windows, Mac, Linux). Note that devices like
              switches, routers, firewalls, printers, etc... will more then likely detect as linux
            - DNS lookup to determine the devices hostname
            - The host name, ip address, and operating system are stored in a sql table. This table is used as an asset list throughout other modules

    .PARAMETER IPRange
        IP Range is a list of ip addresses to run the checks against. At this time only /24 (255.255.255.0) are supported. For other subnets you would need to break them up.
        Example: 192.168.100.1/22 would have to be processed as 192.168.100.1/24, 192.168.101.1/24, and 192.168.102.1/24
        This will be fixed in later versions of this module. At the moment this is just basic functionallity

	.PARAMETER SQLInstance
        Parameter that allows the user to specify what sql instance to use for connection.

    .PARAMETER SQLDatabase
        Allows user to specify database on a specified instance to import the results to. Invoke-Sqlcmd use's the permissions of the user who executed the command to connect to the database.

    .EXAMPLE
        The assets parameter accepts a string or array of strings
		Start-AssetEDiscovery -IPRange $IPRange -SQLInstance $SQLInstance -SQLDatabase $SQLDatabase

    .NOTES
        A workflow was used to take advantage of foreach parallel loops. Allows processing of several assets at once instead of one by one with a standard foreach loop.
#>


. SomeDrive:\SomePath\T-Mon_Configuration.ps1

$FirstThreeOctets = $Subnets.FirstThreeOctets
$FirstIP = $Subnets.FirstIP
$LastIP = $Subnets.LastIP

$IPRange = ($FirstIP..$LastIP | % {"$FirstThreeOctets.$_"}).Replace(' ','')

Workflow Start-AssetEDiscovery
{
    param
        (
            [String[]]$IPRange,
            [String]$SQLInstance,
            [String]$SQLDatabase      
        )

    foreach -parallel ($IP in $IPRange) 
        {
            $TimeToLive = Test-Connection -ComputerName $IP -Count 1 -ErrorAction SilentlyContinue | Select -ExpandProperty ResponseTimeToLive

            if ($TimeToLive)
            {
                $Hostname = Resolve-DnsName $IP | Select -ExpandProperty NameHost -ErrorAction SilentlyContinue

                if ($TimeToLive -le 64)
                    {
                        #Devices that will Shows as linux: MAcbooks, iPhones, Kindles, FreeBSD, Linux (Redhat, debian, ubunutu, etc...), Google's Customized Linux
                        Write-Output "Linux" 
                        $OperatingSystem = 'Linux'
                    }

                elseif ($TimeToLive -le 128)
                    {
                        #Devices that will show as Windows: Windows XP or better
                        Write-Output "Windows"
                        $OperatingSystem = 'Windows'
                    }

                elseif ($TimeToLive -eq 255)
                    {
                        #Devices that may show as Linux: HP Printers, Cisco IOS 11+ devices
                        Write-Output "Linux"
                        $OperatingSystem = 'Linux'
                    }

                Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "INSERT INTO Asset_List (PSComputerName,ipAddress,operatingSystem) VALUES ('$Hostname','$IP','$operatingSystem')"
            }
        }
}


Start-AssetEDiscovery -IPRange $IPRange -SQLInstance $SQLInstance -SQLDatabase $SQLDatabase