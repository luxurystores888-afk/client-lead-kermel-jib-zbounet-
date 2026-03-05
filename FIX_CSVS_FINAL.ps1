$dir = "C:\Users\samde\OneDrive\Desktop\client-lead-repo-sync"
$files = Get-ChildItem -Path $dir -Filter "*.csv" -Recurse

foreach ($file in $files) {
    if ($file.FullName -match "LEADS_TRACKER" -or $file.FullName -match "organized\\LEADS_") {
        Write-Host "Formatting properly: $($file.FullName)"
        $data = Import-Csv -Path $file.FullName -Delimiter ";"
        
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

                $row.phone_or_link = " " + $p
            }
        }
        
        $data | Export-Csv -Path $file.FullName -Delimiter ";" -NoTypeInformation -Encoding UTF8
    }
}
Write-Host "Success"
