# liquidfiles-powershell
PowerShell for creating file links on a LiquidFiles Appliance

## Description
A set of PowerShell commandlets to interact with LiquidFiles to create file links
You will need to create an API key via the liquidfiles GUI and set the $apikey and $url below appropriately.
Owing to the use of the JSON API (easier, given PowerShell (except 6) doesn't support multipart forms yet) files are limited to 100MB!

## Examples:
`$MyFileLink= Get-FileLinks -APIKey $apikey -Website $url`
Retrieves Existing FileLinks

`Set-FileLinkExpiry -APIKey $apikey -Website $url -ExpiryDate "2019-10-02" -file "Archive.zip"`
Updates an exsting file link's expiry date

`Upload-File-and-Email -APIKey $apikey -Website $url -File ".\TestDoc.docx" -EMailAddress "myuser@mydomain.com"`
Uploads a file and emails

`Upload-File-And-Link -APIKey $apikey -Website $url -File ".\TestDoc.docx"`
Uploads a file and creates a new file link
