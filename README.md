# T-Mon
A PowerShell Based Monitoring System with Microsoft SQL Backend


#Purpose
T-Mon is agentless monitoring system utilizing a Series of PowerShell scripts to collect data on devices or services and stores the collected data in Microsoft SQL database (Express (for small instances), Standard (for mid instances), and Enterprise (for Mass Deployments).

#Requirements
T-Mon requires a Microsoft SQL server with capacity for another database and at least one applicaiton server that will execute the scripts.

#Scope
The scope of this project is the following:
  - A Script for Asset Discovery to Discover Devices on a given subnet(s). This script will also establish an asset list in SQL that other scripts in this project will utilize for monitoring extended services
  - A Script for basic server availability monitoring (Is the Device Up or Down). Based on this data other scripts in this project will stop checking until the device is up again.
  - A script gathering server details (Make, Model, Serial Number, OS Info, Disk utilization, Timezone (useful in environments that haven't standardized on a specific time zone), etc...)
  - A Script that monitors services across servers and alerts when a critical service goes down
  - A Scrpit that monitors running processes and when a critical process is no longer running and alert is generated
  - A Script that monitors files for changes over a set period and alerts when the file hasn't been updated within the threshold
  - A Script that monitors websites. Get's the current http status code, and also based on specified content on the page, the page is checked to verify that the expected content is being served indicating that the web server is up and serving data to clients
  - A script that checks website certificates and generates an alerts 30's prior to expiration
  - A script that performs specified actions on an FTP, FTPS, or FTPES server and verifies that the commands and results expected actually occurr without failure.
  - A script to get SNMP data from servers, printers, switches, routers, firewalls, and storage applicances
  
  
 More probes and checks may be added over time. Suggestions are welcome!
  

#Notes
This project is in very early stages, however, changes and updates will happen on a frequent basis. This readme will be updated as new features are added.
