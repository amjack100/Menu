using module Menu

function Show-Command {
        
    $m = [menu]::new((Get-Command | Select-Object -ExpandProperty Source -Unique), { $_ })
    $m.KeyActions.Enter = { param($i, $item) return (Get-Command | Where-Object Source -EQ $item); break }
    $m.Start()

}