

Param ([string] $filename="")


function check([string]$Check)
{
    $GG="That user already exists"
    $WP="That user does not exist .... creating User"
    
    Get-ADUser $Check -ErrorAction SilentlyContinue -ErrorVariable $errorUser
    
    if ($errorUser.count -eq 1)
    {
        return $GG
      
    }
    
    else{
        $WP
    }
    

}


$bool = Test-Path $filename

    $GroupExists="That Group already exists"

<#if ($bool -eq $false)
{
    Write-Host "That file does not exist"

#>
    $x = [xml](Get-Content $filename)
    
        
         ##Adds Groups and checks whether or not they exist
           foreach($i in $x.root.userManagement.user)
        {
            
            $GroupArray=@($i.memberof.group)
            $CheckGroup = Get-ADGroup $GroupArray[0] -ErrorAction SilentlyContinue 
            $CheckGroup2 = Get-ADGroup $GroupArray[1] -ErrorAction SilentlyContinue
            if($CheckGroup -eq $null)
            {
                if($GroupArray[0] -ne $null)
                {
                    New-ADGroup -GroupScope Global -Name $GroupArray[0]
                    Write-Host "Added new group" $GroupArray[0] -ForegroundColor Yellow
                    New-ADGroup -GroupScope Global -Name $GroupArray[1]
                    Write-Host "Added new group" $GroupArray[1] -ForegroundColor Yellow
                }
            }
            
        }
    
            $DC=Get-ADDomain | select -ExpandProperty DistinguishedName
                
        
            ##Checks Organizational Unit and adds if doesnt exists
            $CheckOU=(Get-ADOrganizationalUnit -filter {(Name -eq "$i.ou")})
            if($CheckOU -ne $null)
            {
                Write-Host "That OU already exists"
            }
            else
            {
                New-ADOrganizationalUnit -Name $i.ou -Path "$DC" -ProtectedFromAccidentalDeletion 0
            }


            #Adds Users
            foreach($i in $x.root.userManagement.user)
            {
                $tempou=$i.ou
                
                    if($i.manager -eq '')
                    {
                        New-ADUser -Name $i.account -GivenName $i.firstname -Surname $i.lastname -Description $i.description -Path "OU=$tempou, $DC" -AccountPassword(ConvertTo-SecureString -AsPlainText $i.password -force) -Enabled $true
                        Write-Host "Added new user"$i.account -ForegroundColor Green
                    }
          
                    else{
                            New-ADUser -Name $i.account -GivenName $i.firstname -Surname $i.lastname -Description $i.description -Path "OU=$tempou, $DC" -AccountPassword(ConvertTo-SecureString -AsPlainText $i.password -force) -Enabled $true -Manager $Manager
                            Write-Host "Added new user"$i.account -ForegroundColor Green
                    }
            
            }
    

               ##Adds users to groups
                foreach($i in $x.root.userManagement.user)
                {
                    $GArray=@($i.memberof.group)
                    if($GArray[0] -ne $null)
                    {
                        Add-ADGroupMember -Identity $GArray[0] -Member $i.account
                    }
                    elseif($GArray[1] -ne $null)
                    {
                        Add-ADGroupMember -Identity $GArray[1] -Member $i.account
                    }
                   
                }
                #Makes local groups and adds the users to groups
                foreach($i in $x.root.localGroupManagement.localGroup)
                {
                 New-ADGroup -GroupScope Global -Name $i.name
                 Add-ADGroupMember -Identity $i.name -Member $i.members.group
                }
            
    <#
            foreach($i in $x.root.userManagement.user)
            {

                    $tempaccount = $i.account
                    $tempfirstname = $i.firstname
                    $templastname = $i.lastname
                    $tempdescription = $i.description
                    $temppassword = $i.password
                    $tempmanager = $i.manager
                    $tempou = $i.ou

                    check $tempaccount
        

                    if ($tempmanager -eq '')
                    {
                        New-ADUser -Name $tempaccount -GivenName $tempfirstname -Surname $templastname -Description $tempdescription -Path "OU=$temp.ou, DC=esage, DC=us" -AccountPassword(ConvertTo-SecureString -AsPlainText $temppassword -force) -Enabled $true

                    }

                    elseif($tempmanager -ne '')
                    {
                        New-ADUser -Name $tempaccount -GivenName $tempfirstname -Surname $templastname -Description $tempdescription -Path "OU=$temp.ou, DC=esage, DC=us" -AccountPassword(ConvertTo-SecureString -AsPlainText $temppassword -force) -Enabled $true -Manager $tempmanager
                        
            
                    }
            }

                ##Adds users to groups
                foreach($i in $x.root.userManagement.user)
                {
                    $GArray=@($i.memberof.group)
                    if($GArray[0] -ne $null)
                    {
                        Add-ADGroupMember -Identity $GArray[0] -Member $i.account
                    }
                    elseif($GArray[1] -ne $null)
                    {
                        Add-ADGroupMember -Identity $GArray[1] -Member $i.account
                    }
                }
                
        
       #>  
         




