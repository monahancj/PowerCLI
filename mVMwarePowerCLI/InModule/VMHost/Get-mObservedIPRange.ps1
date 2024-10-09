function Get-mObservedIPRange {
	<#
    .SYNOPSIS
        A brief description of the function or script. This keyword can be used
        only once in each topic.

    .DESCRIPTION
        A detailed description of the function or script. This keyword can be
        used only once in each topic.

    .PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for
        each parameter in the function or script syntax.

    .EXAMPLE
        A sample command that uses the function or script, optionally followed
        by sample output and a description. Repeat this keyword for each example.

    .INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the
        function or script. You can also include a description of the input 
        objects.

    .OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can
        also include a description of the returned objects.

    .NOTES
        Additional information about the function or script.

		Created by:   	cmonahan
		Organization: 	Monster Worldwide, GTI

		Recent Comment History
		----------------------
		YYYMMDD username- 1st comment.
		YYYMMDD username- 2nd comment.
		YYYMMDD username- 3rd comment.

ToDo
----------------------
-Make move to decom folder work when connected to multiple vCenters.

	.LINK
        The name of a related topic. The value appears on the line below
        the .LINK keyword and must be preceded by a comment symbol (#) or
        included in the comment block. 

        Repeat the .LINK keyword for each related topic.

        This content appears in the Related Links section of the help topic.

        The Link keyword content can also include a Uniform Resource Identifier
        (URI) to an online version of the same help topic. The online version 
        opens when you use the Online parameter of Get-Help. The URI must begin
        with "http" or "https".

#>
	
	#TODO: Update comment based help.
	#TODO: Update to match PowerShell function template.
	#TODO: Update all output to the standard format using the snippet "OutputMessage".
	
	[cmdletbinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$VMHost
	)
	
	begin {
		
		# code to be executed once BEFORE the pipeline is processed goes here
		
	} # end begin block
	
	process {
		
		$VMhostobj = Get-VMHost -Name $VMHost
		# Once you have the VMHost object, we need to get the view of it and then query network adapter configuration view.
		
		$VMHostView = Get-View $VMHostObj
		$networkView = Get-View $VMHostView.ConfigManager.NetworkSystem
		#This view will contain the network information which shows the physical network adapters that contain the CDP information. So, we need query each adapters CDP information using QueryNetworkHint() method
		
		$physicalnics = $networkview.networkinfo.pnic
		
		$physicalnics | Sort-Object device | Select-Object @{
			n = 'VMHost'; e = { $VMHost }
		}, device, @{ n = "Hints"; e = { ($networkview.querynetworkhint($_.device)).subnet } }
		
<#
		foreach ($nic in $physicalnics)
		{
			$hints = $networkview.querynetworkhint($nic.device)
			foreach ($hint in $hints)
			{
				$hint.subnet
			}
		}
#>		
		
		
	} #end of the process block
	
	end {
		# code to be executed once AFTER the pipeline is processed goes here
		
		Remove-Variable VMHost -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
<# Comment History
YYYMMDD username- 3rd comment.
YYYMMDD username- 2nd comment.
YYYMMDD username- 1st comment.
#>	
} # end function


