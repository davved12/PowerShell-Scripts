
Param ([string]$filename="")

Test-Path $filename
$x=[xml](Get-Content $filename)

    foreach ($c in $x.clients.domain)
    {
       $Zone=$c.zone
        Get-DnsServerZone -Name $c.zone -ComputerName $c.primary -ErrorAction SilentlyContinue -ErrorVariable geterror
            if ($geterror.count -eq 0){
                Write-Host "zone $($c.zone) already exists"

            }
            else{
                $Resolveip = [system.net.dns]::GetHostAddresses("$c.primary")
                
                    Add-DnsServerPrimaryZone -Name $c.zone -ComputerName $c.primary -Zonefile $c.zone  -ResponsiblePerson $c.responsiblepersonemail
                    Add-DnsServerSecondaryZone -Name $c.zone -ComputerName $c.secondary -ZoneFile $c.zone -MasterServers $Resolveip.IPaddress.tostring
                    Set-DnsServerPrimaryZone -Name $c.zone -Zonefile $c.zone
                    Set-DnsServerSecondaryZone -Name $c.zone -Zonefile $c.zone
                    Write-Host "zone $($c.zone) added"
            }

            foreach($r in $c.records.record){
                if ($r.type -eq 'A'){
                    Add-DnsServerResourceRecordA -Name $r.hostname -ZoneName $Zone -IPv4Address $r.address
                    Write-Host "Added A record $($r.hostname)"
                }elseif ($r.type -eq 'CNAME'){
                    Add-DnsServerResourceRecordCName -Name $r.address -ZoneName $Zone -HostNameAlias $r.hostname
                    Write-Host "Added cname record $($r.hostname)"

                }elseif ($r.type -eq 'MX'){
                    Add-DnsServerResourceRecordMX -preference 0 -Name $r.address -ZoneName $Zone -MailExchange $r.address
                    $r.hostname
                    Write-Host "Added MX record $($r.hostname)"
                }
            }
            
    }



