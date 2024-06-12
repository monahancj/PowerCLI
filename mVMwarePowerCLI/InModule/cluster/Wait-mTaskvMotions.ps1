<#
	.SYNOPSIS
		Will enter a wait/loop if there are running vMotion or svMotion tasks.
	
	.DESCRIPTION
		Checks the tasks and counts the number running vMotion or svMotion tasks.
		If the number of active tasks is greater than the specified limit
		then the function sleeps and checks again. The intended is as a throttle
		in large (s)vMotion loops to prevent overloading the environment.  Is
		especially useful in throttling a script while an unrelated event happens, 
		such as putting a host or datastore into maintenance mode.
	
	.PARAMETER VM
		Optional.  If omitted then all vMotion type tasks in that vCenter count towards
		the "vMotionLimit" parameter.  If specified then only vMotion type tasks in the
		same host cluster as the specfied VM will count.
	
	.PARAMETER HostCluster
		Optional.  Will count active tasks only in the specified cluster.
	
	.PARAMETER vMotionLimit
		Optional.  The number active tasks to test for.  If the number of active tasks is
		less than this the function will exit, meaning it's safe for whatever your doing
		to proceed.  The default is 1, and must be an integer.
	
	.PARAMETER DelayMinutes
		Optional.  How long to wait before checking the active tasks again.  The default 
		is 1, and must be an integer.
	
	.EXAMPLE
		Wait-mTaskvMotions -Verbose
	
	.EXAMPLE
		Wait-mTaskvMotions -vMotionLimit 4
	
	.EXAMPLE
		Wait-mTaskvMotions -vMotionLimit 2 -DelayMinutes 3 -Verbose
	
	.EXAMPLE
		Moves all the VMs except for those with RDMs attached.
		Get-VM -Datastore "SomeDatastoreOrDatastoreclusterName" | sort usedspacegb -descending | % { if ( (Get-VM $_ | select -expand harddisks | ? { $_.DiskType -eq 'RawPhysical' }).Count -eq 0 ) { Write-Output "$(Get-Date)- Moving $($_)"; Wait-mTaskvMotions -VM $_ -Verbose; Move-VM -VM $_ -Datastore "SomeDatastoreOrDatastoreclusterName"; sleep 15 } else { Write-Output "$(Get-Date)- Leaving $($_), has an RDM" } }
	
	.NOTES
		Using -Verbose will output standard cmdlet started and finished messages, 
		and how long the function will sleep before it checks the active tasks again.

		Example 1
		-----------
		05/01/2014 22:42:18- Moving qa12-rse220
		VERBOSE: 05/01/2014 22:42:18- Starting vMotion throttle check
		host cluster check
		VERBOSE: 05/01/2014 22:42:25- vMotion throttle check clear.  Proceeding.
		
	.LINK
		https://opsgit.monster.com/_CMonahan/virtech/blob/master/mVMwarePowerCLI/cluster/Wait-mTaskvMotions.ps1
#>

Import-Module VMware.VimAutomation.Core
function Wait-mTaskvMotions {
	[CmdletBinding()]
	Param (
	[string]$VM,
	[string]$HostCluster,
	[int]$vMotionLimit = 1,
	[int]$DelayMinutes = 5
	)
	
	Write-Verbose "$(Get-Date)- Starting vMotion throttle check"
	
	function Get-mTask {
		get-task | Sort-Object starttime -descending | Select-Object starttime, @{
			n = "Percent"; e = {
				$_.percentcomplete
			}
		}, finishtime, @{
			n = "User"; e = {
				$_.extensiondata.info.reason.username
			}
		}, description, @{
			n = "Name"; e = {
				(get-view $_.objectid).Name
			}
		}, result
	} # end function Get-mTask
	
	function ObjectCluster {
		param ([string]$ObjId)
		if ($ObjId -like "VirtualMachine*") {
			(Get-VM -Id $ObjId).vmhost.parent.name
		}
		elseif ($ObjId -like "StoragePod*") {
			(Get-VMHost -Id (Get-Datastore -id (Get-DatastoreCluster -Id $ObjId -Verbose:$false).ExtensionData.ChildEntity[0] -Verbose:$false).ExtensionData.Host[0].Key -Verbose:$false).Parent.Name
		}
		else {
			Write-Output "Can't get a host or datastore cluster name from this object type.  Aborting."; break
		}
	} # end function ObjectCluster
	
	function NumvMotionTasks {
		param ([string]$ClusterToFilter)
		
		if ($ClusterToFilter) {
			(Get-Task -Verbose:$false | Where-Object {
				($_.PercentComplete -ne 100) -and (($_.Description -like '*DRS*') -or ($_.Description -like '*vMotion*') -or ($_.Description -like '*Relocate*')) -and ((ObjectCluster -ObjId $_.ObjectId) -eq $ClusterToFilter)
			} | Measure-Object).Count
		}
		else {
			(Get-Task -Verbose:$false | Where-Object {
				($_.PercentComplete -ne 100) -and (($_.Description -like '*DRS*') -or ($_.Description -like '*vMotion*') -or ($_.Description -like '*Relocate*'))
			} | Measure-Object).Count
		}
	} # function NumvMotionTasks
	
	# End of internal function declarations.
	# Main program starting.
	
	if ($VM) {
		$Cluster = (Get-VM $VM -Verbose:$false).VMHost.Parent.Name
	}
	elseif (($HostCluster) -and (Get-Cluster -Name $HostCluster)) {
		$Cluster = $HostCluster
	}
	else {
		$Cluster -eq $null
	}
	
	# sleep test
	if ($Cluster) {
		Write-Verbose "cluster check -- $(NumvMotionTasks) -- $($vMotionLimit)"
		While ((NumvMotionTasks -ClusterToFilter $Cluster) -ge $vMotionLimit) {
			if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
				Get-mTask | Format-Table -AutoSize
			} # end if
			Write-Verbose "$(Get-Date)- Waiting $($DelayMinutes) minute(s) before checking again."
			Start-Sleep ($DelayMinutes * 60)
		} # end while
	} # end if
	else {
		Write-Verbose "no cluster check -- $(NumvMotionTasks) -- $($vMotionLimit)"
		While (NumvMotionTasks -ge $vMotionLimit) {
			if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
				Get-mTask | Format-Table -AutoSize
			}
			Write-Verbose "$(Get-Date)- Waiting $($DelayMinutes) minute(s) before checking again."
			Start-Sleep ($DelayMinutes * 60)
		} #end while
	} #end else
	
	Write-Verbose "$(Get-Date)- vMotion throttle check clear.  Proceeding."
	
} # end function
