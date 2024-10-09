function Test-mVMHostConnectionState {
	<#
	.SYNOPSIS
		Either tests for the specified connection state and returns true/false or waits until the VMHost
		enters the specfied connection state.
	
	.DESCRIPTION
		Primary purpose is as a helper function.  When the wait parameter is used the function will wait
		until the VMhost enters the specified connection state, or will exit returning an error if the
		VMHost enters an error state or the timeout period is reached. 
	
	.PARAMETER VMHost
		The VMHost to be tested.  Can be passed as a string or PowerCLI VMHost object.
	
	.PARAMETER ConnectionState
		The connection state to test for or wait for.  Can be 'Online', 'Connected', 'Disconnected', 'Maintenance', or 'NotResponding'.
		'Online' means the VMHost state is either 'Connected' or 'Maintenance'.  After rebooting a VMHost
		might come back in either the 'Connected' or 'Maintenance' state.  This option is useful in scripts
		that reboots a VMHost and needs to wait for it to come back online before continuing.
	
	.PARAMETER Wait
		This is a switch parameter.  If it is specified then the function will wait for the VMHost
		to enter the specified connection state.  The connection state will be tested for the specified
		state and if it doesn't match the function will wait 1 minute before testing again.  This loop
		will repeat until the Timeout period is exceeded.
	
	.PARAMETER Timeout
		In seconds, the amount of time to wait wait for the VMHost to enter the specified connection
		state before giving up and timing out.  If not specified it defaults to 10 minutes.
	
	.EXAMPLE
		PS C:\> Test-mVMHostConnectionState -VMHost $VMHost -ConnectionState Connected
	
	.NOTES
		The capability of testing for a state but not waiting was added because it might be expected
		because of the meaning of the verb "Test".  It not very useful because it duplicates this very
		simple code:
		    if ( (Get-VMHost -Name vmhostname).ConnectionState -eq 'Maintenance' ) { $true } else { $false }
			
		The -Verbose parameter will show function specific debugging output.
			
	.LINK
		https://opsgit.monster.com/_CMonahan/virtech/blob/master/mVMwarePowerCLI/vmhost/Test-mVMHostState.ps1
#>
	
	[OutputType([System.Boolean])][cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false)]$VMHost,
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $false)][ValidateSet('Online', 'Connected', 'Disconnected', 'Maintenance', 'NotResponding', IgnoreCase)]$ConnectionState,
		[Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $false)][switch]$Wait,
		[Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $false)][int]$Timeout = 600 # Defaults to 10 minutes for a timeout period
	)
	
	begin {
		
		# code to be executed once BEFORE the pipeline is processed goes here
		Write-Verbose "`n$(Get-Date)- *** Function $($MyInvocation.InvocationName) started."
		
		Write-Verbose "Parameters $VMHost, $ConnectionState, $Wait, $Timeout"
		$SleepInterval = 60
		$TimeoutConverted = New-TimeSpan -Seconds $Timeout
		
		# Verify connected to a vCenter
		if (!($DefaultVIServer)) {
			Write-Output "$(Get-Date)- *** Not connected to a vCenter."
			break
		}
		else {
			Write-Verbose "$(Get-Date)- *** vCenter connection to $($DefaultVIServer.Name) verified."
		} # end verify vCenter connection
		
	} # end begin block
	
	process {
		
		# code to be executed against every object in the pipeline goes here
		
		# Verify paramenters
		if (!(Get-VMHost -Name $VMHost -ErrorAction Stop -OutVariable $null)) {
			Write-Output "$(Get-Date)- *** Not a valid VMHost name: $($VMHost)."
			break
		} # end verify VMHost
		
		$ErrorState = $false
		$VMH = Get-VMHost -name $VMHost
		# This if statement works around changing "Online" to "Connected|Maintenance" breaking parameter validation.
		if ($ConnectionState -eq 'Online') { $StateToTest = "Connected|Maintenance" }
		else { $StateToTest = $ConnectionState }
		
		if ($Wait) {
			$WaitTimeStart = Get-Date
			while (($VMH.ConnectionState -notmatch $StateToTest) -and !$ErrorState) {
				Write-Verbose "$(Get-Date)- Waiting for internal sleep interval of $($SleepInterval) seconds."
				Write-Verbose "Errorstate- $($ErrorState) -- VMHost name- $(Get-VMHost $VMH) -- Current VMHost state- $((Get-VMHost $VMH).ConnectionState)"
				Start-Sleep $SleepInterval
				$VMH = Get-VMHost -name $VMHost
				if ($VMH.ConnectionState -eq "Error") {
					Write-Output "$(Get-Date)- !! Host $($VMH.name) is in an error state.  Aborting."
					$ErrorState = $true
				}
				if ((Get-Date) -gt ($WaitTimeStart + $TimeoutConverted)) {
					Write-Output "$(Get-Date)- !! Timed out waiting for the host $($VMH.Name) to enter the state: $($State).  Aborting."
					$ErrorState = $true
				}
			} # end testing VMHost state
			
			Get-VMHost -Name $VMHost
			if ($ErrorState) { return }
		}
		else {
			Write-Verbose "$($VMH.ConnectionState) $($StateToTest)"
			if ($VMH.ConnectionState -eq $StateToTest) { return $true }
			else { return $false }
		} # end if-else
	} # end of the process block
	
	end {
		# Code to be executed once AFTER the pipeline is processed goes here
		
		Remove-Variable VMHost, ConnectionState, StateToTest, Wait, Timeout, SleepInterval, TimeoutConverted, VMH, WaitTimeStart, ErrorState -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
		Write-Verbose "`n$(Get-Date)- *** Function $($MyInvocation.InvocationName) finished."
		
	} # end of the end block
	
	<# Tests
	. P:\pathtofile\Test-mVMHostConnectionState.ps1

	Get-VMHost -Name testvmhost
	if ( (Get-VMHost -Name testvmhost).State -ne 'Connected' ) { Set-VMHost -VMHost testvmhost -State Connected -Confirm:$false }

	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Online
	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Connected
	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Maintenance
	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Disconnected

	Test-mVMHostConnectionState -VMHost xxx -ConnectionState Maintenance

	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Maintenance -Wait -Timeout 90

	# Run as a background job with a delay so that the function can start it's waiting period before the VMHost is told to enter maintenance mode.
	Start-Job -ScriptBlock { Add-PSSnapin VMware.VimAutomation.Core; Connect-VIServer -Server vcenter; Start-Sleep 70; Set-VMHost -VMHost testvmhost -State Maintenance -Confirm:$false }

	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Maintenance -Wait

	Start-Job -ScriptBlock { Add-PSSnapin VMware.VimAutomation.Core; Connect-VIServer -Server vcenter; Start-Sleep 70; Set-VMHost -VMHost testvmhost -State Connected -Confirm:$false }

	Test-mVMHostConnectionState -VMHost testvmhost -ConnectionState Connected -Wait

#>
	
} # end function

