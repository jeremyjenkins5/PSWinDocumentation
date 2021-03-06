Function Get-PrivilegedGroupsMembers {
    [CmdletBinding()]
    Param (
        $Domain,
        $DomainSID
    )
    $PrivilegedGroups1 = "$DomainSID-512", "$DomainSID-518", "$DomainSID-519", "$DomainSID-520" # will be only on root domain
    $PrivilegedGroups2 = "S-1-5-32-544", "S-1-5-32-548", "S-1-5-32-549", "S-1-5-32-550", "S-1-5-32-551", "S-1-5-32-552", "S-1-5-32-556", "S-1-5-32-557", "S-1-5-32-573", "S-1-5-32-578", "S-1-5-32-580"

    $SpecialGroups = @()
    foreach ($Group in ($PrivilegedGroups1 + $PrivilegedGroups2)) {
        Write-Verbose "Get-PrivilegedGroupsMembers - Group $Group in $Domain ($DomainSid)"
        try {
            $GroupInfo = Get-AdGroup $Group -ErrorAction Stop
            $GroupData = get-adgroupmember -Server $Domain -Identity $group | Sort-Object -Unique
            $GroupDataRecursive = get-adgroupmember -Server $Domain -Identity $group -Recursive:$Recursive | Sort-Object -Unique
            #$GroupDataRecursive | fl *
            #$GroupData.SamAccountName #| Select * -Unique
            #$GroupData | ft -a
            $SpecialGroups += [ordered]@{
                'Group Name'              = $GroupInfo.Name
                'Group Category'          = $GroupInfo.GroupCategory
                'Group Scope'             = $GroupInfo.GroupScope
                'Members Count'           = Get-ObjectCount $GroupData
                'Members Count Recursive' = Get-ObjectCount $GroupDataRecursive
                'Members'                 = $GroupData.SamAccountName
                'Members Recursive'       = $GroupDataRecursive.SamAccountName
            }
        } catch {
            Write-Verbose "Get-PrivilegedGroupsMembers - Error on Group $Group in $Domain ($DomainSid)"
        }
    }
    return $SpecialGroups.ForEach( {[PSCustomObject]$_})
}
