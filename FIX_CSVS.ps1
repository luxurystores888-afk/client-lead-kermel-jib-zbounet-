$dir = "C:\Users\samde\OneDrive\Desktop\client lead"
$files = Get-ChildItem -Path $dir -Filter "*.csv" -Recurse

foreach ($file in $files) {
    if ($file.FullName -match "LEADS_TRACKER" -or $file.FullName -match "organized\\LEADS_") {
        Write-Host "Cleaning: $($file.FullName)"
        
        # Read with semicolon
        $data = Import-Csv -Path $file.FullName 
        
        foreach ($row in $data) {
            if ($null -ne $row.phone_or_link) {
                # Strip all non-digits except +
                $p = $row.phone_or_link -replace "[^\d\+]",""
                
                if ($p -match "^\+(.*)") {
                    $p = "00$1"
                } elseif ($p -match "^00(.*)") {
                    $p = $p
                } elseif ($p -match "^0(.*)") {
                    $p = "00971$1"
                } elseif ($p -match "^971(.*)") {
                    $p = "00$p"
                }
                
                # Strip any stray letters or weird things, make sure only digits remain
                $p = $p -replace "[^\d]",""

                # Keep a space in front so Excel sees it strictly as text and keeps the zeros!
                $row.phone_or_link = " " + $p
            }
        }
        
        # Export with strictly COMMA
        $data | Export-Csv -Path $file.FullName -Delimiter "," -NoTypeInformation -Encoding UTF8
    }
}
Write-Host "Formatting completed perfectly."

