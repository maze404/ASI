## ASI - Automatic Setup Installer
# Written by Matthias Binner
# To be used for the quick installation of new devices
##################################### Global Variables
$ProgressPreference = 'SilentlyContinue'
##################################### Functions
Function New-ProgressBar {
 
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
    $syncHash = [hashtable]::Synchronized(@{})
    $newRunspace =[runspacefactory]::CreateRunspace()
    $syncHash.Runspace = $newRunspace
    $newRunspace.ApartmentState = "STA" 
    $newRunspace.ThreadOptions = "ReuseThread"           
    $newRunspace.Open() 
    $newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)           
    $PowerShellCommand = [PowerShell]::Create().AddScript({    
        [xml]$xaml = @" 
        <Window 
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
            Name="Window" Title="Herunterladen..." WindowStartupLocation = "CenterScreen" 
            Width = "300" Height = "100" ShowInTaskbar = "True"> 
            <StackPanel Margin="20">
            <ProgressBar x:Name="barProgress" Margin="10,0,10,0" Height="12" VerticalAlignment="Top"/>
            </StackPanel> 
        </Window> 
"@ 
  
        $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
        $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader ) 
        #===========================================================================
        # Store Form Objects In PowerShell
        #===========================================================================
        $xaml.SelectNodes("//*[@Name]") | %{ $SyncHash."$($_.Name)" = $SyncHash.Window.FindName($_.Name)}


        $syncHash.Window.ShowDialog() | Out-Null 
        $syncHash.Error = $Error 

    }) 
    $PowerShellCommand.Runspace = $newRunspace 
    $data = $PowerShellCommand.BeginInvoke() 
   
    
    Register-ObjectEvent -InputObject $SyncHash.Runspace `
            -EventName 'AvailabilityChanged' `
            -Action { 
                
                    if($Sender.RunspaceAvailability -eq "Available")
                    {
                        $Sender.Closeasync()
                        $Sender.Dispose()
                    } 
                
                } 

    return $SyncHash

}
function Write-ProgressBar {

    Param (
        [Parameter(Mandatory=$true)]
        [System.Object[]]$ProgressBar,
        [Parameter(Mandatory=$true)]
        [String]$Activity,
        [int]$PercentComplete
    ) 
   
   # This updates the control based on the parameters passed to the function 
   $ProgressBar.Window.Dispatcher.Invoke([action]{ 
      
      $ProgressBar.Window.Title = $Activity

   }, "Normal")

   if($PercentComplete)
   {

       $ProgressBar.Window.Dispatcher.Invoke([action]{ 
      
          $ProgressBar.ProgressBar.Value = $PercentComplete

       }, "Normal")

   }

}
function Close-ProgressBar {

    Param (
        [Parameter(Mandatory=$true)]
        [System.Object[]]$ProgressBar
    )

    $ProgressBar.Window.Dispatcher.Invoke([action]{ 
      
      $ProgressBar.Window.Close()

    }, "Normal")
 
}
function Get-Software {
    $count = 0
    $boxConsoleTitle.Text = $boxConsoleTitle.Text + "Starten des Downloads..."
    # Firefox
    if ( -not (Test-Path C:\temp\Firefox.msi)) {
        New-Item C:\temp\Firefox.msi
        #& Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=de" -Outfile C:\temp\Firefox.msi -UseBasicParsing
        (New-Object System.Net.WebClient).DownloadFileTaskAsync("https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=de", "C:\temp\Firefox.msi")
        $totalSize = (Invoke-WebRequest "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=de" -Method Head).Headers.'Content-Length'
        $ProgressBar = New-ProgressBar
        for (([INT]$currentSize = (((Get-Item C:\temp\Firefox.msi).length) / $totalSize)*100) -le 100) {Write-ProgressBar -ProgressBar $ProgressBar -Activity "$currentSize done." -PercentComplete $currentSize}
        Close-ProgressBar $ProgressBar
    }
    # $boxConsoleTitle.clear()
    # $boxConsoleTitle.Text = $boxConsoleTitle.Text + "Fertig."
}
##################################### GUI
Add-Type -AssemblyName PresentationFramework
Add-Type -Assembly PresentationCore
$xamlFile = "$PWD\CB-ASI\MainWindow.xaml"
$inputXML = (Get-Content $xamlFile -Raw) -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML
$Window=[Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $XAML) )
$xaml.SelectNodes("//*[@Name]").Name | Format-Table
################ GUI Variables
$checkInstallSoftware = $Window.FindName("checkInstallSoftware")
$checkNvidiaDriver = $Window.FindName("checkNvidiaDriver")
$checkOffice365 = $Window.FindName("checkOffice365")
$checkRMM = $Window.FindName("checkRMM")
$checkEnergySetting = $Window.FindName("checkEnergySetting")
$checkInstallFont = $Window.FindName("checkInstallFont")
$checkNetworkShare = $Window.FindName("checkNetworkShare")
$checkEverything = $Window.FindName("checkEverything")
$buttonExecute = $Window.FindName("buttonExecute")
$boxConsole = $Window.FindName("boxConsole")
$boxConsoleTitle = $Window.FindName("boxConsoleTitle")
################ Button Logic
$buttonExecute.Add_Click({
    try {
        if ($checkInstallSoftware.isChecked -eq $true) {
            Get-Software
        }
     } catch {
        $boxConsole.Text = $boxConsole.Text + "Error`n"
     }
})
$Window.ShowDialog()
