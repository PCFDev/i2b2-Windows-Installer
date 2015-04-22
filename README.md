#I2B2 Windows Installer
Scripts to automate installing I2B2 in a windows environment

## Getting Started ##
To use this installer a few things need to be in place before you begin.

1. You must have a windows server with internet connectivity
2. PowerShell 4.0 or higher must be installed on the server
3. You must be able to connect to a MSSQL server with an account that is a member of the sysadmin server role from the windows server

Once your server is ready follow these steps:

1. Click the **Download ZIP** button on the right of this page
2. Extract the zip on the windows server
3. Edit the **config-i2b2.ps1** file and set values for the following variables:
	1. **DEFAULT\_DB\_SERVER**
	2. **DEFAULT\_DB\_ADMIN\_USER**
	3. **DEFAULT\_DB\_ADMIN\_PASS**
4. Open PowerShell as an Administrator
5. Navigate to the folder the zip extracted to and  run: **.\install.ps1** 


##Current Progress ##
Current Features:

1. Install Prereqs
  * Java
  * Ant
  * JBOSS
  * JBOSS Service
  * IIS
  * PHP
2. I2B2 Data Installation
  * Create Databases (SQL Server Only)
  * Create Users (SQL Server Only)
  * Grant Permissions (SQL Server Only)
  * Run I2B2 Data Installation Creatation Scripts
  * Run I2B2 Demo Data Load Scripts
3. I2B2 Cell Installation
4. I2B2 Admin Tool Installation
5. I2B2 Web Client Installation


##Future Enhancements##


----------

If you are interested in contributing to the cause please feel free to contact us : appdev ( at ) kids.wustl.edu


----------