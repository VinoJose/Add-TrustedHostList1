WorkFlow Add-TrustedHostList {
Param ([Parameter(Mandatory=$true)][STRING]$IPAddress,
[Parameter(Mandatory=$true)]$RVmmCredential,
[Parameter(Mandatory=$true)][STRING]$Logname)

    Write-Log -logname $logname -Message "Adding VM IP address to Trusted Hosts"

    InlineScript {

        Try {
            
            Write-Verbose "Receiving the Mutex 'AddTrustedHost'"
            $mtx = New-Object System.Threading.Mutex($false, "AddTrustedHost")
            $mtx.WaitOne()

            $ConnectVm = Invoke-Command {Get-Process} -ComputerName $Using:IPAddress -Credential $Using:RVmmCredential -ErrorAction Ignore
        
            If (!$ConnectVm){
            
                $ConfirmPreference = "None"

                Write-Verbose "Adding the IP of the VM to the trusted hosts of SMA server"
                $trustedhosts=(Get-Item wsman:\localhost\Client\TrustedHosts).value
                Write-Output "Current list of trustedhost is $trustedhosts"
                Write-Output "IPAddress inside Inline is $Using:IPAddress"

                if(!$trustedhosts)
                {
                    Set-Item wsman:\localhost\Client\TrustedHosts -value "$Using:IPAddress" -Force
                }
                else
                {
                    Set-Item wsman:\localhost\Client\TrustedHosts -value "$trustedhosts,$Using:IPAddress" -Force
                    $S = (Get-Item wsman:\localhost\Client\TrustedHosts).value
                    write-output "End value of trusted list is $s"

                }

                $ConfirmPreference = "High"
            
            }
        } 
        
        Catch {
            
            $Err1 = "Adding the IP of the VM to the trustedhostList of SMA server has been failed"
            Write-Verbose -Message $Err1
            Throw "$Err1. Error message : $_.Exception.Message"
        
        }

        Finally {

            Write-Verbose "Releasing the Mutex 'AddTrustedHost'"
            $mtx.ReleaseMutex()
            
        }
        
    }

}
