
<#
.SYNOPSIS
Script to output Horizon Session data to .CSV via PowerCLI
	
.NOTES
  Version:        1.1
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  1/20/2021
  Purpose/Change: Updated for > 1,000 sessions and added Session Start Time

  Thanks to Wouter Kursten for the guidance on returning more than 1,000 objects in this article:
  https://www.retouw.nl/2017/12/12/get-hvmachine-only-finds-1000-desktops/

  Also thanks to feedback on code.vmware.com I added Session Start Time
  
 #>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$script:mydocs = [environment]::getfolderpath('mydocuments')
$script:date = Get-Date -Format d 
$script:date = $script:date -replace "/","_"
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function LogintoHorizon {

#Capture Login Information

$script:HorizonServer = Read-Host -Prompt 'Enter the Horizon Server Name'
$Username = Read-Host -Prompt 'Enter the Username'
$Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = read-host -Prompt 'Enter the Horizon Domain'

#Convert Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

try {
    
    $script:hvServer = Connect-HVServer -Server $horizonserver -User $username -Password $UnsecurePassword -Domain $domain -Force
    $script:hvServices = $hvServer.ExtensionData
    }

catch {
  Write-Host "An error occurred when logging on $_"
  break
}

write-host "Successfully Logged In"

} 

Function GetDisconnectedSessions {
    
    if ([string]::IsNullOrEmpty($hvServer))
    {
       write-host "You are not logged into Horizon"
        break   
       
    }
       
    try {
             
      $qSrv = New-Object "Vmware.Hv.QueryServiceService"
   
      #Support over 1000 sessions
      $offset = 0
      $qdef = New-Object VMware.Hv.QueryDefinition
      $qdef.limit= 1000
      $qdef.maxpagesize = 1000
      $qdef.queryEntityType = 'SessionLocalSummaryView'
      $qFilter = New-object VMware.Hv.QueryFilterEquals -property @{'memberName'='sessionData.sessionState';'value' = 'DISCONNECTED'}
      $qdef.Filter = $qFilter

      $ssessionoutput=@()
      
      do{
        $qdef.startingoffset = $offset
        $sResult = $qsrv.queryservice_create($hvServices, $qdef)
            if (($sResult.results).count -eq 1000)
                {
                $maxresults = 1
                }
            else 
                {
                $maxresults = 0
                }

        $offset+=1000
        $ssessionoutput+=$sResult
        }
      until ($maxresults -eq 0)
      
      #Cleanup the query
      $qsrv.QueryService_Delete($hvServices, $sresult.id)
                     
    }
    
    catch {
      Write-Host "An error occurred when getting sessions $_"
     break 
    }
    
  if ($ssessionoutput.results.count -eq 0)
   {
    write-host "No Disconnected Sessions"
    break   
   }
 
write-host "There are" $ssessionoutput.results.Count "disconnected sessions"
$tzone = Get-TimeZone 
write-host "Showing Session Start and Disconnect Times in" $tzone

#Write results to table
$ssessionoutput.Results | Format-table -AutoSize -Property @{Name = 'Session Start Time'; Expression = {[System.TimeZoneInfo]::ConvertTimeFromUtc($_.sessiondata.startTime,$tzone)}},@{Name = 'Session State'; Expression = {$_.sessiondata.sessionstate}},@{Name = 'Session Disconnect Time'; Expression = {[System.TimeZoneInfo]::ConvertTimeFromUtc($_.sessiondata.DisconnectTime,$tzone)}},@{Name = 'Username'; Expression = {$_.namesdata.username}},@{Name = 'Pool Name'; Expression = {$_.namesdata.desktopname}},@{Name = 'Machine Name'; Expression = {$_.namesdata.machineorrdsservername}}`

} 

Function GetDisconnectedSessionsOlderThan {
    
  if ([string]::IsNullOrEmpty($hvServer))
  {
     write-host "You are not logged into Horizon"
      break   
     
  }
     
  try {

    do 
    {   
      $sHours = Read-Host -Prompt 'Enter Number of Hours Disconnected'
    }
    until ($shours -ne "")

    $ts = New-TimeSpan -Hours $sHours
    $soldutctime = [System.DateTime]::UtcNow - $ts

    $qSrv = New-Object "Vmware.Hv.QueryServiceService"
 
    #Support over 1000 sessions
    $offset = 0
    $qdef = New-Object VMware.Hv.QueryDefinition
    $qdef.limit= 1000
    $qdef.maxpagesize = 1000
    $qdef.queryEntityType = 'SessionLocalSummaryView'
    $qFilter = New-object VMware.Hv.QueryFilterEquals -property @{'memberName'='sessionData.sessionState';'value' = 'DISCONNECTED'}
    $qdef.Filter = $qFilter

    $ssessionoutput=@()
    
    do{
      $qdef.startingoffset = $offset
      $sResult = $qsrv.queryservice_create($hvServices, $qdef)
          if (($sResult.results).count -eq 1000)
              {
              $maxresults = 1
              }
          else 
              {
              $maxresults = 0
              }

      $offset+=1000
      $ssessionoutput+=$sResult
      }
    until ($maxresults -eq 0)
    
    #Cleanup the query
    $qsrv.QueryService_Delete($hvServices, $sresult.id)
                   
  }
  
  catch {
    Write-Host "An error occurred when getting sessions $_"
   break 
  }
  
if ($ssessionoutput.results.count -eq 0)
 {
  write-host "No Disconnected Sessions"
  break   
 }

$tzone = Get-TimeZone 

$newsessions = @()

  foreach ($session in $ssessionoutput.results)
  {
    if ($session.sessiondata.DisconnectTime -ne "")
      {
        if ($session.sessiondata.DisconnectTime -lt $soldUTCtime)
        {
          $newsessions = $newsessions += $session
        }
      }
  }
  

if ($newsessions.count -eq 0)

{
  write-host "There are no sessions disconnected longer than" $sHours "hour(s)"
  break
}

write-host "There are" $newsessions.count "sessions disconnected longer than" $sHours "hour(s)"
write-host "Showing Session Start and Disconnect Times in" $tzone
#Write results to table
$newsessions | Format-table -AutoSize -Property @{Name = 'Session Start Time'; Expression = {[System.TimeZoneInfo]::ConvertTimeFromUtc($_.sessiondata.startTime,$tzone)}},@{Name = 'Session State'; Expression = {$_.sessiondata.sessionstate}},@{Name = 'Session Disconnect Time'; Expression = {[System.TimeZoneInfo]::ConvertTimeFromUtc($_.sessiondata.DisconnectTime,$tzone)}},@{Name = 'Username'; Expression = {$_.namesdata.username}},@{Name = 'Pool Name'; Expression = {$_.namesdata.desktopname}},@{Name = 'Machine Name'; Expression = {$_.namesdata.machineorrdsservername}}`

Write-Host "Press '1' to Logoff all sessions"
Write-Host "Press '2' to exit without making changes"
$selection = Read-Host "Please make a selection"

switch ($selection)
{

'1' {  

  foreach ($item in $newsessions) 
  
  {
     ForceLogoff_User($item)
  }

   
} 

'2' {

  break

}

}
}

function ForceLogoff_User {
 
  try {
             
   
     $script:hvServices.session.Session_LogoffForced($args[0].id)

    }        
           
    catch {
      Write-Host "An error occurred when Logging Off sessions $_"
     break 
    }

    write-host "Logged off session" $args[0].id.id
}

function Show-Menu
  {
    param (
          [string]$Title = 'VMware Horizon PowerCLI Menu'
          )
       Clear-Host
       Write-Host "================ $Title ================"
             
       Write-Host "Press '1' to Login to Horizon"
       Write-Host "Press '2' to Show All Disconnected Sessions"
       Write-Host "Press '3' to Show / Logoff Sessions Disconnected more than X Hours"
       Write-Host "Press 'Q' to quit."
         }

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    '1' {  

         LogintoHorizon
    } 
    
    '2' {
   
         GetDisconnectedSessions

    }
    
    '3' {
   
        GetDisconnectedSessionsOlderThan

 }

}
    pause
}
 
 until ($selection -eq 'q')




