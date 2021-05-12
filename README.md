# Logoff-Horizon-Sessions-Disconnected-Longer-Than
Show and Logoff Horizon Sessions Disconnected longer than hours specified.

***<u>There is no support for this tool - it is provided as-is</u>***

Please provide any feedback directly to me - my contact information: 

Chris Halstead - Staff Architect, VMware  
Email: chalstead@vmware.com  
Twitter: @chrisdhalstead  <br />

Thanks to Wouter Kursten for the feedback on supporting over 1,000 sessions.  <br/>

The code to support that is based off of his post here:  https://www.retouw.nl/2017/12/12/get-hvmachine-only-finds-1000-desktops/ <br/>

 This script requires Horizon 7 PowerCLI - https://blogs.vmware.com/euc/2020/01/vmware-horizon-7-powercli.html <br/>

Updated May 12, 2021<br />

------

### Script Overview

This is a PowerShell script that uses PowerCLI and the View-API to query Horizon sessions.  The script will show all disconnected sessions, or sessions that have been disconnected longer than specified hours.  You can then logoff those sessions.  Also, all logon and disconnect time are shown in the local time zone.

### Script Usage

Run `Horizon-Logoff-Disconnected-Sessions.ps1` 


   ![Menu](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/mainmenu.PNG)

   #### Login to Horizon Connection Server

Choose **1** to Login to a Horizon Connection Server 

- Enter the FQDN of the server when prompted to "Enter the Horizon Server Name" hit enter

- Enter the Username of an account with Administrative access to the Horizon Server you are connecting to when prompted to "Enter the Username" hit enter

- Enter that users Password and click enter

- Enter that users Domain and click enter

  You will see that you are now logged in to Horizon - click enter to go back to the menu

   ![Login](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/Login.PNG)

#### Show all Disconnected Sessions

Choose **2** to return all Disconnected Horizon Sessions.  The logon and disconnect time will be shown in the local time zone where the script is run.

   ![Sessions](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/disconnected.PNG)

#### Show / Logoff Sessions Disconnected more than X Hours

Choose **3** to return all Sessions Disconnected longer than the number of hours you specify.  You will be prompted to enter the number of hours - this will show all sessions that have been disconnected longer than the number of hours you specify.  In this example we will choose 8 hours.

   ![Sessions](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/disconnectedhours.PNG)

   ![Sessions](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/disconnectedsessions.PNG)

You will now be presented with a menu to **1** Logoff all sessions or **2** to do nothing and return to previous menu.

   ![Sessions](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/disc_menu.PNG)

Choose to Logoff the sessions and they are logged off immediately.

   ![Sessions](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/logoff.PNG)

We can now see that there are no sessions that have been disconnected over 8 hours.

   ![Sessions](https://github.com/chrisdhalstead/logoff-horizon-sessions-disconnected-longer-than/blob/main/Images/no_disc.PNG)