function Get-DCSystemReport {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .NOTES
        https://www.manageengine.com/patch-management/api/system-report-patch-management.html
    #>

    [CmdletBinding()]
    param(
        # The AuthToken for the Desktop Central server API.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AuthToken,

        # The hostname of the Desktop Central server.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $HostName,

        # The port of the Desktop Central server.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int]
        $Port = 8020,

        # The Resource ID to filter on.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [Int]
        $ResourceID,

        # The Platform to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Mac', 'Windows')]
        [String]
        $Platform,

        # The Patch Status to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Installed', 'Missing')]
        [String]
        $PatchStatus,

        # The Approval Status to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Approved', 'NotApproved', 'Declined')]
        [String]
        $ApprovalStatus,

        # The Severity to filter on.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Unrated', 'Low', 'Moderate', 'Important', 'Critical')]
        [String]
        $Severity
    )

    $Function_Name = (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Name
    $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Verbose ('{0}|Arguments: {1} - {2}' -f $Function_Name, $_.Key, ($_.Value -join ' ')) }

    # testing
    # -------
    # [ ] platform
    # [ ] patchstatus
    # [ ] approvalstatus
    # [ ] severity

    try {
        $API_Path = Add-Filters -BoundParameters $PSBoundParameters -BaseURL 'patch/systemreport'
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
