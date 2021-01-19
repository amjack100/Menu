using module Menu

BeforeAll {
    Import-Module $PSScriptRoot\..\Menu.psm1 -Force
}


Describe "Menu" {

    BeforeAll {

        # $Items = @('One', 'Two', 'Three', 'Four', 'Five')
        $Items = 0..50
        $DisplayFilter = { $_ }

        $Menu = [Menu]::new($Items, $DisplayFilter)
    }
    
    Context "Begin" {

        It "Produces selected items at initialization" {
            
            foreach ($Item in $Menu.MakeSelectedItems()) {
                Write-Host $item
                $Item | Should -Beoftype [object]
            }
        }

        It 'Item count same as display count' {

            $Menu.WorkingItems.Count | Should -Be $Menu.DisplayItems.Count
        }
    }

    Context "Refresh host" {

        BeforeAll {
            $RefreshRate = 20
        }

        It "Displays different items based on key input" {
         
            $i_ = 0
            $flag = $false
            while ($i_ -lt 100) {
                
                foreach ($Item in $Menu.Refresh()) {
                    Write-Host $item
                    $Item | Should -Be $Menu.SelectedItems[$Menu.i]
                }
                
                Write-Host ("$($Menu.UpperBounds)" + '..' + $($Menu.LowerBounds) )
                Start-Sleep -Milliseconds $RefreshRate
    
                if ($flag) {
                    $Menu.i --
                }
                else {
                    $Menu.i ++
                }

                $i_ ++

                if ($i_ -gt ($Menu.WorkingItems.Count + 5)) {
                    $flag = $true
                }
            }
        }
    }

    # Context "Boundary Conditions" {

    #     It "Properly sets the boundary conditions if item count is over max display count" {
    #         $Menu.i = 20
    #         $Menu.AdjustBoundary()
    #         $Menu.UpperBounds | Should -Be ($Menu.i - [Math]::Ceiling(($Menu.Max / 2)))
    #         $Menu.LowerBounds | Should -Be ($Menu.i + [Math]::Ceiling(($Menu.Max / 2)))

    #     }

    # }

    Context "GetSelection" {

        It "Returns the selection" {

            $Menu.I = 26
            $Menu.GetSelection() | Should -Be 26

        }
    }

    Context "End" {

        It "Invokes the scriptblock associated with a key" {

            $Menu = [Menu]::new(@('One', 'Two', 'Three'), { $_ })

            $Menu.i = 1

            $Menu.KeyActions.Enter = { param($i, $item) return ($i + 100) }
            $Menu.KeyActions.w = { param($i, $item) return ($item) }

            $Menu.ResolveAction('Enter') | Should -Be ($Menu.i + 100)
            $Menu.ResolveAction('w') | Should -Be ('Two')

        }
    }



}