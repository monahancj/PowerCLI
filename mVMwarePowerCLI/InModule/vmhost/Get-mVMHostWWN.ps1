function Get-mVMHostWWN {
	
<#
	.SYNOPSIS
		Outputs a VMHost's WWN and related information.

    .DESCRIPTION
		Outputs a VMHost's Device name, Port WorldWideName, Status, Speed, Driver name, and HBA Model.

    .PARAMETER VMHost
		The VMHost to report on.

    .EXAMPLE
		PS> Get-mVMHostWWN -VMHost esxf301.ops.global.ad

		VMHost            : esxf301.ops.global.ad
		Device            : vmhba1
		PortWorldWideName : 20000033aa000028
		Status            : online
		Speed             : 16
		Driver            : nfnic
		Model             : Cisco VIC FCoE Controller

		VMHost            : esxf301.ops.global.ad
		Device            : vmhba2
		PortWorldWideName : 20000044bb000028
		Status            : online
		Speed             : 16
		Driver            : nfnic
		Model             : Cisco VIC FCoE Controller

    .EXAMPLE
		PS> Get-Cluster Cluster-01 | Get-VMHost | Sort-Object -Property Name | Get-mVMHostWWN | Format-Table -AutoSize

		VMHost                     Device PortWorldWideName Status Speed Driver Model
		------                     ------ ----------------- ------ ----- ------ -----
		esxa301.ops.global.ad vmhba1 20000033aa000000  online    16 nfnic  Cisco VIC FCoE Controller
		esxa301.ops.global.ad vmhba2 20000044bb000000  online    16 nfnic  Cisco VIC FCoE Controller
		esxb301.ops.global.ad vmhba1 20000033aa000008  online    16 nfnic  Cisco VIC FCoE Controller
		esxb301.ops.global.ad vmhba2 20000044bb000008  online    16 nfnic  Cisco VIC FCoE Controller
		esxc301.ops.global.ad vmhba1 20000033aa000010  online    16 nfnic  Cisco VIC FCoE Controller
		esxc301.ops.global.ad vmhba2 20000044bb000010  online    16 nfnic  Cisco VIC FCoE Controller
		esxd301.ops.global.ad vmhba1 20000033aa000018  online    16 nfnic  Cisco VIC FCoE Controller
		esxd301.ops.global.ad vmhba2 20000044bb000018  online    16 nfnic  Cisco VIC FCoE Controller
		esxe301.ops.global.ad vmhba1 20000033aa000020  online    16 nfnic  Cisco VIC FCoE Controller
		esxe301.ops.global.ad vmhba2 20000044bb000020  online    16 nfnic  Cisco VIC FCoE Controller
		esxf301.ops.global.ad vmhba1 20000033aa000028  online    16 nfnic  Cisco VIC FCoE Controller
		esxf301.ops.global.ad vmhba2 20000044bb000028  online    16 nfnic  Cisco VIC FCoE Controller

    .INPUTS
		System.String
		VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl

    .OUTPUTS
		PSCustomObject

    .NOTES

		Original Author: Christopher Monahan, Monster Worldwide GTIS

	.LINK
		https://github.com/Monster-Platform-Services/mVMwarePowerCLI/blob/main/InModule/VMHost/Get-mVMHostWWN.ps1

#>

<# Comment History
	YYYY-MM-DD username- Initial add
#>
	
	[OutputType([PSCustomObject])]
	[cmdletbinding(SupportsShouldProcess = $false, PositionalBinding = $true)]

	param ([parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$VMHost)
	
	begin { # Code to be executed once BEFORE the pipeline is processed goes here.

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started."

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Begin block start"
		$EAPsaved = $ErrorActionPreference
		
		# The functions Get-mNow and Get-mCurrentLine are used in every script and function.
		if (Test-Path -Path function:\Get-mNow) { Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function Get-mNow is loaded in the session." }
		else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - The function Get-mNow is not loaded in the session." }

		if (Test-Path -Path function:\Get-mCurrentLine) { Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function Get-mCurrentLine is loaded in the session." }
		else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - The function Get-mCurrentLine is not loaded in the session." }

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started."

		# Test for required functions that aren't in required modules.  Remove this section if it's not needed.
		$FunctionList = "Test-mIsModuleLoaded", "Get-mCurrentLine"
		$FunctionList | ForEach-Object {
			if (Test-Path -Path function:\"$($_)") { Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is loaded in the session." }
			else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is not loaded in the session." }
		}

		# Test for required modules.  Internal support modules and vendor specific technology modules in addition to the builtin Microsoft PowerShell modules.  Remove this section if it's not needed.
		$ModuleList = "mPowerShellGenerics", "Microsoft.PowerShell.Security", "mVMwarePowerCLI", "VMware.VimAutomation.Core"
		$ModuleList | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) { Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is loaded in the session." }
			else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is not loaded in the session." }
		}

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Begin block end"

	} # end of the begin block

	process { # Code to be executed against every object in the pipeline goes here.

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Process block start - param1 $($VMHost)"

		# Do the work
		if (Get-VMHost $VMHost -ErrorAction SilentlyContinue) {
			Get-VMHostHba -VMHost $VMHost -Type FibreChannel | Select-Object VMHost, Device, @{ n = 'PortWorldWideName'; e = { "{0:x}" -f $_.PortWorldWideName } }, Status, Speed, Driver, Model
		}
		else { Write-Error "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - VMHost $($VMHost) doesn't exist." }
		
		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Process block end"

	} #end of the process block
	
	end {  # Code to be executed once AFTER the pipeline is processed goes here.  Disconnect server connections, remove variables, reset the transcript file if necessary, and any other cleanup.

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - End block start"
		# When testing comment out "-ErrorAction SilentlyContinue".  This will help find typos, unused variables, and other problems.
		Remove-Variable -Name ModuleList, FunctionList, VMHost -WhatIf:$false -ErrorAction SilentlyContinue # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.

		[System.GC]::Collect() # Memory cleanup
		$ErrorActionPreference = $EAPsaved

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - End block end"
		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function ended."

	} #end of the end block
} # end of the function Get-mVMHostWWN
