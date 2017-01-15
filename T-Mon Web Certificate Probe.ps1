<#
    .SYNOPSIS
        T-Mon Web Certificate Monitoring

    .DESCRIPTION
        T-Mon Web Certificate monitor performs the following checks:
            - Performs a get response request on the website to pull the certificate inforamtion
            - Verifies if the certificate is valid by ensuring that current date is past the begin date but before the expire date
              (I will add alert logic of 30 days, later on, this is just basic functionality at this time)

    .PARAMETER Website
        This parameter is set within the configuration file and contains data pulled of sql of monitored websites that should be checked

	.PARAMETER SQLInstance
        Parameter that allows the user to specify what sql instance to use for connection.

    .PARAMETER SQLDatabase
        Allows user to specify database on a specified instance to import the results to. Invoke-Sqlcmd use's the permissions of the user who executed the command to connect to the database.

    .EXAMPLE
        At this time there is no ability to pass values into variables. This will be a function in later releases, that will run from configuration file but also as a standalone function.

    .NOTES
        Script is in very early stages, will be updated soon.
#>



. E:\Documents\WindowsPowerShell\T-Mon\T-Mon_Configuration.ps1

foreach ($Website in $CertWebsites)
{
    $WebRequest = [Net.WebRequest]::Create("$Website")
    $Response = $WebRequest.GetResponse()
    $Certificate = [Security.Cryptography.X509Certificates.X509Certificate2]$WebRequest.ServicePoint.Certificate | Select NotAfter, NotBefore, ThumbPrint

    Write-Host "$Website"
    Write-Host "Certificate Valid From "$Certificate.NotBefore.ToShortDateString()" to "$Certificate.NotAfter.ToShortDateString()""

    If ((Get-Date -Format MM/dd/yyyy) -ge "$Certificate.NotBefore.ToShortDateString()" -and "$Certificate.NotAfter.ToShortDateString()" -le (Get-Date -Format MM/dd/yyyy))
    {
        Write-Host "Certificate is Valid!"
        $DaysLeft = New-TimeSpan -Start (Get-Date -Format MM/dd/yyyy) -End $Certificate.NotAfter.ToShortDateString() | Select -ExpandProperty Days
        $StartDate = $Certificate.NotBefore.ToShortDateString()
        $EndDate = $Certificate.NotAfter.ToShortDateString()

        Write-Host "Certificate Expires in $DaysLeft Days" -ForegroundColor Green
       

        Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -Query "UPDATE cuswebcertstatus SET StartDate='$StartDate', EndDate='$EndDate', DaysRemaining='$DaysLeft', CertificateValid='$true' WHERE URL = '$Website';"
    }

    else

    {
        Write-Host "Certificate is Not Valid!"
        $DaysLeft = New-TimeSpan -Start (Get-Date -Format MM/dd/yyyy) -End $Certificate.NotAfter.ToShortDateString() | Select -ExpandProperty Days
        Write-Host "Certificate Expires in $DaysLeft Days" -ForegroundColor Green
        Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -Query "UPDATE cuswebcertstatus SET StartDate='$StartDate', EndDate='$EndDate', DaysRemaining='$DaysLeft', CertificateValid='$false' WHERE URL = '$Website';"
    }

    Write-Output "-------------------------------------"

    $WebRequest.Abort()
}
