<#
    .SYNOPSIS
        A brief description of the function or script. This keyword can be used
        only once in each topic.

    .DESCRIPTION
        A detailed description of the function or script. This keyword can be
        used only once in each topic.

    .PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for
        each parameter in the function or script syntax.

    .EXAMPLE
        A sample command that uses the function or script, optionally followed
        by sample output and a description. Repeat this keyword for each example.

    .INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the
        function or script. You can also include a description of the input 
        objects.

    .OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can
        also include a description of the returned objects.

    .NOTES
        Additional information about the function or script.

		Created by:   	cmonahan
		Organization: 	Monster Worldwide, GTI

		Recent Comment History
		----------------------
		YYYMMDD username- 1st comment.
		YYYMMDD username- 2nd comment.
		YYYMMDD username- 3rd comment.

ToDo
----------------------
-Make move to decom folder work when connected to multiple vCenters.

	.LINK
        The name of a related topic. The value appears on the line below
        the .LINK keyword and must be preceded by a comment symbol (#) or
        included in the comment block. 

        Repeat the .LINK keyword for each related topic.

        This content appears in the Related Links section of the help topic.

        The Link keyword content can also include a Uniform Resource Identifier
        (URI) to an online version of the same help topic. The online version 
        opens when you use the Online parameter of Get-Help. The URI must begin
        with "http" or "https".

#>



Function Set-mVMCpuMemHotAdd {
	
	[cmdletbinding(SupportsShouldProcess = $true)]
	param (
	[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$VM,
	[Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $false)][switch]$CPU,
	[Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $false)][switch]$Memory
	)
	
	begin {
		
		# code to be executed ONCE BEFORE the pipeline is processed goes here
		
	} # end begin block
	
	process {
		
		$vmview = Get-vm $vm | Get-View
		$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
		
		if ($CPU -or $Memory) {
			
			$vmview.config | Select-Object @{ n = 'TimeStamp'; e = { (Get-Date) } }, @{ n = 'When'; e = { 'Before' } }, Name, CpuHotAddEnabled, CpuHotRemoveEnabled, MemoryHotAddEnabled, HotPlugMemoryLimit | Format-Table -AutoSize
			
			if ($CPU) {
				Write-Verbose "$(Get-Date)- Enabling CPU Hot Add."
				$extra = New-Object VMware.Vim.optionvalue
				$extra.Key = "vcpu.hotadd"
				$extra.Value = "true"
				$vmConfigSpec.extraconfig += $extra
				$vmview.ReconfigVM($vmConfigSpec)
			}
			
			if ($Memory) {
				Write-Verbose "$(Get-Date)- Enabling Memory Hot Add."
				$extra = New-Object VMware.Vim.optionvalue
				$extra.Key = "mem.hotadd"
				$extra.Value = "true"
				$vmConfigSpec.extraconfig += $extra
				$vmview.ReconfigVM($vmConfigSpec)
			}
		}
		else { Write-Output "$(Get-Date)- Neither parameter -CPU or -Memory present." }
		
		
	} #end of the process block
	
	end {
		Write-Output "Reminder- Settings will not take effect until the VM is powered off.  An OS level reboot will not change the setting."		
		
		Remove-Variable VM, CPU, Memory
		[System.GC]::Collect() # Memory cleanup
		
	} #end of the end block
	
} # end function

<# Comment History
YYYMMDD username- 3rd comment.
YYYMMDD username- 2nd comment.
YYYMMDD username- 1st comment.
#>