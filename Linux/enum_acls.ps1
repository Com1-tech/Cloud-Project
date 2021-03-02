$directory = Get-ChildItem -Path C:\users\sysadmin.GOODCORP



foreach ($item in $directory) {
    
   
    Write-Output $Item | Get-Acl
     
 

    }