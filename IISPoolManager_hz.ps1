## Параметры
## -a имя пула
## -s имя сервера
## -d действие
## -u пользователь
## -p пароль пользователя
## -t таймаут повторов

# script.ps1 -a edoclib -s localhost или ip -d start/stop/recycle -u user -p password -t timeout seconds

param ([string]$appPool = $null,
       [string]$server = $null,
       [string]$do = $null,
       [string]$user = $null,
       [string]$password = $null,
       [int]$timeout = $null
      )


$strPass = ConvertTo-SecureString -String $password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($user , $strPass) 

$Name = "W3SVC/APPPOOLS/$appPool"
$Path = "IISApplicationPool.Name='$Name'"
$poolActionResult = $false
$date = Get-Date -Format "dd.MM.yyyy"
$dateLog = Get-Date -Format "HH:mm:ss dd.MM.yyyy"

while(!$poolActionResult){
    
       
    if (!(Invoke-WMIMethod $do -Path $Path -Computer $server -Namespace root\MicrosoftIISv2 -Credential $Credential)) {
        Try
        {
            Write-Host "$appPool $do on $server" -foregroundcolor Green
            Add-Content Log_$date.txt "$dateLog $appPool $do on $server`r`n"
            $poolActionResult=$true
        }
        Catch [System.IO.DirectoryNotFoundException]
        {
            Write-Host "IIS Application Pool $appPool is not found on $server"
            Add-Content Log_$date.txt "IIS Application Pool $appPool is not found on $server`r`n"
        }
    }else{
            $poolActionResult=$false
            }
            Start-Sleep -s $timeout
    }