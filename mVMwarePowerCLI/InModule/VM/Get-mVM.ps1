function Get-mVM {
	
<#
    .SYNOPSIS
        Dumb wrapper around PowerCLI's Get-VM cmdlet so that it can take pipeline input for the VM parameter.

    .DESCRIPTION
        There's no additional functionality.

    .PARAMETER  Name
        This can be a string or a VM object, the same as Get-VM.

    .EXAMPLE
        Get-Content VM_Names.txt | Get-mVM

    .INPUTS
        [String]
		[VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl]

    .OUTPUTS
        [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl]

    .NOTES
        
		Original Author: Christopher Monahan, Monster Worldwide GTIS
		Contributors:	 name,org
#>
	
	[OutputType([VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl])][cmdletbinding(SupportsShouldProcess = $false)]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$Name
	)
	
	begin {
		# Code to be executed once BEFORE the pipeline is processed goes here.
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started."
		
		# Test for required modules
		$ModuleList = 'mPowerShellGenerics'
		$ModuleList | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) { Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is loaded in the session." }
			else { throw "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is not loaded in the session." }
		}
		
	} # end begin block
	
	process {
		# Code to be executed against every object in the pipeline goes here.
		return Get-VM $Name
	} #end of the process block
	
	end {
		# Code to be executed once AFTER the pipeline is processed goes here.
		
		Remove-Variable VM, ModuleList -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function ended."
		
	} #end of the end block
	
} # end of the function
