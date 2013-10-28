<#
.SYNOPSIS
   Enables
.DESCRIPTION
   Base code from LucD (again) https://communities.vmware.com/thread/287941?start=0&tstart=0
.PARAMETER VM
   A VirtualMachine object
.EXAMPLE
   Enable-vCpuAndMemHotAdd (Get-VM -Name vmname)
.Notes
   <Information that does not fit easily into the other sections>
.Link
   <Links to other Help topics and Web sites of interest>
#>

# 1- put in switch logic to pick out OS
# 2- then update only what can be updated and aren't at the correct value
# 3- show before and after in console

Write-Output "`n$(Get-Date)- Starting script $($PSCommandPath) with the parameters:"
Write-Output -InputObject $PSBoundParameters | Format-Table -AutoSize

function EnableCPUandRAM ($gvVM) {
  $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec  
  $extra1 = New-Object VMware.Vim.optionvalue  
  $extra1.Key="mem.hotadd"  
  $extra1.Value="true"  
  $vmConfigSpec.extraconfig += $extra1  
  $extra2 = New-Object VMware.Vim.optionvalue  
  $extra2.Key="vcpu.hotadd"  
  $extra2.Value="true"  
  $vmConfigSpec.extraconfig += $extra2  
  $gvVM.Extensiondata.ReconfigVM($vmConfigSpec)  
}

function EnableRAM ($gvVM) {
  $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec  
  $extra1 = New-Object VMware.Vim.optionvalue  
  $extra1.Key="mem.hotadd"  
  $extra1.Value="true"  
  $vmConfigSpec.extraconfig += $extra1  
  $gvVM.Extensiondata.ReconfigVM($vmConfigSpec)  
}


$AllVMs = Get-VM *jump* | Sort-Object | Get-View
$AllVMs = Get-VM | Sort-Object | Get-View
$AllVMs | Measure-Object

foreach ($VM in $AllVMs) {
	switch ($VM.Guest.GuestId) {
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if ($VM.Config.MemoryHotAddEnabled -eq $false) { $VM.Name; EnableRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'windows7_64Guest'      { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'windows7Server64Guest' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'windows8Server64Guest' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'rhel4_64Guest' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
		'' { $VM; if (($VM.Config.CpuHotAddEnabled -eq $false) -or ($VM.Config.MemoryHotAddEnabled -eq $false)) { $VM.Name; EnableCPUandRAM -gvVM (Get-View -VIObject $VM.Name) } }
	}
}


Write-Output "`n$(Get-Date)- Finished script $($PSCommandPath).`n"


<#
$> get-vm cjm* | sort | % { Get-View -VIObject $_ } | select -expand config | select Name,GuestId,GuestFullName,CpuHotAddEnabled,CpuHotRemoveEnabled,MemoryHotAddEnabled,HotPlugMemoryLimit | ft -a

Name         GuestFullName                             CpuHotAddEnabled CpuHotRemoveEnabled MemoryHotAddEnabled HotPlugMemoryLimit
----         -------------                             ---------------- ------------------- ------------------- ------------------
cjm0         Microsoft Windows Server 2012 (64-bit)               False               False               False
cjm0-updated Microsoft Windows Server 2012 (64-bit)                True               False                True
cjm1         Microsoft Windows Server 2008 R2 (64-bit)            False               False               False
cjm1-updated Microsoft Windows Server 2008 R2 (64-bit)             True               False                True
cjm2         Microsoft Windows Server 2003 (64-bit)               False               False               False
cjm2-updated Microsoft Windows Server 2003 (64-bit)               False               False                True
cjm3         CentOS 4/5/6 (32-bit)                                False               False               False
cjm3-updated CentOS 4/5/6 (32-bit)                                 True               False                True
cjm4         Red Hat Enterprise Linux 5 (32-bit)                  False               False               False
cjm4-updated Red Hat Enterprise Linux 5 (32-bit)                  False               False               False
cjm5         Red Hat Enterprise Linux 5 (64-bit)                  False               False               False
cjm5-updated Red Hat Enterprise Linux 5 (64-bit)                   True               False                True
cjm6         Red Hat Enterprise Linux 6 (32-bit)                  False               False               False
cjm6-updated Red Hat Enterprise Linux 6 (32-bit)                   True               False                True
#>

