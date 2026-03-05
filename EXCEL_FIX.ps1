$dir = "C:\Users\samde\OneDrive\Desktop\client-lead-repo-sync"
$files = Get-ChildItem -Path $dir -Filter "*.csv" -Recurse

foreach ($file in $files) {
    if ($file.FullName -match "LEADS_TRACKER" -or $file.FullName -match "organized\\LEADS_") {
        Write-Host "Fixing strictly for Excel: $($file.FullName)"
        
        # Read normally
        $data = Import-Csv -Path $file.FullName -Delimiter ";"
        
        # Let's save it back but explicitly inject "sep=;" at the VERY first line.
        # This is the universally recognized Excel trick to force column separation.
        # Also let's force the phone string formatting strictly.
        
        foreach ($row in $data) {
            if ($null -ne $row.phone_or_link) {
                # Trim spaces
                $p = $row.phone_or_link.Trim()
                
                # Check formatting explicitly!
                if ($p -match "^\+971(.*)") {
                    $p = "00971" + $matches[1]
                } elseif ($p -match "^00971(.*)") {
                    # keep it
                } elseif ($p -match "^05(.*)") {
                    $p = "009715" + $matches[1]
                } elseif ($p -match "^971(.*)") {
                    $p = "00971" + $matches[1]
                }
                
                # Strip spaces and pluses just in case
                $p = $p -replace "[^\d]",""

                # Ensure only ONE prefix
                if ($p -match "^00971971(.*)") { $p = "00971" + $matches[1] } 

                # Tell Excel THIS IS A FORMULA STRING so it NEVER eats the zeros or messes it up
                $row.phone_or_link = "=""" + $p + """"
            }
        }
        
        # Export as standard comma first
        $data | Export-Csv -Path $file.FullName -Delimiter "," -NoTypeInformation -Encoding UTF8
        
        # Then prepend 'sep=,' so Excel opens it with commas immediately regardless of region settings
        $content = "sep=,`r`n" + (Get-Content $file.FullName -Raw)
        $content | Set-Content $file.FullName -Encoding UTF8
    }
}
Write-Host "Excel fix applied."
