<#
    .SYNOPSIS
        T-Mon Website Monitoring

    .DESCRIPTION
        T-Mon Website monitoring performs the following checks:
            - Pull information from sql via configuration file variable that contains website url and piece of expected content from page
            - Get's currrent status on verified that content is being served.
              (I will add alert logic for content not found and status codes other an 200 in future releases)

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



#Load Variable Parameters
. E:\Documents\WindowsPowerShell\T-Mon\T-Mon_Configuration.ps1

foreach ($Website in $Websites)
{
    $Url = $Website.URL
    $Content = $Website.webContent
    $websiteStatus = Invoke-WebRequest -UseBasicParsing -Uri $Url
    $statusCode = $WebsiteStatus.StatusCode
    #$statusDescription = $WebsiteStatus.StatusDescription
    $webContent = ($WebsiteStatus.Content).Split('') -contains "$Content"

        if (Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "SELECT Website FROM cusWebStatus WHERE Website = '$Url'")
        {
            Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "UPDATE cusWebStatus SET Website='$Url', statusCode='$statusCode', contentFound='$webContent' WHERE Website = '$Url';"
        }
        else
        {
            Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $SQLDatabase -DisableVariables -Query "INSERT INTO cusWebStatus (Website,statusCode,contentFound) VALUES ('$Url','$statusCode','$webContent');" 
        }
    }
