Function New-DynamicParameter
{
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'DynamicParameter')]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [type]$Type = [string],

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [string[]]$Alias,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$Mandatory,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [int]$Position,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [string]$HelpMessage,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$DontShow,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromPipeline,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromPipelineByPropertyName,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromRemainingArguments,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [string]$ParameterSetName = '__AllParameterSets',

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowNull,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowEmptyString,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowEmptyCollection,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$ValidateNotNull,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [switch]$ValidateNotNullOrEmpty,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2,2)]
        [int[]]$ValidateCount,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2,2)]
        [int[]]$ValidateRange,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2,2)]
        [int[]]$ValidateLength,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string]$ValidatePattern,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$ValidateScript,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ValidateSet,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                    If(!($_ -is [Management.Automation.RuntimeDefinedParameterDictionary]))
                    {
                        Throw 'Dictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object'
                    }
                    $true
        })]
        $Dictionary = $false,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'CreateVariables')]
        [switch]$CreateVariables,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'CreateVariables')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                    # System.Management.Automation.PSBoundParametersDictionary is an internal sealed class,
                    # so one can't use PowerShell's '-is' operator to validate type.
                    If($_.GetType().Name -ne 'PSBoundParametersDictionary')
                    {
                        Throw 'BoundParameters must be a System.Management.Automation.PSBoundParametersDictionary object'
                    }
                    $true
        })]
        $BoundParameters
    )

    Begin
    {
        Write-Verbose -Message 'Creating new dynamic parameters dictionary'
        $InternalDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

        Write-Verbose -Message 'Getting common parameters'
        function _temp
        {
            [CmdletBinding()] Param()
        }
        $CommonParameters = (Get-Command -Name _temp).Parameters.Keys
    }

    Process
    {
        If($CreateVariables)
        {
            Write-Verbose -Message 'Creating variables from bound parameters'
            Write-Debug -Message 'Picking out bound parameters that are not in common parameters set'
            $BoundKeys = $BoundParameters.Keys | Where-Object -FilterScript {
                $CommonParameters -notcontains $_
            }

            foreach($Parameter in $BoundKeys)
            {
                Write-Debug -Message ("Setting existing variable for dynamic parameter '{0}' with value '{1}'" -f $Parameter, $BoundParameters.$Parameter)
                Set-Variable -Name $Parameter -Value $BoundParameters.$Parameter -Scope 1 -Force -WhatIf:$false
            }
        }
        Else
        {
            Write-Verbose -Message 'Looking for cached bound parameters'
            Write-Debug -Message 'More info: https://beatcracker.wordpress.com/2014/12/18/psboundparameters-pipeline-and-the-valuefrompipelinebypropertyname-parameter-attribute'
            $StaleKeys = @()
            $StaleKeys = $PSBoundParameters.GetEnumerator() |
            ForEach-Object -Process {
                If($_.Value.PSobject.Methods.Name -match '^Equals$')
                {
                    # If object has Equals, compare bound key and variable using it
                    If(!$_.Value.Equals((Get-Variable -Name $_.Key -ValueOnly -Scope 0)))
                    {
                        $_.Key
                    }
                }
                Else
                {
                    # If object doesn't has Equals (e.g. $null), fallback to the PowerShell's -ne operator
                    If($_.Value -ne (Get-Variable -Name $_.Key -ValueOnly -Scope 0))
                    {
                        $_.Key
                    }
                }
            }
            If($StaleKeys)
            {
                [string[]]('Found {0} cached bound parameters:' -f $StaleKeys.Count) +  $StaleKeys | Write-Debug
                Write-Verbose -Message 'Removing cached bound parameters'
                $StaleKeys | ForEach-Object -Process {
                    $null = $PSBoundParameters.Remove($_)
                }
            }

            # Since we rely solely on $PSBoundParameters, we don't have access to default values for unbound parameters
            Write-Verbose -Message 'Looking for unbound parameters with default values'

            Write-Debug -Message 'Getting unbound parameters list'
            $UnboundParameters = (Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters.GetEnumerator()  |
            # Find parameters that are belong to the current parameter set
            Where-Object -FilterScript {
                $_.Value.ParameterSets.Keys -contains $PSCmdlet.ParameterSetName
            } |
            Select-Object -ExpandProperty Key |
            # Find unbound parameters in the current parameter set
            Where-Object -FilterScript {
                $PSBoundParameters.Keys -notcontains $_
            }

            # Even If parameter is not bound, corresponding variable is created with parameter's default value (If specified)
            Write-Debug -Message 'Trying to get variables with default parameter value and create a new bound parameter''s'
            $tmp = $null
            foreach($Parameter in $UnboundParameters)
            {
                $DefaultValue = Get-Variable -Name $Parameter -ValueOnly -Scope 0
                If(!$PSBoundParameters.TryGetValue($Parameter, [ref]$tmp) -and $DefaultValue)
                {
                    $PSBoundParameters.$Parameter = $DefaultValue
                    Write-Debug -Message ("Added new parameter '{0}' with value '{1}'" -f $Parameter, $DefaultValue)
                }
            }

            If($Dictionary)
            {
                Write-Verbose -Message 'Using external dynamic parameter dictionary'
                $DPDictionary = $Dictionary
            }
            Else
            {
                Write-Verbose -Message 'Using internal dynamic parameter dictionary'
                $DPDictionary = $InternalDictionary
            }

            Write-Verbose -Message ('Creating new dynamic parameter: {0}' -f $Name)

            # Shortcut for getting local variables
            $GetVar = {
                Get-Variable -Name $_ -ValueOnly -Scope 0
            }

            # Strings to match attributes and validation arguments
            $AttributeRegex = '^(Mandatory|Position|ParameterSetName|DontShow|HelpMessage|ValueFromPipeline|ValueFromPipelineByPropertyName|ValueFromRemainingArguments)$'
            $ValidationRegex = '^(AllowNull|AllowEmptyString|AllowEmptyCollection|ValidateCount|ValidateLength|ValidatePattern|ValidateRange|ValidateScript|ValidateSet|ValidateNotNull|ValidateNotNullOrEmpty)$'
            $AliasRegex = '^Alias$'

            Write-Debug -Message 'Creating new parameter''s attirubutes object'
            $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute

            Write-Debug -Message 'Looping through the bound parameters, setting attirubutes...'
            switch -regex ($PSBoundParameters.Keys)
            {
                $AttributeRegex
                {
                    Try
                    {
                        $ParameterAttribute.$_ = . $GetVar
                        Write-Debug -Message ('Added new parameter attribute: {0}' -f $_)
                    }
                    Catch
                    {
                        $_
                    }
                    continue
                }
            }

            If($DPDictionary.Keys -contains $Name)
            {
                Write-Verbose -Message ("Dynamic parameter '{0}' already exist, adding another parameter set to it" -f $Name)
                $DPDictionary.$Name.Attributes.Add($ParameterAttribute)
            }
            Else
            {
                Write-Verbose -Message ("Dynamic parameter '{0}' doesn't exist, creating" -f $Name)

                Write-Debug -Message 'Creating new attribute collection object'
                $AttributeCollection = New-Object -TypeName Collections.ObjectModel.Collection[System.Attribute]

                Write-Debug -Message 'Looping through bound parameters, adding attributes'
                switch -regex ($PSBoundParameters.Keys)
                {
                    $ValidationRegex
                    {
                        Try
                        {
                            $ParameterOptions = New-Object -TypeName ('System.Management.Automation.{0}Attribute' -f $_) -ArgumentList (. $GetVar) -ErrorAction Stop
                            $AttributeCollection.Add($ParameterOptions)
                            Write-Debug -Message ('Added attribute: {0}' -f $_)
                        }
                        Catch
                        {
                            $_
                        }
                        continue
                    }

                    $AliasRegex
                    {
                        Try
                        {
                            $ParameterAlias = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList (. $GetVar) -ErrorAction Stop
                            $AttributeCollection.Add($ParameterAlias)
                            Write-Debug -Message ('Added alias: {0}' -f $_)
                            continue
                        }
                        Catch
                        {
                            $_
                        }
                    }
                }

                Write-Debug -Message 'Adding attributes to the attribute collection'
                $AttributeCollection.Add($ParameterAttribute)

                Write-Debug -Message 'Finishing creation of the new dynamic parameter'
                $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)

                Write-Debug -Message 'Adding dynamic parameter to the dynamic parameter dictionary'
                $DPDictionary.Add($Name, $Parameter)
            }
        }
    }

    End
    {
        If(!$CreateVariables -and !$Dictionary)
        {
            Write-Verbose -Message 'Writing dynamic parameter dictionary to the pipeline'
            $DPDictionary
        }
    }
}
