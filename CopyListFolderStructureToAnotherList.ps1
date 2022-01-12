function Get-folders()
{
param (

    [Parameter(Mandatory=$true,Position=0)]
    $Folders,
    [Parameter(Mandatory=$true,Position=1)]
    [string]$OriginalLibrary,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$DestinationLibrary
    )

    $Host.Runspace.ThreadOptions = “ReuseThread”
    $ll2=$ctx.Web.Lists.GetByTitle($DestinationLibrary.Replace("/",""))
    
    foreach($folder in $folders)
    {
        $ctx.Load($folder.Folders)
        $ctx.ExecuteQuery()
        #Write-host $folder.ServerRelativeUrl $folder.folders.count

        if($folder.ServerRelativeUrl -match $OriginalLibrary)
        {
            $urel= $folder.ServerRelativeUrl.Replace($OriginalLibrary,$DestinationLibrary)
            Write-Host $urel
            $newFolder=$ll2.RootFolder.Folders.Add($folder.ServerRelativeUrl.Replace($OriginalLibrary,$DestinationLibrary))
            $ctx.Load($newFolder)
            $ctx.ExecuteQuery()
        }


        if($folder.Folders.Count -gt 0)
        {
            Get-folders -Folders $folder.Folders -OriginalLibrary $OriginalLibrary -DestinationLibrary $DestinationLibrary
        }

    }
}



function Get-Webfolders()
{
param (

    [Parameter(Mandatory=$true,Position=0)]
    [string]$OriginalLibrary,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$DestinationLibrary

)

    $Host.Runspace.ThreadOptions = “ReuseThread”

    $OriginalList=$ctx.Web.Lists.GetByTitle($OriginalLibrary)
    $DestinationList=$ctx.Web.Lists.GetByTitle($DestinationLibrary)

    $folderCollection=$OriginalList.RootFolder.Folders
    $ctx.load($OriginalList)
    $ctx.Load($folderCollection)
    $ctx.ExecuteQuery()
    $OriginalLibrary="/"+$OriginalLibrary+"/"
    $DestinationLibrary="/"+$DestinationLibrary+"/"
    
    foreach($fodler in $folderCollection)
    {

        $ctx.Load($fodler.Folders)
        $ctx.ExecuteQuery()
        #Write-host $fodler.ServerRelativeUrl $fodler.folders.count

        if($fodler.ServerRelativeUrl -match $OriginalLibrary)
        {
            $urel= $fodler.ServerRelativeUrl.Replace($OriginalLibrary,$DestinationLibrary)
            Write-Host $urel
            $newFolder=$ll2.RootFolder.Folders.Add($fodler.ServerRelativeUrl.Replace($OriginalLibrary,$DestinationLibrary))
            $ctx.Load($newFolder)
            $ctx.ExecuteQuery()
        }



        if($fodler.Folders.Count -gt 0){
        Get-folders -folders $fodler.Folders -OriginalLibrary $OriginalLibrary -DestinationLibrary $DestinationLibrary
        }
    }
}


function Connect-SPO()
{

param (

    [Parameter(Mandatory=$true,Position=1)]
    [string]$Username,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$Url,
    [Parameter(Mandatory=$true,Position=3)]
    $AdminPassword

    )

    $global:ctx=New-Object Microsoft.SharePoint.Client.ClientContext($Url)
    $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username, $AdminPassword)
    $ctx.Load($ctx.Web)
    $ctx.ExecuteQuery()

}

# Paths to SDK. Please verify location on your computer.

Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 


$admin="t@trial890.onmicrosoft.com"
$pass=Read-Host "Enter Password: " -AsSecureString
$site="https://trial890.sharepoint.com/sites/teamsitewithlibraries"
$libraryTitle="tescik2"
$destLibr="lib4"
$global:ctx

Connect-SPO -Username $admin -Url $site -AdminPassword $pass

Get-Webfolders -DestinationLibrary $destLibr -OriginalLibrary $libraryTitle -ErrorAction Continue
