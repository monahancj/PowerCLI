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

        Type the parameter name on the same line as the .PARAMETER keyword. 
        Type the parameter description on the lines following the .PARAMETER
        keyword. Windows PowerShell interprets all text between the .PARAMETER
        line and the next keyword or the end of the comment block as part of
        the parameter description. The description can include paragraph breaks.

        The Parameter keywords can appear in any order in the comment block, but
        the function or script syntax determines the order in which the parameters
        (and their descriptions) appear in help topic. To change the order,
        change the syntax.
 
        You can also specify a parameter description by placing a comment in the
        function or script syntax immediately before the parameter variable name.
        If you use both a syntax comment and a Parameter keyword, the description
        associated with the Parameter keyword is used, and the syntax comment is
        ignored.


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

function Get-mClusterResourceUsage {
	[cmdletbinding(PositionalBinding = $false)]
	param (
	[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$Cluster
	)
	
	$ClusterHosts = Get-VMHost -Location $Cluster -State Connected
	
	"" | Select-Object @{ n = 'Cluster'; e = { $ClusterHosts[0].Parent.Name } }, `
					   @{ n = 'NumHosts'; e = { $ClusterHosts.Count } }, `
					   @{ n = 'CPUPct'; e = { [int]((((($ClusterHosts | Measure-Object -Property CPUUsageMhz -Sum).Sum/1024)) / (($ClusterHosts | Measure-Object -Property CPUTotalMhz -Sum).Sum/1024)) * 100) } }, `
					   @{ n = 'MemPct'; e = { [int]((($ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum).Sum / ($ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum).Sum) * 100) } }, `
					   @{ n = '||'; e = { '||' } }, `
					   @{ n = 'VMvCPUs'; e = { (Get-VM -Location $Cluster | Measure-Object -Sum -Property NumCpu).Sum } }, `
					   @{ n = 'HostpCPUs'; e = { ($ClusterHosts | Measure-Object -Sum -Property NumCpu).Sum } }, `
					   @{ n = 'CPUTotalMhz'; e = { [int](($ClusterHosts | Measure-Object -Property CPUTotalMhz -Sum).Sum/1024) } }, `
					   @{ n = 'CPUUsageMhz'; e = { [Math]::Round(((($ClusterHosts | Measure-Object -Property CPUUsageMhz -Sum).Sum/1024)), 2) } }, `
					   @{ n = 'CPUFreeMhz'; e = { [Math]::Round((((($ClusterHosts | Measure-Object -Property CPUTotalMhz -Sum).Sum/1024) - (($ClusterHosts | Measure-Object -Property CPUUsageMhz -Sum).Sum/1024))), 2) } }, `
					   @{ n = 'MemoryTotalGB'; e = { [int]($ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum).Sum } }, `
					   @{ n = 'MemoryUsageGB'; e = { [int]($ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum).Sum } }, `
					   @{ n = 'MemoryFreeGB'; e = { [int]((($ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum).Sum) - (($ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum).Sum)) } }

Remove-Variable Cluster, ClusterHosts
[System.GC]::Collect() # Memory cleanup

}



# Get-mClusterResourceUsage -Cluster bed-poc-ucs-01 | ft -a


# Get-Cluster | Sort-Object | % { Get-mClusterResourceUsage -Cluster $_ } | ft -a
