# Powershell Menu

Work in progress!

A simple powershell menu object to be embedded within scripts

## Function Example:

```Powershell
    New-Menu (Get-Command)
```

![alt text](https://github.com/amjack100/Menu/blob/master/Docs/sHxBL9G.gif "-")

## Class Example:

```Powershell
    $Items = 1..50
    $DisplayFilter = { $_ }

    $Menu = [Menu]::new($Items, $DisplayFilter)

    $Menu.Start()
```

## Directory Navigation Menu Example:

```Powershell
    $Menu = [Menu]::new($ChildItems, $Filter)

    $Menu.KeyActions.Delete = { param($i, $item) remove-item $item -Force -Recurse }
    $Menu.KeyActions.Enter = { param($i, $item) if ($Item -is [System.IO.FileInfo]) { Start-Process $item }  else { Set-Location $item }}
    $Menu.KeyActions.Left = { Set-Location .. }
    $Menu.KeyActions.Right = { param($i, $item) if ($Item -is [System.IO.FileInfo]) { Start-Process $item }  else { Set-Location $item } }

    $Menu.Start()
```
