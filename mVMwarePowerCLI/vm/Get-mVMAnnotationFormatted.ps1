if (!(Get-Module -Name VMware.VimAutomation.Core)) { Import-Module VMware.VimAutomation.Core }
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

Function Get-mVMAnnotationFormatted {
	
	[cmdletbinding(SupportsShouldProcess = $false)]
	param (
	[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$VM
	)
	
	begin {
		
		# code to be executed once BEFORE the pipeline is processed goes here
		
	} # end begin block
	
	process {
		
		Get-VM -Name $VM | Select-Object Name, `
										 @{ n = 'Application'; e = { $_.CustomFields.Item("Application") } }, `
										 @{ n = 'Business Unit'; e = { $_.CustomFields.Item("Business Unit") } }, `
										 @{ n = 'Category'; e = { $_.CustomFields.Item("Category") } }, `
										 @{ n = 'Support Contact'; e = { $_.CustomFields.Item("Support Contact") } }, `
										 @{ n = 'PCI'; e = { $_.CustomFields.Item("PCI") } }, `
										 @{ n = 'PCI Role'; e = { $_.CustomFields.Item("PCI Role") } }
		
		
	} #end of the process block
	
	end {
		# code to be executed once AFTER the pipeline is processed goes here
		
		Remove-Variable VM
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
	
} # end function

<# Comment History
YYYMMDD username- 3rd comment.
YYYMMDD username- 2nd comment.
YYYMMDD username- 1st comment.
#>