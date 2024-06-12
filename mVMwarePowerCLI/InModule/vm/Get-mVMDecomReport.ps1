<#
.SYNOPSIS
	Reports on the VM(s) properties before decommissioning it.

.DESCRIPTION
	Records those properties that are either useful for the decommissioning process or might be useful in
	the future for reporting or recreating the VM.

.PARAMETER VM
   	The VM Name in either text or PowerCLI VM object form.

.EXAMPLE
	Get-Content VMlist.txt | % { Get-mVMDecomReport -VM $_ } | Format-Table -Property * -AutoSize
	Note: That form of Format-Table prevents the columns at the end from not being displayed regardless of
	      how wide the monitor is.
.Notes
   Output is pasted into the standard decommissioning process form and put into the decommissioning ticket.

Comment History
20161013 cmonahan- Using $.HardDisks property of Get-VM has had a warning that it would be deprecated and now it finally has been.  In the RDMsGB property of the Select-Object I replaced "$_.DiskType" with "Get-HardDisk -VM $_".
20161013 cmonahan- Added this comment section.
#>

function Get-mVMDecomReport {
	param (
		[Parameter(Position = 0, Mandatory = $true)] $VM
	)
  Get-VM -Name $VM | Select-Object Name,@{n="Cluster";e={$_.VMHost.Parent.Name}}, `
  PowerState, `
  NumCPu, `
  MemoryGB, `
  @{n='VMDKProvGB';e={ $_ | ForEach-Object { [int]($_.ProvisionedSpaceGB - (($_.HardDisks | Where-Object { $_.DiskType -eq 'RawPhysical' }) | Select-Object -ExpandProperty capacitygb | Measure-Object -Sum).Sum - $_.MemoryGB)} }}, `
  @{n='VMDKUsedGB';e={ $_ | ForEach-Object { [int]($_.UsedSpaceGB -        (($_.HardDisks | Where-Object { $_.DiskType -eq 'RawPhysical' }) | Select-Object -ExpandProperty capacitygb | Measure-Object -Sum).Sum)} }}, `
  @{n='RDMsGB';e={ [int]((Get-HardDisk -VM $_ | Where-Object { $_.DiskType -eq 'RawPhysical' }) | Select-Object -ExpandProperty capacitygb | Measure-Object -Sum).Sum }}, `
  @{n="IPAddress";e={$_.Guest.IPAddress}}, `
  @{n="Datastore";e={($_.HardDisks[0].Filename) -split(" ") | Select-Object -first 1}}, `
  @{n="OSFullName";e={$_.Guest.OSFullName}}, `
  @{n="Hostname";e={ if ($_.Guest.IPAddress -ne $null) {(nslookup ($_.Guest.IPAddress) | Select-String "Name") -split " " | Select-Object -Last 1 } }}
}

<# Comment History
20161013 cmonahan- Using $.HardDisks property of Get-VM has had a warning that it would be deprecated and now it finally has been.  In the RDMsGB property of the Select-Object I replaced "$_.DiskType" with "Get-HardDisk -VM $_".
20161013 cmonahan- Added this comment section.
#>