function Set-CIPPMobileDevice(
    [string]$Headers,
    [string]$Quarantine,
    [string]$UserId,
    [string]$DeviceId,
    [string]$TenantFilter,
    [string]$Delete,
    [string]$Guid,
    [string]$APIName = 'Mobile Device'
) {

    try {
        if ($Quarantine -eq 'false') {
            New-ExoRequest -tenantid $TenantFilter -cmdlet 'Set-CASMailbox' -cmdParams @{Identity = $UserId; ActiveSyncAllowedDeviceIDs = @{'@odata.type' = '#Exchange.GenericHashTable'; add = $DeviceId } }
            Write-LogMessage -headers $Headers -API $APIName -tenant $TenantFilter -message "Allow Active Sync Device for $UserId" -Sev 'Info'
            return "Allowed Active Sync Device for $UserId"
        } elseif ($Quarantine -eq 'true') {
            New-ExoRequest -tenantid $TenantFilter -cmdlet 'Set-CASMailbox' -cmdParams @{Identity = $UserId; ActiveSyncBlockedDeviceIDs = @{'@odata.type' = '#Exchange.GenericHashTable'; add = $DeviceId } }
            Write-LogMessage -headers $Headers -API $APIName -tenant $TenantFilter -message "Blocked Active Sync Device for $UserId" -Sev 'Info'
            return "Blocked Active Sync Device for $UserId"
        }
    } catch {
        $ErrorMessage = Get-CippException -Exception $_
        if ($Quarantine -eq 'false') {
            Write-LogMessage -headers $Headers -API $APIName -tenant $TenantFilter -message "Failed to Allow Active Sync Device for $($UserId): $($ErrorMessage.NormalizedError)" -Sev 'Error' -LogData $ErrorMessage
            return "Failed to Allow Active Sync Device for $($UserId): $($ErrorMessage.NormalizedError)"
        } elseif ($Quarantine -eq 'true') {
            Write-LogMessage -headers $Headers -API $APIName -tenant $TenantFilter -message "Failed to Block Active Sync Device for $($UserId): $($ErrorMessage.NormalizedError)" -Sev 'Error' -LogData $ErrorMessage
            return "Failed to Block Active Sync Device for $($UserId): $($ErrorMessage.NormalizedError)"
        }
    }

    try {
        if ($Delete -eq 'true') {
            New-ExoRequest -tenant $TenantFilter -cmdlet 'Remove-MobileDevice' -cmdParams @{Identity = $Guid; Confirm = $false } -UseSystemMailbox $true
            Write-LogMessage -headers $Headers -API $APIName -tenant $TenantFilter -message "Deleted Active Sync Device for $UserId" -Sev 'Info'
            return "Deleted Active Sync Device for $UserId"
        }
    } catch {
        $ErrorMessage = Get-CippException -Exception $_
        Write-LogMessage -headers $Headers -API $APIName -tenant $TenantFilter -message "Failed to delete Mobile Device $($Guid): $($ErrorMessage.NormalizedError)" -Sev 'Error' -LogData $ErrorMessage
        return "Failed to delete Mobile Device $($Guid): $($ErrorMessage.NormalizedError)"
    }
}
