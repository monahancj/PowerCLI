class mClusterResourceUsage_Properties {
	[string]$Name
	[int]$HostsAvail
	[int]$HostsUnavail
	[int]$CPUPct
	[int]$MemPct
	[float]$vCPUpCpuRatio
	[int]$VMvCPUs
	[int]$HostpCPUs
	[int]$CPUTotalMhz
	[int]$CPUUsageMhz
	[int]$CPUFreeMhz
	[int]$MemoryTotalGB
	[int]$MemoryUsageGB
	[int]$MemoryFreeGB
}

function Get-mClusterResourceUsage {
	
	<#
    .SYNOPSIS
        Reports on various cluster statistics.

    .DESCRIPTION
        Calculated statistics: HostsAvail, HostsUnavail, CPUPct, MemPct, vCPUpCpuRatio, VMvCPUs, HostpCPUs, CPUTotalMhz, and CPUUsageMhz.

    .PARAMETER  Cluster
        The description of a parameter. Add a .PARAMETER keyword for each parameter in the function or script syntax.

    .EXAMPLE
		Get-mClusterResourceUsage -Cluster bed-poc-ucs-01 | ft -a

	.EXAMPLE
		Get-Cluster | Sort-Object | Get-mClusterResourceUsage | Format-Table -AutoSize

    .INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the function or script. You can also include a description of the input objects.

    .OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can also include a description of the returned objects.

    .NOTES
        Additional information about the function or script.

    .LINK
        The name of a related topic. The value appears on the line below the .LINK keyword and must be preceded by a comment symbol (#) or included in the comment block.

        Repeat the .LINK keyword for each related topic.

        This content appears in the Related Links section of the help topic.
#>
	[outputtype([mClusterResourceUsage_Properties])]
	[cmdletbinding(PositionalBinding = $true)]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$Cluster
	)
	
	#TODO: Update to latest function template.
	#TODO: Update comment based help.

	begin {
		# code to be executed once BEFORE the pipeline is processed goes here
		
		# The function Get-mCurrentLine is used in ever script and function.
		if (Test-Path -Path function:\Get-mCurrentLine) { Write-Verbose "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function Get-mCurrentLine is loaded in the session." }
		else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line 52 or so - Function Get-mCurrentLine is not loaded in the session." }
		
		Write-Verbose "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started."
		
		# Test for required modules.  Internal support modules and vendor specific technology modules in addition to the builtin Microsoft PowerShell modules.  Remove this section if it's not needed.
		$ModuleList = "mPowerShellGenerics", "VMware.VimAutomation.Core"
		$ModuleList | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) { Write-Verbose "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is loaded in the session." }
			else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is not loaded in the session." }
		}
		
		if (-not (Test-mVCenterConnection)) { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Not connected to a vCenter server." }
		
	} # end of the begin block
	
	process {
		
		#Validate the parameters as needed.
		if (-not (Get-Cluster $Cluster)) { Write-Error -Message "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Cluster $($Cluster) not found."; break }
		
		# Do the work
		$ClusterHosts = Get-VMHost -Location $Cluster -State Connected
		
		if ($ClusterHosts) {
			$HostpCPUs = ($ClusterHosts | Measure-Object -Sum -Property NumCpu).Sum
			$VMvCPUs = (Get-VM -Location $Cluster | Where-Object { $_.PowerState -eq 'PoweredOn' } | Measure-Object -Sum -Property NumCpu).Sum
		}
		else {
			$HostpCPUs = 0
			$VMvCPUs = 0
		}
		"" | Select-Object @{ n = 'Name'; e = { $Cluster } }, `
						   @{ n = 'HostsAvail'; e = { $ClusterHosts.Count } }, `
						   @{ n = 'HostsUnavail'; e = { (Get-VMHost -Location $Cluster | Where-Object { $_.ConnectionState -ne 'Connected' } | Measure-Object).Count } }, `
						   @{ n = 'CPUPct'; e = { [int]((((($ClusterHosts | Measure-Object -Property CPUUsageMhz -Sum).Sum/1024)) / (($ClusterHosts | Measure-Object -Property CPUTotalMhz -Sum).Sum/1024)) * 100) } }, `
						   @{ n = 'MemPct'; e = { [int]((($ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum).Sum / ($ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum).Sum) * 100) } }, `
						   @{ n = 'vCPUpCpuRatio'; e = { ([Math]::Round(($VMvCPUs / $HostpCPUs), 2)).ToString("0.00") } }, `
						   @{ n = 'VMvCPUs'; e = { $VMvCPUs } }, `
						   @{ n = 'HostpCPUs'; e = { $HostpCPUs } }, `
						   @{ n = 'CPUTotalMhz'; e = { [int](($ClusterHosts | Measure-Object -Property CPUTotalMhz -Sum).Sum/1024) } }, `
						   @{ n = 'CPUUsageMhz'; e = { [int](($ClusterHosts | Measure-Object -Property CPUUsageMhz -Sum).Sum/1024) } }, `
						   @{ n = 'CPUFreeMhz'; e = { [int](((($ClusterHosts | Measure-Object -Property CPUTotalMhz -Sum).Sum/1024) - (($ClusterHosts | Measure-Object -Property CPUUsageMhz -Sum).Sum/1024))) } }, `
						   @{ n = 'MemoryTotalGB'; e = { [int]($ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum).Sum } }, `
						   @{ n = 'MemoryUsageGB'; e = { [int]($ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum).Sum } }, `
						   @{ n = 'MemoryFreeGB'; e = { [int]((($ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum).Sum) - (($ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum).Sum)) } }
		
	} #end of the process block
	
	end {
		# Code to be executed once AFTER the pipeline is processed goes here.  Disconnect server connections, remove variables, reset the transcript file if necessary, and any other cleanup.
		
		# When testing comment out "-ErrorAction SilentlyContinue".  This will help find typos, unused variables, and other problems.
		Remove-Variable ModuleList, Cluster, ClusterHosts, HostpCPUs, VMvCPUs -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
	
}
