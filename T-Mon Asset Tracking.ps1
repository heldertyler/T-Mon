<#
    .SYNOPSIS
        T-Mon Asset Tracking

    .DESCRIPTION
        Probe used to collect data from assets. Collects things like hardware, os, software, configuration inforamtion and stores in SQL 

    .PARAMETER Assets
        This parameter all you to specify a string or array of strings to run the checks against. You could pull from a SQL asset table or csv and then feed into workflow.
        Will pull this from the configuration file in future releases

	.PARAMETER SQLInstance
        Parameter that allows the user to specify what sql instance to use for connection.

    .PARAMETER SQLDatabase
        Allows user to specify database on a specified instance to import the results to. Invoke-Sqlcmd use's the permissions of the user who executed the command to connect to the database.

    .EXAMPLE


    .NOTES
        In furture releases this will be turned into a fuction that will run against assetList table in SQL as well as on the fly for one of runs
#>

. E:\Documents\WindowsPowerShell\T-Mon\T-Mon_Configuration.ps1

Import-Module SQLPS

$Asset = Import-Csv -Path "C:\Temp\Test.csv" -Delimiter ","
$SQLInstance = "$env:COMPUTERNAME\SQLEXPRESS"
$ExcludedServices = @()

#Get System Info
$AssetGeneralInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Computer | Select Name, Domain, Model, Manufacturer, PSComputerName

foreach ($General in $AssetGeneralInfo)
    {
        $sys1 = $General.Name
        $sys2 = $General.Domain
        $sys3 = $General.Model
        $sys4 = $General.Manufacturer
        $sys5 = $General.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT Name, PSComputerName FROM AssetGeneralInfo WHERE Name = '$sys1' and PSComputerName = '$sys5';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetGeneralInfo SET Name='$sys1', Domain='$sys2', Model='$sys3', Manufacturer='$sys4', PSComputerName='$sys5' WHERE Name = '$sys1' and PSComputerName = '$sys5';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetGeneralInfo (Name,Domain,Model,Manufacturer,PSComputerName) VALUES ('$sys1','$sys2','$sys3','$sys4','$sys5');"
            }
    }

#Get BIOS Related Information
$AssetBiosInfo = Get-CimInstance -ClassName Win32_Bios -ComputerName $Computer | Select Manufacturer, PrimaryBIOS, Version, SerialNumber, ReleaseDate, PSComputerName, Status 

foreach ($Bios in $AssetBiosInfo)
    {
        $bios1 = $Bios.Manufacturer
        $bios2 = $Bios.PrimaryBIOS
        $bios3 = $Bios.Version
        $bios4 = $Bios.SerialNumber
        $bios5 = $Bios.ReleaseDate
        $bios6 = $Bios.Status
        $bios7 = $Bios.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT PrimaryBIOS, PSComputerName FROM AssetBiosInfo WHERE PrimaryBIOS = '$bios2' and PSComputerName = '$bios7';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetBiosInfo SET Manufacturer='$bios1', PrimaryBIOS='$bios2', Version='$bios3', SerialNumber='$bios4', ReleaseDate='$bios5', Status='$bios6', PSComputerName='$bios7' WHERE PrimaryBIOS = '$bios2' and PSComputerName = '$bios7';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetBiosInfo (Manufacturer,PrimaryBIOS,Version,SerialNumber,ReleaseDate,Status,PSComputerName) VALUES ('$bios1','$bios2','$bios3','$bios4','$bios5','$bios6','$bios7');"
            }
    }

#Get Operating System Related Information
$AssetOSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Computer | Select Caption, CSDVersion, OSArchitecture, OSLanguage, PSComputerName

foreach ($OS in $AssetOSInfo)
    {
        $os1 = $OS.Caption
        $os2 = $OS.CSDVersion
        $os3 = $OS.OSArchitecture
        $os4 = $OS.OSLanguage
        $os5 = $OS.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT Caption, PSComputerName FROM AssetOSInfo WHERE Caption = '$os1' and PSComputerName = '$os5';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetOSInfo SET Caption='$os1', CSDVersion='$os2', OSArchitecture='$os3', OSLanguage='$os4', PSComputerName='$os5' WHERE Caption = '$os1' and PSComputerName = '$os5';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetOSInfo (Caption,CSDVersion,OSArchitecture,OSLanguage,PSComputerName) VALUES ('$os1','$os2','$os3','$os4','$os5');"
            }
    }

#Get Time Zone Information
$AssetTimeZoneInfo = Get-CimInstance -ClassName Win32_TimeZone -ComputerName $Computer | Select StandardName, PSComputerName

foreach ($TimeZone in $AssetTimeZoneInfo)
    {
        $timezone1 = $TimeZone.StandardName
        $timezone2 = $TimeZone.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT Name, PSComputerName FROM AssetTimeZoneInfo WHERE Name = '$timezone1' and PSComputerName = '$timezone2';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetTimeZoneInfo SET Name='$timezone1', PSComputerName='$timezone2' WHERE Name = '$timezone1' and PSComputerName = '$timezone2';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetTimeZoneInfo (Name,PSComputerName) VALUES ('$timezone1','$timezone2');"
            }
    }

#Get Disk space Related Information
$AssetPartitionInfo = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $Computer -Filter "DriveType=3" | Select DeviceID, @{Name="Size";Expression={[Math]::Round($_.Size / 1GB)}},@{Name="FreeSpace";Expression={[Math]::Round($_.FreeSpace/1GB)}}, @{Name="PercentFree";Expression={[Math]::Round(($_.FreeSpace / $_.Size) * 100, 2)}}, PSComputerName

foreach ($Partition in $AssetPartitionInfo)
    {
        $diskspace1 = $Partition.DeviceID
        $diskspace2 = $Partition.Size
        $diskspace3 = $Partition.FreeSpace
        $diskspace4 = $Partition.PercentFree
        $diskspace5 = $Partition.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT DeviceID, PSComputerName FROM AssetPartitionInfo WHERE DeviceID = '$diskspace1' and PSComputerName = '$diskspace5';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetPartitionInfo SET DeviceID='$diskspace1', Size='$diskspace2', FreeSpace='$diskspace3', PercentFree='$diskspace4', PSComputerName='$diskspace5' WHERE DeviceID = '$diskspace1' and PSComputerName = '$diskspace5';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetPartitionInfo (DeviceID,Size,FreeSpace,PercentFree,PSComputerName) VALUES ('$diskspace1','$diskspace2','$diskspace3','$diskspace4','$diskspace5');"
            }
    }

#Get Windows Update Information
$AssetWinUpdateInfo = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $Computer -Property InstalledOn | Sort InstalledOn -Descending | Select InstalledOn, PSComputerName -First 1

foreach ($WinUpdate in $AssetWinUpdateInfo)
    {
        $winupdate1 = $AssetWinUpdateInfo.InstalledOn
        $winupdate2 = $AssetWinUpdateInfo.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT LastInstallDate, PSComputerName FROM AssetWinUpdateInfo WHERE LastInstallDate = '$winupdate1' and PSComputerName = '$winupdate2';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetWinUpdateInfo SET LastInstallDate='$winupdate1', PSComputerName='$winupdate2' WHERE LastInstallDate = '$winupdate1' and PSComputerName = '$winupdate2';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetWinUpdateInfo (LastInstallDate,PSComputerName) VALUES ('$winupdate1','$winupdate2');"
            }
    }

#Gets Processor Related Information
$AssetCPUInfo = Get-CimInstance -ClassName Win32_Processor -ComputerName $env:COMPUTERNAME | Select DeviceID, Name, NumberOfCores, NumberOfLogicalProcessors, CurrentClockSpeed, MaxClockSpeed, PSComputerName, Status

foreach ($Cpu in $AssetCPUInfo)
    {
        $cpu1 = $Cpu.DeviceID
        $cpu2 = $Cpu.Name
        $cpu3 = $Cpu.NumberOfCores
        $cpu4 = $Cpu.NumberOfLogicalProcessors
        $cpu5 = $Cpu.CurrentClockSpeed
        $cpu6 = $Cpu.MaxClockSpeed
        $cpu7 = $Cpu.Status
        $cpu8 = $Cpu.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT DeviceID, PSComputerName FROM AssetCPUInfo WHERE DeviceID = '$cpu1' and PSComputerName = '$cpu8';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetCPUInfo SET DeviceID='$cpu1', Name='$cpu2', NumberOfCores='$cpu3', NumberOfLogicalProcessors='$cpu4', CurrentClockSpeed='$cpu5', MaxClockSpeed='$cpu6', Status='$cpu7', PSComputerName='$cpu8' WHERE DeviceID = '$cpu1' and PSComputerName = '$cpu8';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetCPUInfo (DeviceID,Name,NumberOfCores,NumberOfLogicalProcessors,CurrentClockSpeed,MaxClockSpeed,Status,PSComputerName) VALUES ('$cpu1','$cpu2','$cpu3','$cpu4','$cpu5','$cpu6','$cpu7','$cpu8');"
            }
    }

#Get Memory Information
$AssetMemoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $Computer | Select Manufacturer, PartNumber, SerialNumber, @{Name="Capacity";Expression={[Math]::Round($_.Capacity / 1GB)}}, Speed, DeviceLocator, PSComputerName

foreach ($Memory in $AssetMemoryInfo)
    {
        $mem1 = $Memory.Manufacturer
        $mem2 = $Memory.PartNumber
        $mem3 = $Memory.SerialNumber
        $mem4 = $Memory.Capacity
        $mem5 = $Memory.Speed
        $mem6 = $Memory.DeviceLocator
        $mem7 = $Memory.PSComputerName
        
        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT SerialNumber, PSComputerName FROM AssetMemoryInfo WHERE SerialNumber = '$mem3' and PSComputerName = '$mem7';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetMemoryInfo SET Manufacturer='$mem1', PartNumber='$mem2', SerialNumber='$mem3', Capacity='$mem4', Speed='$mem5', DeviceLocator='$mem6', PSComputerName='$mem7' WHERE SerialNumber = '$mem3' and PSComputerName = '$mem7';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetMemoryInfo (Manufacturer,PartNumber,SerialNumber,Capacity,Speed,DeviceLocator,PSComputerName) VALUES ('$mem1','$mem2','$mem3','$mem4','$mem5','$mem6','$mem7');"
            }
    }

#Motherboard Related Information
$AssetMotherBoardInfo = Get-CimInstance -ClassName Win32_MotherBoardDevice -ComputerName $Computer | Select Caption, PnPDeviceID, PSComputerName, Status

foreach ($motherboard in $AssetMotherBoardInfo)
    {
        $montherboard1 = $motherboard.Caption
        $montherboard2 = $motherboard.PnPDeviceID
        $montherboard3 = $motherboard.Status
        $montherboard4 = $motherboard.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT PnPDeviceID, PSComputerName FROM AssetMotherBoardInfo WHERE PnPDeviceID = '$montherboard2' and PSComputerName = '$montherboard4';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetMotherBoardInfo SET Caption='$montherboard1', PnPDeviceID='$montherboard2', Status='$montherboard3', PSComputerName='$montherboard4' WHERE PnPDeviceID = '$montherboard2' and PSComputerName = '$montherboard4';"                
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetMotherBoardInfo (Caption,PnPDeviceID,Status,PSComputerName) VALUES ('$montherboard1','$montherboard2','$montherboard3','$montherboard4');"
            }
    }

#Hard Drive Information
$AssetHardDriveInfo = Get-CimInstance -ClassName Win32_DiskDrive -ComputerName $Computer | Select Caption, DeviceID, SerialNumber, FirmwareRevision, PSComputerName, Status
    
    foreach ($HardDrive in $AssetHardDriveInfo)
        {
            $hdd1 = $HardDrive.Caption
            $hdd2 = $HardDrive.DeviceID
            $hdd3 = $HardDrive.SerialNumber
            $hdd4 = $HardDrive.FirmwareRevision
            $hdd5 = $HardDrive.Status
            $hdd6 = $HardDrive.PSComputerName

            if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT SerialNumber, PSComputerName FROM AssetHardDriveInfo WHERE SerialNumber = '$hdd3' and PSComputerName = '$hdd5';")
                {
                    Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetServiceInfo SET Caption='$hdd1', DeviceID='$hdd2', SerialNumber='$hdd3', FirmwareRevision='$hdd4', Status='$hdd5', PSComputerName='$hdd6' WHERE SerialNumber = '$hdd3' and PSComputerName = '$hdd6';"
                }
            ELSE
                {
                    Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetHardDriveInfo (Caption,DeviceID,SerialNumber,FirmwareRevision,Status,PSComputerName) VALUES ('$hdd1','$hdd2','$hdd3','$hdd4','$hdd5','$hdd6');"   
                }
        }

#Non-Working Devices
$AssetNonDeviceInfo = Get-CimInstance -ClassName Win32_PnpEntity -ComputerName $Computer | Where {$_.ConfigManagerErrorCode -ne "0"} | Select Name, DeviceID, ConfigManagerErrorCode, PSComputerName


foreach ($nondevice in $AssetNonDeviceInfo)
    {
        $nondevice1 = $nondevice.Name
        $nondevice2 = $nondevice.DeviceID
        $nondevice3 = $nondevice.ConfigManagerErrorCode
        $nondevice4 = $nondevice.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT Name, PSComputerName FROM AssetNonDeviceInfo WHERE Name = '$nondevice1' and PSComputerName = '$nondevice4';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetNonDeviceInfo SET Name='$nondevice1', DeviceID='$nondevice2', ConfigManagerErrorCode='$nondevice3', PSComputerName='$nondevice4' WHERE Name = '$nondevice1' and PSComputerName = '$nondevice4';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetNonDeviceInfo (Name,DeviceID,ConfigManagerErrorCode,PSComputerName) VALUES ('$nondevice1','$nondevice2','$nondevice3','$nondevice4');"
            }
    }

#Database Information
$AssetDBInfo = Get-SqlDatabase -ServerInstance $Computer\SQLEXPRESS | Select Name, Status, Parent

foreach ($Database in $AssetDBInfo)
    {
        $db1 = $Database.Name
        $db2 = $Database.Status
        $db3 = $Database.Parent

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT Name, PSComputerName FROM AssetDBInfo WHERE Name = '$db1' and PSComputerName = '$db3';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetDBInfo SET Name='$db1', Status='$db2', PSComputerName='$db3' WHERE Name = '$db1' and PSComputerName = '$db3';"
            }
        ELSE
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetDBInfo (Name,Status,PSComputerName) VALUES ('$db1','$db2','$db3');" 
            }
    }

#Service Information
$AssetServiceInfo = Get-CimInstance -ClassName Win32_Service -ComputerName $Computer | Select DisplayName, Name, StartMode, PSComputerName, State | Where {$_.StartMode -eq "Auto" -and $_.State -ne "Running" -and $_.Name -notin $ExcluedServices}

foreach ($Service in $AssetServiceInfo)
    {
        $service1 = $Service.DisplayName
        $service2 = $Service.Name
        $service3 = $Service.StartMode
        $service4 = $Service.State
        $service5 = $Service.PSComputerName

        if (Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "SELECT Name, PSComputerName FROM AssetServiceInfo WHERE Name = '$Service2' and PSComputerName = '$Service5';")
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "UPDATE AssetServiceInfo SET DisplayName='$Service1', Name='$Service2', StartMode='$Service3', State='$Service4', PSComputerName='$Service5' WHERE Name = '$Service2' and PSComputerName = '$Service5';"
            }
        Else
            {
                Invoke-Sqlcmd -ServerInstance "$tmondb" -Database tmon -DisableVariables -Query "INSERT INTO AssetServiceInfo (DisplayName,Name,StartMode,State,PSComputerName) VALUES ('$service1','$service2','$service3','$service4','$service5');"

            }
    }



#Event Information
$EventLogs = @()
$EventLogs += Get-EventLog -LogName Application -ComputerName $Computer | Where {$_.EntryType -eq "Error"} | Select EventID, MachineName, EntryType, Message, Source, TimeGenerated, TimeWritten, UserName -First 10
$EventLogs += Get-EventLog -LogName System -ComputerName $Computer | Where {$_.EntryType -eq "Error"} | Select EventID, MachineName, EntryType, Message, Source, TimeGenerated, TimeWritten, UserName -First 10
$EventLogs += Get-EventLog -LogName Security -ComputerName $Computer | Where {$_.EntryType -eq "FailureAudit"} | Select EventID, MachineName, EntryType, Message, Source, TimeGenerated, TimeWritten, UserName -First 10