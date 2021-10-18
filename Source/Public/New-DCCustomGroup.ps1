function New-DCCustomGroup {
    <#
    .SYNOPSIS
        Creates a custom group.
    .DESCRIPTION

    .EXAMPLE
        New-DCCustomGroup -HostName DCSERVER -AuthToken '47A1157A-7AAC-4660-XXXX-34858F3A001C'

        Creates the custom group...
    .NOTES
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        # The AuthToken for the Desktop Central server API.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AuthToken,

        # The description of the custom group.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Description,

        # The category of custom group to create - Static or StaticUnique.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Static', 'StaticUnique')]
        [String]
        $GroupCategory,

        # The name of the custom group.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        # The type of custom group to create - user or computer.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Computer', 'User')]
        [String]
        $GroupType,

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

        # The Resource ID or IDs of the computers to add to the group.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int[]]
        $ResourceID
    )

    $Function_Name = (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Name
    $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Verbose ('{0}|Arguments: {1} - {2}' -f $Function_Name, $_.Key, ($_.Value -join ' ')) }

    try {
        $API_Path = 'dcapi/customGroups'
        $API_Body = @{
            'groupName'     = $GroupName
            'groupCategory' = $Group_Categories_Mapping[$GroupCategory]
            'groupType'     = $Group_Types_Mapping[$GroupType]
            'resourceIds'   = $ResourceID
        }
        if ($PSBoundParameters.ContainsKey('Description')) {
            $API_Body['description'] = $Description
        }
        $API_Header = @{
            'Accept' = 'application/customGroupAdded.v1+json'
        }
        $Query_Parameters = @{
            'AuthToken'   = $AuthToken
            'HostName'    = $HostName
            'Port'        = $Port
            'APIPath'     = $API_Path
            'Method'      = 'POST'
            'Body'        = $API_Body
            'Header'      = $API_Header
            'ContentType' = 'application/customGroupDetail.v1+json'
        }

        $Confirm_Header = New-Object -TypeName 'System.Text.StringBuilder'
        [void]$Confirm_Header.AppendLine('Confirm')
        [void]$Confirm_Header.AppendLine('Are you sure you want to perform this action?')

        $Remove_ShouldProcess = New-Object -TypeName 'System.Text.StringBuilder'
        [void]$Remove_ShouldProcess.AppendLine(('Create custom group: {0}' -f $GroupName))

        $Whatif_Statement = $Remove_ShouldProcess.ToString().Trim()
        $Confirm_Statement = $Whatif_Statement
        if ($PSCmdlet.ShouldProcess($Whatif_Statement, $Confirm_Statement, $Confirm_Header.ToString())) {
            Write-Verbose ('{0}|Calling Invoke-DCQuery' -f $Function_Name)
            $Query_Return = Invoke-DCQuery @Query_Parameters
            $Query_Return
        }

    } catch {
        if ($_.FullyQualifiedErrorId -match '^DC-') {
            $Terminating_ErrorRecord = New-DefaultErrorRecord -InputObject $_
            $PSCmdlet.ThrowTerminatingError($Terminating_ErrorRecord)
        } else {
            throw
        }
    }
}