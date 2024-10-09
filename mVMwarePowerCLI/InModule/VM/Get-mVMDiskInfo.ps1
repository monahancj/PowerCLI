function Get-mVMDiskInfo {
	
	<#
    .SYNOPSIS
        Returns detailed disk information for the specified VM.

    .DESCRIPTION
        For each disk in the VM it returns SCSI controller and SCSI ID specified in the VM hardware config, and the detailed disk info like DiskType, StorageFormat, ScsiCanonicalName, and a few more.

    .PARAMETER VM
        The VM to generate the report for.

    .EXAMPLE
		Get-mVMDiskInfo -VM dbserver0001 | Format-Table -AutoSize

		Parent       ControllerName    ControllerType          SCSIid DiskName    CapacityGB    DiskType StorageFormat ScsiCanonicalName                    Filename
		------       --------------    --------------          ------ --------    ----------    -------- ------------- -----------------                    --------
		dbserver0001 SCSI controller 0 LSI Logic SAS           0:0    Hard disk 1         60        Flat          Thin                                      [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001.vmdk
		dbserver0001 SCSI controller 1 VMware paravirtual SCSI 1:0    Hard disk 2        100        Flat          Thin                                      [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_1.vmdk
		dbserver0001 SCSI controller 1 VMware paravirtual SCSI 1:1    Hard disk 3        200        Flat          Thin                                      [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_2.vmdk
		dbserver0001 SCSI controller 2 VMware paravirtual SCSI 2:0    Hard disk 4       1000 RawPhysical               naa.60060160ca4a2200a69211da7378e311 [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_3.vmdk
		dbserver0001 SCSI controller 2 VMware paravirtual SCSI 2:1    Hard disk 5       1000 RawPhysical               naa.60060160ca4a2200a89211da7378e311 [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_4.vmdk

    .EXAMPLE
		"dbserver0001","dbserver0002" | % { Get-mVMDiskInfo -VM $_ } | Format-Table -AutoSize

		Parent       ControllerName    ControllerType          SCSIid DiskName    CapacityGB    DiskType    StorageFormat ScsiCanonicalName                    Filename
		------       --------------    --------------          ------ --------    ----------    --------    ------------- -----------------                    --------
		dbserver0001 SCSI controller 0 LSI Logic SAS           0:0    Hard disk 1         60        Flat             Thin                                      [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001.vmdk
		dbserver0001 SCSI controller 1 VMware paravirtual SCSI 1:0    Hard disk 2        100        Flat             Thin                                      [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_1.vmdk
		dbserver0001 SCSI controller 1 VMware paravirtual SCSI 1:1    Hard disk 3        200        Flat             Thin                                      [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_2.vmdk
		dbserver0001 SCSI controller 2 VMware paravirtual SCSI 2:0    Hard disk 4       1000 RawPhysical                  naa.60060160ca4a2200a69211da7378e311 [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_3.vmdk
		dbserver0001 SCSI controller 2 VMware paravirtual SCSI 2:1    Hard disk 5       1000 RawPhysical                  naa.60060160ca4a2200a89211da7378e311 [BED-QA-UCS-04-1448-01] dbserver0001/dbserver0001_4.vmdk
		dbserver0002 SCSI controller 0 LSI Logic SAS           0:0    Hard disk 1        160        Flat EagerZeroedThick                                      [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:0    Hard disk 2       2049 RawPhysical                  naa.600601603df0320063f30bfa2d05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_1.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:1    Hard disk 3       2049 RawPhysical                  naa.600601603df0320065f30bfa2d05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_2.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:2    Hard disk 4       2049 RawPhysical                  naa.600601603df0320067f30bfa2d05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_3.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:3    Hard disk 5       2049 RawPhysical                  naa.600601603df0320069f30bfa2d05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_4.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:4    Hard disk 6       2049 RawPhysical                  naa.600601603df03200f96d02022e05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_5.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:5    Hard disk 7       2049 RawPhysical                  naa.600601603df03200fb6d02022e05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_6.vmdk
		dbserver0002 SCSI controller 1 VMware paravirtual SCSI 1:6    Hard disk 8       1536 RawPhysical                  naa.600601603df03200fd6d02022e05e811 [VM-VMFS_BED-QADev-UCS-02-VNX-4507-02] dbserver0002/dbserver0002_7.vmdk

    .EXAMPLE
		Get-mVMDiskInfo -VM dbserver0001 | Where-Object { $_.DiskType -eq 'RawPhysical' } | Select-Object Parent,ControllerType,SCSIid,DiskName,ScsiCanonicalName | Format-Table -AutoSize

		Parent       ControllerType          SCSIid DiskName    ScsiCanonicalName
		------       --------------          ------ --------    -----------------
		dbserver0001 VMware paravirtual SCSI 2:0    Hard disk 4 naa.60060160ca4a2200a69211da7378e311
		dbserver0001 VMware paravirtual SCSI 2:1    Hard disk 5 naa.60060160ca4a2200a89211da7378e311

    .INPUTS
        System.String
		VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl

    .OUTPUTS
		NoteProperty System.Decimal CapacityGB
		NoteProperty System.String DiskName
		NoteProperty VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.DiskType DiskType
		NoteProperty System.String Filename
		NoteProperty string Label
		NoteProperty VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl Parent
		NoteProperty object ScsiCanonicalName
		NoteProperty System.String SCSIid
		NoteProperty VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat
		NoteProperty string Summary

    .NOTES
		Used to record RDM disk to SCSI controller assignments before changes are made to the VM, such as a migration to a new SAN array.
#>
	
	<# Comment History
		20210621 cmonahan- Fixed error when VM had only 1 disk.
		20180327 cmonahan- Initial add
	#>
	
	[cmdletbinding(SupportsShouldProcess = $false)]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$VM
	)
	
	begin {
		
		# code to be executed once BEFORE the pipeline is processed goes here
		
	} # end begin block
	
	process {
		
		if (Test-mVMIsPresent -VM $VM) { $VM = Get-VM $VM }
		else { Write-Error -Message "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Source VM $($VM) does not exist."; break }
		
		$Disks = Get-HardDisk -VM $VM
		$VMSCSI = $VM.ExtensionData.Config.Hardware.Device | Where-Object { $_.DeviceInfo.Label -like "SCSI controller*" }
		if ($VerbosePreference -ne 'SilentlyContinue') { $Disks | Sort-Object | Select-Object Parent, Name, CapacityGB, Id, Format, DiskType, SCSICanonicalName, Filename | Format-Table -AutoSize }
		if ($VerbosePreference -ne 'SilentlyContinue') { $vmscsi | Select-Object @{ n = 'ControllerName'; e = { $_.DeviceInfo.Label } }, @{ n = 'ControllerType'; e = { $_.DeviceInfo.Summary } }, Key, UnitNumber, @{ n = 'CtrlrKey'; e = { $_.ControllerKey } }, BusNumber, Device | Format-Table -AutoSize }
		$Report = foreach ($Device in ($VMSCSI | Select-Object -ExpandProperty device)) {
			Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Device = $($Device)"
			$Device | Select-Object @{ n = 'Parent'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).Parent } }, `
									@{ n = 'ControllerName'; e = { ($VMSCSI | Where-Object { $_.Device -contains $Device }).DeviceInfo.Label } }, `
									@{ n = 'ControllerType'; e = { ($VMSCSI | Where-Object { $_.Device -contains $Device }).DeviceInfo.Summary } }, `
									@{ n = 'SCSIid'; e = { "$([Math]::Truncate(($Device - 2000) / 16)):$((($Device - 2000) % 16))" } }, `
									@{ n = 'DiskName'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).Name } }, `
									@{ n = 'CapacityGB'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).CapacityGB } }, `
									@{ n = 'DiskType'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).DiskType } }, `
									@{ n = 'StorageFormat'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).StorageFormat } }, `
									@{ n = 'ScsiCanonicalName'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).ScsiCanonicalName } }, `
									@{ n = 'Sharing'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).ExtensionData.Backing.Sharing } }, `
									@{ n = 'Filename'; e = { ($Disks | Where-Object { $_.ExtensionData.Key -eq $Device }).Filename } }
		}
		
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Disk count check- Get-mVMDiskInfo: $(($Report | Measure-Object).Count)  Get-Harddisk: $((Get-HardDisk -VM $VM | Measure-Object).Count)"
		if (($Report | Measure-Object).Count -eq (Get-HardDisk -VM $VM | Measure-Object).Count) { $Report }
		else { Write-Error "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Get-mVMDiskInfo reporting incorrect number of disks.  Get-mVMDiskInfo: $(($Report | Measure-Object).Count)  Get-Harddisk: $((Get-HardDisk -VM $VM).Count)" }
		
	} #end of the process block
	
	end {
		# code to be executed once AFTER the pipeline is processed goes here
		
		Remove-Variable VM, VMSCSI, Disks, Device -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
	
} # end function
