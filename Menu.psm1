

class KeyReader {

    static [hashtable]$Keyboard = @{
        13 = 'Enter'
        38 = 'Up'    
        40 = 'Down'  
        37 = 'Left'  
        39 = 'Right' 
        16 = 'Shift' 
        17 = 'Ctrl'  
        46 = 'Delete'
        65 = 'a'     
        66 = 'b'     
        67 = 'c'     
        68 = 'd'     
        69 = 'e'     
        70 = 'f'     
        71 = 'g'     
        72 = 'h'     
        73 = 'i'     
        74 = 'j'     
        75 = 'k'     
        76 = 'l'     
        77 = 'm'     
        78 = 'n'     
        79 = 'o'     
        80 = 'p'     
        81 = 'q'     
        82 = 'r'     
        83 = 's'     
        84 = 't'     
        85 = 'u'     
        86 = 'v'     
        87 = 'w'     
        88 = 'x'     
        89 = 'y'     
        90 = 'z'     
    }

    static [string] ReadKey() {
        return [KeyReader]::Keyboard[$global:host.ui.rawui.readkey("NoEcho, IncludeKeyDown").virtualkeycode]
    }

}
function Color {
    #Created 12.6.2020 'Set the color of text' | TESTED
    # Public\132525684000000000.psm1
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content,
        [string]$Foreground,
        [string]$Background
    )
    
    $Reset = "[0m"

    $FGColorTable = @{
        DarkBlack   = "[30m"
        DarkRed     = "[31m"
        DarkGreen   = "[32m"
        DarkYellow  = "[33m"
        DarkBlue    = "[34m"
        DarkMagenta = "[35m"
        DarkCyan    = "[36m"
        DarkWhite   = "[37m"
        Black       = "[90m"
        Red         = "[91m"
        Green       = "[92m"
        Yellow      = "[93m"
        Blue        = "[94m"
        Magenta     = "[95m"
        Cyan        = "[96m"
        White       = "[97m"
    }
    $BGColorTable = @{
        DarkBlack   = "[40m"
        DarkRed     = "[41m"
        DarkGreen   = "[42m"
        DarkYellow  = "[43m"
        DarkBlue    = "[44m"
        DarkMagenta = "[45m"
        DarkCyan    = "[46m"
        DarkWhite   = "[47m"
        Black       = "[100m"
        Red         = "[101m"
        Green       = "[102m"
        Yellow      = "[103m"
        Blue        = "[104m"
        Magenta     = "[105m"
        Cyan        = "[106m"
        White       = "[107m"
    }

    $Prefix = ""

    if ($Foreground) {
        $Prefix = "$Prefix$([char]27)$($FGColorTable[$Foreground])"
    }
    if ($Background) {
        $Prefix = "$Prefix$([char]27)$($BGColorTable[$Background])"
    }

    $Suffix = "$([char]27)$Reset"

    $Value = "$prefix$content$suffix"

    return $value
}


class Menu {
    
    #Created ? 'The menu constructor'
    #Updated 11.29.2020
    #Updated 12.5.2020 'Try catch that uses COM object https://stackoverflow.com/questions/17849522/how-to-perform-keystroke-inside-powershell'

    hidden [array]$DisplayItems
    hidden [array]$SelectedItems
    hidden [string]$Keyinput
    [array]$WorkingItems
    [scriptblock]$DisplayFilter
    [int32]$UpperBounds
    [int32]$LowerBounds
    [int32]$Max
    [int32]$i
    [object]$SelectedItem
    [hashtable]$KeyActions

    Menu(
        [array]$WorkingItems,
        [scriptblock]$DisplayFilter
    ) {
        $this.WorkingItems = $WorkingItems
        $this.DisplayFilter = $DisplayFilter

        $this.DisplayItems = $WorkingItems | Foreach-Object $DisplayFilter
        $this.UpperBounds = 0 
        $this.LowerBounds = $this.Max = 20
        $this.i = 0
    
        $this.KeyActions = @{
            'Up'   = { return { $this.i -= 1 } }  
            'Down' = { return { $this.i += 1 } } 
        }
    
        if ($this.WorkingItems.Count -ne $this.DisplayItems.Count) {
            throw ('Display filter produced ' + $this.DisplayItems.Count + ' items but the number of input items was ' + $this.WorkingItems.Count )
        }
    
        $this.SelectedItems = $this.MakeSelectedItems()
    
    }

    hidden [object[]] MakeSelectedItems() {
    
        # Ensures that all the heavy lifting with customizing each item as a "selected" item is done
        # before the menu runs rather than during the main loop, as it was previously
    
        $tmp = @()
        $i_ = 0
    
        foreach ($item in $this.DisplayItems) {
            $item = $item -replace '(.*?)\[\d+m(.*)', '$1[96m$2'
            $tmp += "$(Color "• $($Item)" -Foreground Cyan)"
            $i_ ++
        }
        return $tmp
    
    }
    
    hidden [object] GetSelection([int32]$i) {
        
        return ($this.WorkingItems)[$i]
    }

    hidden [int32] WrapIndex([int32]$i_, [int32]$ItemCount) {

        if ($i_ -lt 0) {
            $i_ = $ItemCount - 1
        }
        if ($i_ -gt ($ItemCount - 1)) {
            $i_ = 0
        }

        return $i_
    } 

    hidden [Int32[]] CreateBoundary( [int32]$i_, [int32]$ItemCount, [int32]$MaxCount ) {

        $Bounds = [psobject]@{
            Upper = $null
            Lower = $null
        }

        if ($ItemCount -gt $MaxCount) {
        
            $Bounds.Lower = $i_ + [Math]::Ceiling(($this.Max / 2))
            $Bounds.Upper = $i_ - [Math]::Ceiling(($this.Max / 2))

            # if ($this.LowerBounds -gt $this.DisplayItems.Count) {
            #     throw
            # }
            if ($Bounds.Upper -lt 0) {
                $Bounds.Upper = 0
            }
            if ($Bounds.Upper -eq 0) {
                $Bounds.Lower = $MaxCount
            }

            if ($Bounds.Lower -gt $ItemCount) {
                $Bounds.Lower = $ItemCount
                $Bounds.Upper = $Bounds.Lower - $MaxCount
            }
            
        }
        else {
            $Bounds.Lower = $ItemCount - 1
            $Bounds.Upper = 0
        }

        return $Bounds.Upper..$Bounds.Lower

    }

    hidden [object[]] CreateHostSelection($Items, $ItemsAsSelected, [int32[]]$Range, [int32]$Selection) {

        $ResultItems = @()

        For ($i_ = $Range[0]; $i_ -le $Range[ - 1]; $i_++) {
        
            If ($i_ -eq $this.i) {
                #Selected item
                $ResultItems += $this.SelectedItems[$i_]
            }
            Else {
                #Other items
                $ResultItems += "  $($this.DisplayItems[$i_])  "
            }
        }
        return $ResultItems
    }

    hidden [object] Refresh() {

        [console]::CursorVisible = $false

        $this.i = $this.WrapIndex($this.i, $this.DisplayItems.Count)

        [int32[]]$ItemRange_ = $this.CreateBoundary($this.i, $this.DisplayItems.Count, $this.Max)

        Clear-Host

        $this.CreateHostSelection($this.DisplayItems, $this.WorkingItems, $ItemRange_, $this.i) | Write-Host

        return [psobject]@{
            i    = $this.i
            item = $this.GetSelection($this.i)            
        }
    }

    hidden [object] ResolveAction([string]$Key, [hashtable]$Actions, [psobject]$Selection) {

        if ($Key -in $Actions.Keys) {
            
            # Every scriptblock in KeyActions is given $i and the selection when it is invoked
            return (. $Actions[$Key] $Selection.i $Selection.item)
        }
        else {
            return $null
        }
    }

    [object] Start() {
    
        # Main loop which refreshes immediately upon receiving keyboard input
        # If the key input is not associated with a predefined action, sends the key to the host
        # under the assumption that the user is entering unrelated input
        
        While ($true) {
        
            [psobject]$Selection = $this.Refresh()
        
            $ActionResult = $this.ResolveAction([KeyReader]::ReadKey(), $this.KeyActions, $Selection)

            if ($null -ne $ActionResult) {
                if ($ActionResult -is [scriptblock]) {
                    . $ActionResult
                }
                else {
                    return $ActionResult
                }
            }
            else {
                $wshell = New-Object -ComObject wscript.shell
                $wshell.SendKeys("$($this.KeyInput)")
                [console]::CursorVisible = $true
                break
                return $null
            }
        }
        return $null
    }
}


function New-Menu {
    param(
        [Parameter(Mandatory)]
        $Items
    )

    $m = [menu]::new($Items, { $_ })
    $m.KeyActions.Enter = { param($i, $item) return $item; break }
    $m.Start()

}