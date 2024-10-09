function Wait-mVMPowerOff {
	<#
    .SYNOPSIS
        Function will loop and sleep until the VM is powered off.

    .DESCRIPTION
        At the start the VM's power state is tested.  If it's off the function exits.
		If it's powered on the function sleeps for the set time and tests the VM's
		power state again.  It will do this until the VM is powered off or you kill
		the function.

    .PARAMETER  VM
        The VM you're waiting for to power off.

	.PARAMETER WaitPeriod
		How long to wait between checks.  Defaults to 10 seconds.

    .EXAMPLE
        Wait-mVMPowerOff -VM $VM

    .EXAMPLE
        Wait-mVMPowerOff -VM $VM -WaitPeriod 30

    .LINK
		https://opsgit.monster.com/_CMonahan/virtech/blob/master/Repo/Modules/mVirtech/mVMwarePowerCLI/vm/Wait-mVMPoweroff.ps1
#>
	
	[CmdletBinding(
				   SupportsShouldProcess = $false,
				   ConfirmImpact = "None"
				   )]
	param (
		[Parameter(Mandatory = $true)]$VM,
		[Parameter(Mandatory = $false)]$WaitPeriod = 10
	)
	
	begin {
		
	} # end Begin Block
	
	process {
		while ((Get-VM -Name $VM).PowerState -ne 'PoweredOff') {
			Write-Output "$(Get-Date)- $((Get-VM -Name $VM).Name) is $((Get-VM -Name $VM).PowerState)"
			Start-Sleep $WaitPeriod
		}
		
	} # end Process Block
	
	end {
		Write-Output "$(Get-Date)- $((Get-VM -Name $VM).Name) is $((Get-VM -Name $VM).PowerState)"
		[System.GC]::Collect() # .Net memory gabarge collection
	} # end End Block
	
} # end Function

