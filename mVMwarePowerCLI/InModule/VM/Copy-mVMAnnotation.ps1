function Copy-mVMAnnotation {

<#
    .SYNOPSIS
        Copies the Annotation from one vCenter object to another of the same type.

    .DESCRIPTION
        This is nothing more than a wrapper around a one liner so I didn't have to
		keep typing a loop and to make large updates easier.

		This filters out Attributes that don't have a value assigned.

    .PARAMETER  Source
        The VM to copy the attributes from.

    .PARAMETER  Destination
        The VM to copy the attributes to.

	.EXAMPLE
		PS D:\Tickets> Copy-mVMAnnotations -Source testvm1 -Destination testvm2

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
		20210219 cmonahan - Added tests for the Source and Target VMs existing and that they aren't the same VM.
		20170608 cmonahan - Added support for Whatif and ShouldProcess, and #Requires.
		20160516 cmonahan - Initial release.
#>

	[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$Source,
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]$Destination
	)
	#TODO: Add comment based help.
	#TODO: Fully enable Confirm Impact.  Currently it's no prompting when not specified.
	#TODO: LowPri- Add parameter (hash table?) to copy individual annotation fields.  Add a parameter -All to copy all annotations (current behavior).
	#TODO: Fix issue with copying annotation between two VMs with the same name.  Update to work with VM Ids.

<#

	PS> Copy-mVMAnnotation -Source (Get-VM -Id VirtualMachine-vm-33333) -Target (Get-VM -Id VirtualMachine-vm-92394) -WhatIf
What if: Performing the operation "Remove variable" on target "Name: Name".
What if: Performing the operation "Remove variable" on target "Name: VIServerMode".
What if: Performing the operation "Remove variable" on target "Name: vCenterConnectionStatus".
Test-mVMIsPresent : 01/10/2022 23:28:25 - *** More than one VM returned.  A wildcard was likely used in the name: SourceVM01
At C:\Users\cmonahan\OneDrive - Monster_AD\My Documents\WindowsPowerShell\Modules\mVMwarePowerCLI\2021.8.25.0\mVMwarePowerCLI.psm1:1393 char:7
+         if (Test-mVMIsPresent -VM $Source) { $Source = Get-VM $Source ...
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Test-mVMIsPresent

What if: Performing the operation "Remove variable" on target "Name: VM".
Copy-mVMAnnotation : 01/10/2022 23:28:25- Copy-mVMAnnotation Line 1394 *** Source VM SourceVM01 does not exist.
At line:1 char:1
+ Copy-mVMAnnotation -Source (Get-VM -Id VirtualMachine-vm-33333) -Targ ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Copy-mVMAnnotation

#>

	#TODO: Troubleshoot issue with source VM name having a space in it.  Also check if it's also a problem with the parameter "-Target"
	#TODO: Currently the function only copies data if the source VM's annotation has data in it.  This has the benefit of not overwriting data with a $null.  That may not be desired behavior.  If the target VM has data in an annotation and the source VM does not the target VM's annotation won't be overwritten and the two VM's won't have the same annotations.

<#

PS> Copy-mVMAnnotation -Source "SourceVM01 New" -Target TargetVM01
Copy-mVMAnnotation : 01/10/2022 23:53:59- Copy-mVMAnnotation Line 1394 *** Source VM SourceVM01 New does not exist.
At line:1 char:1
+ Copy-mVMAnnotation -Source "SourceVM01 New" -Targ ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Copy-mVMAnnotation

#>
	begin {
		# code to be executed once BEFORE the pipeline is processed goes here
		#Requires -Module VMware.VimAutomation.Core
		
	} # end begin block

	process {
		if (Test-mVMIsPresent -VM $Source) { $Source = Get-VM $Source }
		else { Write-Error -Message "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Source VM $($Source) does not exist."; break }
		if (Test-mVMIsPresent -VM $Destination) { $Destination = Get-VM $Destination }
		else { Write-Error -Message "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Destination VM $($Destination) does not exist."; break }
		if ($Source -eq $Destination) { Write-Error -Message "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Source and Destination VMs $($Source) are the same."; break }

		Write-Verbose -Message "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Source VM $($Source) - Destination VM $($Destination)."
		
		if ($Pscmdlet.ShouldProcess($Destination, "Applying $($Source)'s custom attributes")) {
			Get-Annotation -Entity $Source | Where-Object { ($_.Value) -and ($_.Name -ne 'NB_LAST_BACKUP') } | ForEach-Object { Set-Annotation -Entity $Destination -CustomAttribute $_.Name -Value $_.Value }
		}
	} #end of the process block

	end {
		# code to be executed once AFTER the pipeline is processed goes here
		
		Remove-Variable Source, Destination -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
	
<# Comment History
2024-01-10 cmonahan - Excluded the annotation 'NB_LAST_BACKUP' so as not to copy incorrect information.
2021-02-19 cmonahan - Added tests for the Source and Target VMs existing and that they aren't the same VM.
2017-06-08 cmonahan - Added support for Whatif and ShouldProcess.
2016-05-16 cmonahan - Initial release.
#>
} # end function
