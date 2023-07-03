## ASI - Automatic Setup Installer
# Written by Matthias Binner
# To be used for the quick installation of new devices
##################################### Skript Parameter
Param(
    [String]$mode,
    [String]$noInstall,

    [Parameter(Mandatory=$false)]
    [switch]$shouldAssumeToBeElevated,

    [Parameter(Mandatory=$false)]
    [String]$workingDirOverride
)

##################################### Variabel Deklarierung
# Logfile Speicherort
$logfile = "C:\temp\cb-asi.log"
$ProgressPreference = 'SilentlyContinue'
$fontLocation = "PATH\TO\FONT\HERE"

##################################### Administrator Check
# If parameter is not set, we are propably in non-admin execution. We set it to the current working directory so that
# the working directory of the elevated execution of this script is the current working directory
if(-not($PSBoundParameters.ContainsKey('workingDirOverride'))) {
    $workingDirOverride = "C:\temp\Data"
}
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false) {''
    if ($shouldAssumeToBeElevated) {
        Write-Output "Elevating did not work"
    } else {
        if ($mode -eq "bpr") {
            if ($noInstall -eq "true") {
                Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}" -mode bpr -noInstall true' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))  
            } else {
            #                                                         vvvvv add `-noexit` here for better debugging vvvvv
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}" -mode bpr' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))  
            }

        } elseif ($mode -eq "vpn") {
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}" -mode vpn' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))
        } else {
            if ($noInstall -eq "true") {
                Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}" -noInstall true' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))
            } else {
                Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}"' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))
            }
        }

    }
    exit
}
Set-Location "$workingDirOverride"
##################################### Funktionen
function Test-Temp {
    if (!(Test-Path -Path C:\temp -ErrorAction SilentlyContinue)) {
        New-Item -Path "C:\" -Name "temp" -ItemType "directory" -ErrorAction SilentlyContinue
    }
}

function Get-Software {
    Write-Host "Willst du den Download der Standart Programme jetzt starten?" -BackgroundColor White -ForegroundColor Black
    $startDownload = Read-Host "J fuer Ja, N fuer Nein"
    if ($startDownload -eq "J" -or $startDownload -eq "j") {
        # Firefox
        if ( -not (Test-Path C:\temp\Firefox.msi)) {
            Write-Host "Firefox wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=de" -Outfile C:\temp\Firefox.msi -UseBasicParsing
        }
        # VLC
        if ( -not (Test-Path C:\temp\VLC.msi)) {
            Write-Host "VLC wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            $vlcdllink="https://download.videolan.org/vlc/last/win64/" + (((Invoke-WebRequest -Uri "https://download.videolan.org/vlc/last/win64/" -UseBasicParsing ).Links.href) -like "*.msi")
            Invoke-WebRequest -Uri "$vlcdllink" -Outfile C:\temp\VLC.msi -UseBasicParsing
        }
        # 7 zip
        if ( -not (Test-Path C:\temp\7zip.msi)) {
            Write-Host "7zip wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            $7zipdl = "https://www.7-zip.org/" + ((Invoke-WebRequest -Uri "https://www.7-zip.org/download.html" -UseBasicParsing ).Links.href -like "*.msi" | Select-Object -first 1)
            Invoke-WebRequest -Uri $7zipdl -Outfile C:\temp\7zip.msi -UseBasicParsing
        }
        # Java
        if ( -not (Test-Path C:\temp\Java.exe)) {
            Write-Host "Java wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            Invoke-WebRequest -Uri ((Invoke-WebRequest -Uri "https://www.oracle.com/java/technologies/javase-downloads.html" -UseBasicParsing).Links.href -like "*.msi" | Select-Object -first 1) -Outfile C:\temp\Java.msi -UseBasicParsing
        }
        # Teamviewer
        if ( -not (Test-Path C:\temp\Teamviewer.exe)) {
            Write-Host "Teamviwer wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            Invoke-WebRequest -Uri "https://download.teamviewer.com/download/TeamViewer_Setup.exe" -Outfile C:\temp\Teamviewer.exe -UseBasicParsing
        }
        # Adobe Reader DC
        if ( -not (Test-Path C:\temp\AdobeReader.exe)) {
            Write-Host "Adobe Reader DC wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            Invoke-WebRequest -Uri "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2101120039/AcroRdrDC2101120039_de_DE.exe" -Outfile C:\temp\AdobeReader.exe -UseBasicParsing
        }
        # Notepad++
        if ( -not (Test-Path C:\temp\notepad++.exe)) {
            Write-Host "Notepad++ wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            $DownloadUrl = "https://github.com" + ((Invoke-WebRequest -Uri "https://github.com/notepad-plus-plus/notepad-plus-plus/releases" -UseBasicParsing).Links.href -like "*x64.exe")
            Invoke-WebRequest -Uri $DownloadUrl -OutFile "C:\temp\Notepad++.exe"
        }
        # OpenVPN
        if ( -not (Test-Path C:\temp\OpenVPN.msi)) {
            Write-Host "OpenVPN Connect wird heruntergeladen." -BackgroundColor White -ForegroundColor Black
            Invoke-WebRequest -Uri "https://openvpn.net/downloads/openvpn-connect-v3-windows.msi" -OutFile C:\temp\OpenVPN.msi -UseBasicParsing
        }
    }
}
function Install-Software {
    Write-Host "Willst du die Installation der Standart Programme jetzt starten?" -BackgroundColor White -ForegroundColor Black
    $startInstall = Read-Host "J fuer Ja, N fuer Nein"
    if ($startInstall -eq "J" -or $startInstall -eq "j") {
        # Firefox
        Write-Host "Installation von Firefox" -BackgroundColor White -ForegroundColor Black
        Start-Process msiexec -Wait -ArgumentList '/I C:\temp\Firefox.msi /quiet'
        # VLC
        Write-Host "Installation von VLC Media Player" -BackgroundColor White -ForegroundColor Black
        Start-Process msiexec -Wait -ArgumentList '/I C:\temp\VLC.msi /qn'
        # 7 zip
        Write-Host "Installation von 7zip" -BackgroundColor White -ForegroundColor Black
        Start-Process msiexec -Wait -ArgumentList '/I C:\temp\7zip.msi /qn'
        # Java
        Write-Host "Installation von Java" -BackgroundColor White -ForegroundColor Black
        Start-Process -FilePath "C:\temp\Java.msi" -Wait -ArgumentList ' /q'
        # Teamviewer
        Write-Host "Installation von Teamviewer" -BackgroundColor White -ForegroundColor Black
        Start-Process -FilePath "C:\temp\Teamviewer.exe" -Wait -ArgumentList '/S'
        # Adobe Reader DC
        Write-Host "Installation von Adobe Reader DC" -BackgroundColor White -ForegroundColor Black
        Start-Process -FilePath "C:\temp\AdobeReader.exe" -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES /L*v $logfile" -WindowStyle Hidden -Wait
        # Notepad++
        Write-Host "Installation von Notepad++" -BackgroundColor White -ForegroundColor Black
        Start-process -FilePath "C:\temp\notepad++.exe" -ArgumentList "/S /L*v $logfile" -Verb runas -Wait
        # OpenVPN
        Write-Host "Installation von OpenVPN Connect" -BackgroundColor White -ForegroundColor Black
        Start-Process msiexec -Wait -ArgumentList '/I C:\temp\OpenVPN.msi /qb'
    }
}
function Install-NvidiaDriver {
    # Pruefe, ob das System eine Nvidia GPU hat
    if(((Get-WmiObject win32_VideoController | Format-List VideoProcessor | Out-String) -match 'Quadro') -or ((Get-WmiObject win32_VideoController | Format-List VideoProcessor | Out-String) -match 'Nvidia')) {
        Write-Host "Willst du die Installation des Nvidia Treibers starten?" -BackgroundColor White -ForegroundColor Black
        $confirmDriverInstall = Read-Host "J fuer Ja, N fuer Nein"
        if ($confirmDriverInstall -eq "J" -or $confirmDriverInstall -eq "j") {
            # Generiere die Download Links
            if ( -not (Test-Path C:\temp\C:\temp\nvidia.exe)) {
                Write-Host "Durchsuche Nvidia Repository nach neuestem Treiber" -BackgroundColor White -ForegroundColor Black
                if ((Get-WmiObject -Class Win32_VideoController).VideoProcessor -like "*Quadro*") {
                    $n0 = "https:" + ((Invoke-WebRequest -Uri 'https://www.nvidia.com/Download/processFind.aspx?psid=124&pfid=912&osid=57&lid=9&whql=1&ctk=0&dtcid=1').Links[0].href)
                } elseif ((Get-WmiObject -Class Win32_VideoController).VideoProcessor -like "*Nvidia*") {
                    $n0 = "https:" + ((Invoke-WebRequest -Uri 'https://www.nvidia.com/Download/processFind.aspx?psid=101&pfid=816&osid=57&lid=1&whql=1&ctk=0&dtcid=1' -UseBasicParsing).Links[0].href) 
                }
                Write-Host "Auswaehlen des neusten Download Links" -BackgroundColor White -ForegroundColor Black
                $n1 = "https://www.nvidia.de" + ((Invoke-WebRequest -Uri "$n0" -UseBasicParsing).Links.href -like "*DriverDownloads*")
                Write-Host "Aufrufen des direkten Download Links" -BackgroundColor White -ForegroundColor Black
                $n2 = "https:" + ((Invoke-WebRequest -Uri $n1 -UseBasicParsing).Links.href -like '*.exe')
                # Herunterladen des Installers
                Write-Host "Herunterladen der neuesten Version" -BackgroundColor White -ForegroundColor Black
                Invoke-WebRequest -Uri $n2 -Outfile "C:\temp\nvidia.exe" -UseBasicParsing
            }
            Write-Host "Entpacken des Installers" -BackgroundColor White -ForegroundColor Black
            $filesToExtract = "Display.Driver HDAudio NVI2 PhysX EULA.txt ListDevices.txt setup.cfg setup.exe"
            Start-Process -FilePath (((Get-ItemProperty -path  HKLM:\SOFTWARE\7-Zip\ -Name Path).Path) + "7z.exe") -NoNewWindow -ArgumentList "x -bso0 -bsp1 -bse1 -aoa C:\temp\nvidia.exe $filesToExtract -o""C:\temp\nvidia""" -wait
            Write-Host "Starten der Grafikkarten Treiber Installation" -BackgroundColor White -ForegroundColor Black
            (Get-Content "C:\temp\nvidia\setup.cfg") | Where-Object { $_ -notmatch 'name="\${{(EulaHtmlFile|FunctionalConsentFile|PrivacyPolicyFile)}}' } | Set-Content "C:\temp\nvidia\setup.cfg" -Encoding UTF8 -Force
            Start-Process -Wait -FilePath "C:\temp\nvidia\setup.exe" -ArgumentList "-passive -noeula -nofinish -s -wait"
        }
    }
}
function Install-Office365 {
    Write-Host "Willst du die Installation von Office365 jetzt starten?" -BackgroundColor White -ForegroundColor Black
    $start365 = Read-Host "J fuer Ja, N fuer Nein"
    if ($start365 -eq "J" -or $start365 -eq "j") {
        Write-Host "Installation von Office365" -BackgroundColor White -ForegroundColor Black
        Start-Process C:\temp\Data\Office\Setup64.exe -Wait -ArgumentList "SETUP /configure config.xml"
    }
}
function Set-EnergyMode {
    Write-Host "Die Energiespareinstellungen werden angepasst" -BackgroundColor White -ForegroundColor Black
    powercfg /change monitor-timeout-dc 0
    powercfg /change monitor-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0
}
function Set-ComputerName {
    Write-Host "Willst du den PC Namen anpassen?" -BackgroundColor White -ForegroundColor Black
    $askComputerName = Read-Host "J fuer Ja, N fuer Nein"
    if ($askComputerName -eq "J" -or $askComputerName -eq "j") {
        $ComputerName = Read-Host "Bitte gebe den neuen Namen fuer den PC ein"
        Rename-Computer -ComputerName "$env:computername" -NewName "$ComputerName" -Force
    }
}
function Set-DefaultFont {
    Param ( [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$FontFile )
    #Get Font Name from the File's Extended Attributes
    $oShell = new-object -com shell.application
    $Folder = $oShell.namespace($FontFile.DirectoryName)
    $Item = $Folder.Items().Item($FontFile.Name)
    $FontName = $Folder.GetDetailsOf($Item, 21)
    switch ($FontFile.Extension) {
        ".ttf" {$FontName = $FontName + [char]32 + '(TrueType)'}
        ".otf" {$FontName = $FontName + [char]32 + '(OpenType)'}
    }
    Copy-Item -Path $fontFile.FullName -Destination ("C:\Windows\Fonts\" + $FontFile.Name) -Force
    If ((Test-Path ("C:\Windows\Fonts\" + $FontFile.Name)) -ne $true) {
        Write-Host "Failed" -ForegroundColor White -BackgroundColor Red
    }
    Write-Host "Testing if font registry entry exists." -BackgroundColor White -ForegroundColor Black
    If ($null -ne (Get-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {
        Write-Host "Testing if the entry matches the font file name." -BackgroundColor White -ForegroundColor Black
        If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -ne $FontFile.Name) {
            Write-Host "Deleting the old registry entry for the font" -BackgroundColor White -ForegroundColor Black
            Remove-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force
            Write-Host "Setting a new entry for the font" -BackgroundColor White -ForegroundColor Black
            New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null
        }
    } else {
        Write-Host "Setting a new entry for the font" -BackgroundColor White -ForegroundColor Black
        New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null
    }
}
function Set-MSofficeFont {
    if ($startFont -eq "J" -or $startFont -eq "j") {
        If ((Test-Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Options") -ne $true) {
            New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Excel" -Name Options -Force
        }
        If ($null -ne (Get-ItemProperty -Name Font -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Options" -ErrorAction SilentlyContinue)) {
            If ((Get-ItemPropertyValue -Name Font -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Options") -like "$FontName*") {
                Remove-ItemProperty -Name Font -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Options" -Force
                New-ItemProperty -Name Font -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Options" -PropertyType string -Value "$FontName,10" -Force
            }
        } else {
            New-ItemProperty -Name Font -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Options" -PropertyType string -Value "$FontName,10" -Force
        }
        foreach ($user in $(Get-ChildItem C:\Users)) {
            if (-not ($user -like "admin*" -or $user -like "Public")) {
                if (Test-Path "C:\Users\$user\AppData\Roaming\Microsoft\Templates") {
                    Copy-Item $fontLocation\Normal.dotm C:\Users\$user\AppData\Roaming\Microsoft\Templates\Normal.dotm
                } else {
                    mkdir "C:\Users\$user\AppData\Roaming\Microsoft\Templates"
                    Copy-Item $fontLocation\Normal.dotm C:\Users\$user\AppData\Roaming\Microsoft\Templates\Normal.dotm
                }
            }
        }
    }
}
##################################### Script execution
#Clear-Host 
Write-Host @"
AAA                 SSSSSSSSSSSSSSS IIIIIIIIII
A:::A              SS:::::::::::::::SI::::::::I
A:::::A            S:::::SSSSSS::::::SI::::::::I
A:::::::A           S:::::S     SSSSSSSII::::::II
A:::::::::A          S:::::S              I::::I  
A:::::A:::::A         S:::::S              I::::I  
A:::::A A:::::A         S::::SSSS           I::::I  
A:::::A   A:::::A         SS::::::SSSSS      I::::I  
A:::::A     A:::::A          SSS::::::::SS    I::::I  
A:::::AAAAAAAAA:::::A            SSSSSS::::S   I::::I  
A:::::::::::::::::::::A                S:::::S  I::::I  
A:::::AAAAAAAAAAAAA:::::A               S:::::S  I::::I  
A:::::A             A:::::A  SSSSSSS     S:::::SII::::::II
A:::::A               A:::::A S::::::SSSSSS:::::SI::::::::I
A:::::A                 A:::::AS:::::::::::::::SS I::::::::I
AAAAAAA                   AAAAAAASSSSSSSSSSSSSSS   IIIIIIIIII

The Automatic Setup Installer                                                         
                                                          
"@ -BackgroundColor White -ForegroundColor Black
Test-Temp
Start-Sleep 1
if ($mode -eq "bpr") {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2
    if (-not $noInstall) {
        Get-Software
        Install-Software
        Install-NvidiaDriver
        Install-Office365
        Install-RMM
    }
    Set-EnergyMode
    Set-MSofficeFont
} else {
    if (-not $noInstall) {
        Get-Software
        Install-Software
        Install-NvidiaDriver
    }
    Set-EnergyMode
}
Write-Host "Aufraeumen..." -BackgroundColor White -ForegroundColor Black
Write-Host "Fertig." -BackgroundColor Green -ForegroundColor White
pause