# T-Mon
A PowerShell Based Monitoring System with Microsoft SQL Backend


#Purpose
T-Mon is agentless monitoring system utilizing a Series of PowerShell scripts to collect data on devices or services and stores the collected data in Microsoft SQL database (Express (for small instances), Standard (for mid instances), and Enterprise (for Mass Deployments).

#Requirements
T-Mon requires a server with Microsoft SQL installed with capacity for another database and at least one applicaiton server that will execute the scripts. For smaller instances, the scripts and database could run on the same server.

#Scope
The scope of this project is the following:
  - A script that is used as a configuration file that the other scripts utilize. Think of a linux style configuration file for PowerShell, the scripts will dot source variables from this file and each script will utilize the data.
  - A script for Asset Discovery to Discover Devices on a given subnet(s). This script will also establish an asset list in SQL that other scripts in this project will utilize for monitoring extended services
  - A script for basic server availability monitoring (Is the Device Up or Down). Based on this data other scripts in this project will stop checking until the device is up again.
  - A script gathering server details (Make, Model, Serial Number, OS Info, Disk utilization, Timezone (useful in environments that haven't standardized on a specific time zone), etc...)
  - A script that monitors services across servers and alerts when a critical service goes down
  - A script that monitors running processes and when a critical process is no longer running and alert is generated
  - A script that monitors files for changes over a set period and alerts when the file hasn't been updated within the threshold
  - A script that monitors websites. Get's the current http status code, and also based on specified content on the page, the page is checked to verify that the expected content is being served indicating that the web server is up and serving data to clients
  - A script that checks website certificates and generates an alerts 30's prior to expiration
  - A script that performs specified actions on an FTP, FTPS, or FTPES server and verifies that the commands and results expected actually occurr without failure.
  - A script to get SNMP data from servers, printers, switches, routers, firewalls, and storage applicances
  
  
 More probes and checks may be added over time. Suggestions are welcome!
  

#Notes
This project is in very early stages, however, changes and updates will happen on a frequent basis. This readme will be updated as new features are added.
