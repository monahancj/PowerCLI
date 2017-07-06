<#
    .SYNOPSIS
        Copies the Annotation from one vCenter object to another of the same type.

    .DESCRIPTION
        This is nothing more than a wrapper around a one liner so I didn't have to
		keep typing a loop and to make large updates easier.

		This filters out Attributes that don't have a value assigned.

    .PARAMETER  Source
        The VM to copy the attributes from.

    .PARAMETER  Target
        The VM to copy the attributes to.

	.EXAMPLE
		PS D:\Tickets> Copy-mVMAnnotations -SourceVM testvm1 -TargetVM testvm2

		AnnotatedEntity Name                 Value
		--------------- ----                 -----
		testvm2       Application          Jump
		testvm2       Business Unit        DBA
		testvm2       Category             Misc
		testvm2       Support Contact      site-dba@monster.com

    .NOTES
        Additional information about the function or script.

		Created by:   	cmonahan
		Organization: 	Monster Worldwide, GTI

		Recent Comment History
		----------------------
		20170608 cmonahan - Added support for Whatif and ShouldProcess, and #Requires.
		20160516 cmonahan - Initial release.

#>

function Copy-mVMAnnotations {
	
	[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	param (
	[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$Source,
	[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]$Target
	)
	
	begin {
		
		# code to be executed once BEFORE the pipeline is processed goes here
		#Requires -Module VMware.VimAutomation.Core
		
	} # end begin block
	
	process {
		
		If ($Pscmdlet.ShouldProcess($Target, "Overwriting $($Target)'s custom attributes with $($Source)'s") ) {
			Get-Annotation -Entity $Source | Where-Object { $_.Value } | ForEach-Object { Set-Annotation -Entity $Target -CustomAttribute $_.Name -Value $_.Value }
		}
		
	} #end of the process block
	
	end {
		# code to be executed once AFTER the pipeline is processed goes here
		
		Remove-Variable Source, Target -WhatIf:$false
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
	
} # end function

<# Comment History
20170608 cmonahan - Added support for Whatif and ShouldProcess.
20160516 cmonahan - Initial release.
#>