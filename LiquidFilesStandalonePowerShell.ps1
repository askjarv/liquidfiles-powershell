<#
  .SYNOPSIS
	A set of PowerShell commandlets to interact with LiquidFiles to create file links
  .DESCRIPTION
    A set of PowerShell commandlets to interact with LiquidFiles to create file links
  .EXAMPLE
    $MyFileLink= Get-FileLinks -APIKey $apikey -Website $url
	Retrieves Existing FileLinks
  .EXAMPLE
   Set-FileLinkExpiry -APIKey $apikey -Website $url -ExpiryDate "2019-10-02" -file "Archive.zip"
   Updates an exsting file link's expiry date
  .EXAMPLE
   Upload-File-and-Email -APIKey $apikey -Website $url -File ".\TestDoc.docx" -EMailAddress "myuser@mydomain.com"
   Uploads a file and emails
  .EXAMPLE
    Upload-File-And-Link -APIKey $apikey -Website $url -File ".\TestDoc.docx" 
	Uploads a file and creates a new file link
  .NOTES
    You will need to create an API key via the liquidfiles GUI and set the $apikey and $url below appropriately.
	Owing to the use of the JSON API (easier, given PowerShell (except 6) doesn't support multipart forms yet) files are limited to 100MB!
#>
#Requires -Version 3.0
<#
=========================================
CHANGELOG:
=========================================
2019-09-25 - Chris Hudson - Initial release version
#>

# Title:     Tripwire Onboarding Email Notifcations
# Author:    Chris Hudson
# Version:   1.0


#
# WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, TRIPWIRE HAS NO OBLIGATION TO INDEMNIFY OR
# DEFEND RECIPIENT AGAINST CLAIMS RELATED TO INFRINGEMENT OF INTELLECTUAL PROPERTY RIGHTS.
# ----------------------------------------------------

#-------------------------------------------------------[Global Variables]---------------------------------------------------------
$apikey = 'YOUR API KEY HERE' # You should be able to get this from your Liquid Files login, under your user profile and the API tab!
$url ='https://liquidfiles.mydomain.com' # The base URL for your appliance - e.g. https://liquidfiles.mydomain.com
#-----------------------------------------------------------[Functions]------------------------------------------------------------
################# Liquid Files ######################
Function Get-FileLinks {
    param
    (
    [String]$APIKey,
    [String]$Website
    )
    $pass = ''
    $pair = "$($apikey):$($pass)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{'Authorization'=$basicAuthValue}
    $page = Invoke-WebRequest -Uri ($url+"/link") -Headers $headers -ContentType 'application/json' -Method Get -UseBasicParsing | ConvertFrom-Json
    $page
}

Function Set-FileLinkExpiry{
    param
    (
    [String]$APIKey,
    [String]$Website,
    [String]$ExpiryDate,
    [String]$File
    )
    $filetoextend = Get-FileLinks -APIKey $APIKey -Website $url
    $filetoextend = $filetoextend.links | where-object {$_.filename -eq $file}
    $filetoextendid = $filetoextend.id
    $expirydate = @{expires_at=$ExpiryDate} | ConvertTo-Json 
    $pass = ''
    $pair = "$($apikey):$($pass)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{'Authorization'=$basicAuthValue}
    $url = $url+"/link/"+$filetoextendid+"/update_expires_at"
    write-host "Applying change on $url"
    $page = Invoke-WebRequest  -Uri $url -Headers $headers -ContentType 'application/json' -Method Put -UseBasicParsing -Body $ExpiryDate | ConvertFrom-Json
    $page   
}

Function New-FileLink{
    param
    (
    [String]$APIKey,
    [String]$Website,
    [String]$File
    )
    $filetoextend = Get-FileLinks -APIKey $APIKey -Website $url
    $filetoextend = $filetoextend.links | where-object {$_.filename -eq $file}
    $filetoextendid = $filetoextend.id
    $expirydate = @{expires_at=$ExpiryDate} | ConvertTo-Json 
    $pass = ''
    $pair = "$($apikey):$($pass)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{'Authorization'=$basicAuthValue}
    $url = $url+"/link/"+$filetoextendid+"/update_expires_at"
    write-host "Applying change on $url"
    $page = Invoke-WebRequest  -Uri $url -Headers $headers -ContentType 'application/json' -Method Put -UseBasicParsing -Body $ExpiryDate | ConvertFrom-Json
    $page   
$json = @"
{"link":
  {
    "attachment":"fHbIuSIou38Txc0jVrobEp",
    "expires_at":"2017-01-01",
    "download_receipt":true,
    "require_authentication":true
  }
}
"@

}

Function Upload-File-and-Email{
    param
    (
    [String]$APIKey,
    [String]$Website,
    [String]$File,
    [String]$EMailAddress
    )

    # Need to create a binary object for this:
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($File))
$body = @"
{"message":
  {
    "recipients":["$EMailAddress"],
    "subject":"File Shared using Liquid Files",
    "message":"The files you requested",
    "expires_at":"2019-10-02",
    "send_email":true,
    "authorization":3,
    "attachments":[{
      "filename":"TestDoc.docx",
      "data":"$base64string"
    }]
  }
}
"@
    write-host $body
    $pass = ''
    $pair = "$($apikey):$($pass)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{'Authorization'=$basicAuthValue}
    $url = $url+"/message"
    Write-host $url
    Invoke-WebRequest -Uri $url -Headers $headers  -Method POST -Body $body -TimeoutSec 600 -ErrorAction Stop -ContentType "application/json"
}

Function Upload-File{
    param
    (
    [String]$APIKey,
    [String]$Website,
    [String]$File
    )

    # Need to create a binary object for this:
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($File))
    $body = @"
{"filelink":
  {

    "attachments":[{
       "filename":"TestDoc.docx",
       "data":"$base64string"
    }]
  }
}
"@
    write-host $body
    $pass = ''
    $pair = "$($apikey):$($pass)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{'Authorization'=$basicAuthValue}
    $url = $url+"/attachments"
    Write-host $url
    Invoke-WebRequest -Uri ($url+"/attachments/binary_upload.json?name="+$file+"&chunk=0&chunks=1") -Headers $headers  -Method POST -Body $body -TimeoutSec 600 -ErrorAction Stop -ContentType "application/json"
}
 # Upload-File -APIKey $apikey -Website $url -File ".\TestDoc.docx"  

Function Upload-File-And-Link{
    param
    (
    [String]$APIKey,
    [String]$Website,
    [String]$File,
    [String]$expirydate
    )
    If(!$expirydate){$expirydate = get-date -Format yyyy-MM-dd}
    # Need to create a binary object for this:
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($File))
    $body = @"
{"filelink":
  {

    "attachments":[{
       "filename":"TestDoc.docx",
       "data":"$base64string"
    }]
  }
}
"@
    write-host $body
    $pass = ''
    $pair = "$($apikey):$($pass)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{'Authorization'=$basicAuthValue}
    # Upload file
    $result = Invoke-WebRequest -Uri ($url+"/attachments/binary_upload.json?name="+$file+"&chunk=0&chunks=1") -Headers $headers  -Method POST -Body $body -TimeoutSec 600 -ErrorAction Stop -ContentType "application/json" | ConvertFrom-Json
    $attachmentid = $result.attachment.id
    # Create file link
    $body = @"
{"link":
  {
    "attachment":"$attachmentid",
    "expires_at":"$expirydate",
    "download_receipt":true,
    "require_authentication":true
  }
}
"@
    $result = Invoke-WebRequest -Uri ($url+"/link") -Headers $headers  -Method POST -Body $body -TimeoutSec 600 -ErrorAction Stop -ContentType "application/json" -Proxy http://127.0.0.1:8888 | ConvertFrom-Json
    write-debug $result.link.id
    write-debug $result.expires_at
    
    $result.link.url
}