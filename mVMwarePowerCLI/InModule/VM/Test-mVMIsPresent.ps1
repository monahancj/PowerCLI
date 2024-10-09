function Test-mVMIsPresent {
	<#
	.SYNOPSIS
		Tests if a VM exist in the currently connected vCenter(s).  Returns $true or $false.
	
	.DESCRIPTION
		Primary purpose is as a helper function.  Functions that act on VMs should make sure the VM exists first to	avoid outputting a lot of noisy errors.
	
	.PARAMETER VM
		The VM name to test.
	
	.EXAMPLE
		PS C:\> Test-mVMIsPresent -VM somevmname
	
	.NOTES
		(shrugs)
			
	.LINK
		https://github.com/monster-next/mVMwarePowerCLI/blob/main/vm/Test-mVMIsPresent.ps1
#>
	
	[OutputType([System.Boolean])][cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$VM
	)
	
	begin {
		# Code to be executed once BEFORE the pipeline is processed goes here.
		
		Write-Verbose "`n$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) - *** Function $($MyInvocation.InvocationName) started."
		
		<# Test-mVCenterConnection needs more conditions tested for.  Currently returning false if 2 vCenters are connected but no parameters passed to Test-mVCenterConnection.
		# Verify connected to a vCenter
		if (Test-mVCenterConnection) { Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** vCenter connection to $($DefaultVIServer.Name) verified." }
		else { throw "$(Get-Date) - *** Not connected to a vCenter." } # end verify vCenter connection
		#>
		
	} # end begin block
	
	process {
		# Code to be executed against every object in the pipeline goes here.
		
		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Script Parameter Values`n------------------------`nVM: $($VM)"
		
		# Attempt to get the VM object.
		$tVM = Get-VM $VM -ErrorAction SilentlyContinue -OutVariable $null
		if (($tVM | Measure-Object).Count -gt 1) {
			Write-Error "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) - *** More than one VM returned.  A wildcard was likely used in the name: $($VM)"
			return $false
		}
		elseif ($tVM.NumCPU -eq 0) {
			Write-Error "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) - *** VM NumCPU = 0.  VM was likely just created and is still processing: $($VM)"
			return $false
}
		elseif ($tVM) {
			Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) - *** VM found: $($VM)."
			return $true
		}
		else {
			Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) - *** VM not found: $($VM)."
			return $false
		} # end Testing if a VM exists
		
	} # end of the process block
	
	end {
		# Code to be executed once AFTER the pipeline is processed goes here.
		
		# Variables that have not been set will cause Remove-Variable to error.  Using "SilentyContinue" to suppress that.
		Remove-Variable -Name VM -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) - *** Function finished"
		
	} # end of the end block
	
} # end function
