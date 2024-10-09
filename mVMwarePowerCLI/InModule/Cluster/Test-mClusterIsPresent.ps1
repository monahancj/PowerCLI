function Test-mClusterIsPresent {
	<#
	.SYNOPSIS
		Tests if a host cluster exist in the currently connected vCenter(s).  Returns true or false.

	.DESCRIPTION
		Primary purpose is as a helper function.  Functions that act on clusters should make sure the cluster exists first to avoid outputting a lot of noisy errors.

	.PARAMETER Cluster
		The cluster name to test.

	.EXAMPLE
		PS C:\> Test-mClusterIsPresent -Cluster someclustername

	.NOTES
		Not much too it.

	.LINK
		https://github.monster.com/OPS/mVMwarePowerCLI/blob/master/mVMwarePowerCLI/Cluster/Test-mClusterIsPresent.ps1
#>
	
	[OutputType([System.Boolean])][cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false)]$Cluster
	)
	
	begin {
		# Code to be executed once BEFORE the pipeline is processed goes here.
		
		Write-Verbose "`n$(Get-Date)- *** Function $($MyInvocation.InvocationName) started."
		
		# Verify connected to a vCenter
		if (!($DefaultVIServer)) { throw "$(Get-Date)- *** Not connected to a vCenter." }
		else { Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** vCenter connection to $($DefaultVIServer.Name) verified." } # end verify vCenter connection
		
	} # end begin block
	
	process {
		# Code to be executed against every object in the pipeline goes here.
		
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Script Parameter Values`n------------------------`nCluster: $($Cluster)"
		
		# Attempt to get the Cluster object.
		$tCluster = Get-Cluster $Cluster -ErrorAction SilentlyContinue -OutVariable $null
		if ($tCluster.Count -gt 1) {
			Write-Error "$(Get-Date)- *** More than one cluster returned.  A wildcard was likely used in the name and is not supported: $($Cluster)"
			return $false
		}
		elseif ($tCluster) {
			Write-Verbose "$(Get-Date)- *** Cluster found: $($Cluster)"
			return $true
		}
		else {
			Write-Error "$(Get-Date)- *** Cluster not found: $($Cluster)"
			return $false
		} # end Testing if a cluster exists
		
	} # end of the process block
	
	end {
		# Code to be executed once AFTER the pipeline is processed goes here.
		
		# Variables that have not been set will cause Remove-Variable to error.  Using "SilentyContinue" to suppress that.
		Remove-Variable -Name Cluster, tCluster -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Function finished"
		
	} # end of the end block
	
} # end function
