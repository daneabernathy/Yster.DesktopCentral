function Get-DCPatch {
    <#
    .SYNOPSIS
        Gets a list of all patches applicable to your environment.
    .DESCRIPTION
        Provides a list of all patches that are available in the Patch Management interface.

        With no filters, it will display all applicable patches. This can be filtered down to just installed or just missing patches.
        Or the patches can be filtered by ID, BulletinID, Approval Status and/or Severity.
    .EXAMPLE
        Get-DCPatch -HostName DCSERVER -AuthToken '47A1157A-7AAC-4660-XXXX-34858F3A001C'

        Returns information on all patches supported by the server.
    .EXAMPLE
        Get-DCPatch -HostName DCSERVER -AuthToken '47A1157A-7AAC-4660-XXXX-34858F3A001C' -Domain 'CONTOSO' -PatchStatus Missing

        Displays just the missing patches for the CONTOSO domain.
    .EXAMPLE
        Get-DCPatch -HostName DCSERVER -AuthToken '47A1157A-7AAC-4660-XXXX-34858F3A001C' -PatchID 500049

        Returns just the information on the patch with ID 500049.
    .NOTES
        https://www.manageengine.com/patch-management/api/all-patches-patch-management.html
        https://www.manageengine.com/patch-management/api/supported-patches-patch-management.html
    #>

    [CmdletBinding()]
    param(
        # The Approval Status to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Approved', 'NotApproved', 'Declined')]
        [String]
        $ApprovalStatus,

        # The AuthToken for the Desktop Central server API.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AuthToken,

        # The Branch Office to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $BranchOffice,

        # The BulletinID to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $BulletinID,

        # The Custom Group to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CustomGroup,

        # The NETBIOS name of the Domain to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Domain,

        # The hostname of the Desktop Central server.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $HostName,

        # The PatchID to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int]
        $PatchID,

        # The Patch Status to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Installed', 'Missing')]
        [String]
        $PatchStatus,

        # The port of the Desktop Central server.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int]
        $Port = 8020,

        # The Platform to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Mac', 'Windows', 'Linux')]
        [String]
        $Platform,

        # The Severity to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Unrated', 'Low', 'Moderate', 'Important', 'Critical')]
        [String]
        $Severity
    )

    $Function_Name = (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Name
    $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Verbose ('{0}|Arguments: {1} - {2}' -f $Function_Name, $_.Key, ($_.Value -join ' ')) }

    try {
        $API_Path = Add-Filters -BoundParameters $PSBoundParameters -BaseURL 'patch/allpatches'
        $Query_Parameters = @{
            'AuthToken' = $AuthToken
            'HostName'  = $HostName
            'Port'      = $Port
            'APIPath'   = $API_Path
            'Method'    = 'GET'
        }
        Write-Verbose ('{0}|Calling Invoke-DCQuery' -f $Function_Name)
        $Query_Return = Invoke-DCQuery @Query_Parameters
        $Query_Return

    } catch {
        if ($_.FullyQualifiedErrorId -match '^DC-') {
            $Terminating_ErrorRecord = New-DefaultErrorRecord -InputObject $_
            $PSCmdlet.ThrowTerminatingError($Terminating_ErrorRecord)
        } else {
            throw
        }
    }
}