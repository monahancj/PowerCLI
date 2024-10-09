function Set-mPerenniallyReservedLUN {

<#
	.SYNOPSIS
		Sets any Raw Device Mapping FC SAN LUNs attached to a VM and used for Windows Microsoft Clustering to be perennially reserved.

    .DESCRIPTION
		Can be run against a single VMHost or all the VMHosts in a cluster.

		By default there is no output.  Use "-InformationAction Continue" to see which VMHosts and RDMs are being checked and modified.

    .PARAMETER Cluster
		A VMHost cluster.  Can either be a text string or a PowerCLI cluster object.

    .PARAMETER VMHost
		A VMHost.  Can either be a text string or a PowerCLI VMHost object.

    .EXAMPLE
		Set-mPerenniallyReservedLUN -Cluster Prod-CL-01

    .EXAMPLE
		Set-mPerenniallyReservedLUN -VMHost QA-esx07


    .NOTES
		This is a conversion of a small script I got from Adam Savage.

	.LINK
		https://github.com/Monster-Platform-Services/mVMwarePowerCLI/blob/main/InModule/VMHost/Set-mPerenniallyReservedLUN.ps1

#>

<# Comment History
	2024-10-07- Initial add
#>

	[cmdletbinding(PositionalBinding = $true, DefaultParameterSetName = "Cluster")]

	param (
		[Parameter(ParameterSetName = 'Cluster', Position = 0, Mandatory, ValueFromPipeline)]$Cluster,
		[Parameter(ParameterSetName = 'VMHost',  Position = 0, Mandatory, ValueFromPipeline)]$VMHost
	)

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
		$FunctionList = "Test-mIsModuleLoaded", "Get-mNow", "Get-mCurrentLine" # These functions are in the module mPowerShellGenerics
		$FunctionList | ForEach-Object {
			if (Test-Path -Path function:\"$($_)") { Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is loaded in the session." }
			else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is not loaded in the session." }
		}

		# Test for required modules.  Internal support modules and vendor specific technology modules in addition to the builtin Microsoft PowerShell modules.  Remove this section if it's not needed.
		$ModuleList = "mPowerShellGenerics", "mVMwarePowerCLI", "VMware.VimAutomation.Core"
		$ModuleList | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) { Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is loaded in the session." }
			else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is not loaded in the session." }
		}

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Begin block end"

	} # end of the begin block

	process {
		# Code to be executed against every object in the pipeline goes here.

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Process block start - Cluster= $($Cluster) - VMHost= $($VMHost)"

		# Verify connected to a vCenter server.
		if (Test-mVCenterConnection) {
			Write-Verbose -Message "$(get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - vCenter connection(s) found: $($global:DefaultVIServers) .  Proceeding"
		}
		else {
			Write-Error -Message "$(get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - No vCenter connection.  Exiting."
			break
		}

		# Validate the parameters as needed.
		switch ($PSCmdlet.ParameterSetName) {
			'Cluster' {
				if (Get-Cluster $Cluster) {
					Write-Verbose -Message "$(get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Cluster $($Cluster) was found.  Proceeding"
					$Cluster = Get-Cluster $Cluster
				}
				else {
					Write-Error -Message "$(get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Cluster $($Cluster) was not found.  Exiting."
					exit
				}
				break
			}
			'VMHost' {
				if (Get-VMHost $VMHost -ErrorAction SilentlyContinue) {
					Write-Verbose -Message "$(get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - VMHost $($VMHost) was found.  Proceeding"
					$VMHost = Get-VMHost $VMHost
				}
				else {
					Write-Error -Message "$(get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - VMHost $($VMHost) was not found.  Exiting."
					exit
				}
				break
			}
		}

		# Do the work
		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Setting the reservations."

		# Get the RDM canonical names
		# Setting the $VMHosts and $RDMNAAs variables was copied from Adam Savage's script with minor changes in addition to putting it into a switch statement.
		switch ($PSCmdlet.ParameterSetName) {
			'Cluster' {
				$VMHosts = Get-VMHost -Location $Cluster | Sort-Object -Property Name
				$RDMNAAs = Get-VM -Location $Cluster | Sort-Object -Property Name | Get-HardDisk -DiskType "RawPhysical", "RawVirtual" | Sort-Object -Property Name | Select-Object -ExpandProperty ScsiCanonicalName -Unique
				break
			}
			'VMHost' {
				$VMHosts = Get-VMHost -Name $VMHost
				$RDMNAAs = Get-VM -Location $VMHosts | Sort-Object -Property Name | Get-HardDisk -DiskType "RawPhysical", "RawVirtual" | Sort-Object -Property Name | Select-Object -ExpandProperty ScsiCanonicalName -Unique
				break
			}
		}

		try {
			Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - VMHosts count: $(($VMHosts | Measure-Object).Count)   RDMNAAs count: $(($RDMNAAs | Measure-Object).Count)"
		}
		catch {
			Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - VMHosts count: $(($VMHosts | Measure-Object).Count)   RDMNAAs count: 0"
		}

		# Set the LUN reservations.
		# This code section was copied from Adam Savage's script with neglible changes.
		foreach ($VMH in $VMHosts) {
			Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - $($VMH) - Looking for LUNs to set as perennially reserved."
			$myesxcli = Get-EsxCli -VMHost $VMH

			foreach ($naa in $RDMNAAs) {
				Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Checking LUN $($naa)"
				$diskinfo = $myesxcli.storage.core.device.list("$naa") | Select-Object -ExpandProperty IsPerenniallyReserved
				Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - $($VMH) -- $($naa) -- IsPerenniallyReserved -- $($diskinfo)"
				if ($diskinfo -eq "false") {
					Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Configuring Perennial Reservation for VMHost $($VMH) - LUN $($naa) ....."
					$myesxcli.storage.core.device.setconfig($false, $naa, $true)
					$diskinfo = $myesxcli.storage.core.device.list("$naa") | Select-Object -ExpandProperty IsPerenniallyReserved
					Write-Information -MessageData "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - $($VMH) -- $($naa) -- IsPerenniallyReserved -- $($diskinfo)"
				}
				Write-Information -MessageData "----------------------------------------------------------------------------------------------"
			}
		}

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Cluster = $($Cluster)`nVMHost = $($VMHost)`nVMHosts = $($VMHosts)`nVMH = $($VMH)`nmyesxcli = $($myesxcli)`nnaa = $($naa)`ndiskinfo = $($diskinfo)"
		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Process block end"

	} #end of the process block

	end {  # Code to be executed once AFTER the pipeline is processed goes here.  Disconnect server connections, remove variables, reset the transcript file if necessary, and any other cleanup.

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - End block start"
		# When testing comment out "-ErrorAction SilentlyContinue".  This will help find typos, unused variables, and other problems.
		Remove-Variable -Name ModuleList, FunctionList, Cluster, VMHost, VMHosts, VMH, myesxcli, naa, diskinfo -WhatIf:$false -ErrorAction SilentlyContinue # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.

		[System.GC]::Collect() # Memory cleanup
		$ErrorActionPreference = $EAPsaved

		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - End block end"
		Write-Verbose -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function ended - $($MyInvocation.InvocationName)"

	} #end of the end block

} # end of the function Set-mPerenniallyReservedLUNs (Useful for when you are looking at a function in a PSM1 file.  Can easily see when a function ends.  Can also be used with select string to find the start and end of a function.  I don't have a use case for that last one, but who know?)
