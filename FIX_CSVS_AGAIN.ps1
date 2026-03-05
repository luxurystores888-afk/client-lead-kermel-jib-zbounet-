$dir = "C:\Users\samde\OneDrive\Desktop\client-lead-repo-sync"
$files = Get-ChildItem -Path $dir -Filter "*.csv" -Recurse

foreach ($file in $files) {
    if ($file.FullName -match "LEADS_TRACKER" -or $file.FullName -match "organized\\LEADS_") {
        Write-Host "Formatting properly: $($file.FullName)"
        $data = Import-Csv -Path $file.FullName -Delimiter ";"
        
        foreach ($row in $data) {
            if ($null -ne $row.phone_or_link) {
                $p = $row.phone_or_link
                # Strip all non-digits except +
                $p = $p -replace "[^\d\+]",""
                
                if ($p -match "^\+(.*)") {
                    $p = "00" + $matches[1]
                } elseif ($p -match "^0(.*)") {
                    $p = "00971" + $matches[1]
                } elseif ($p -match "^971(.*)") {
                    $p = "00" + $p
                }
                
                # Strip remaining plusses if any
                $p = $p -replace "\+",""

                $row.phone_or_link = " " + $p
            }
        }
        
        $data | Export-Csv -Path $file.FullName -Delimiter ";" -NoTypeInformation -Encoding UTF8
    }
}
Write-Host "Success"
