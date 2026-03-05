param(
  [string]$OutCsv = ".\\LEADS_TRACKER_1000_UAE.csv",
  [int]$Target = 1000,
  [int]$MaxProfilesToScan = 6000,
  [int]$ProfileSitemapStart = 1,
  [int]$ProfileSitemapEnd = 42
)

$ErrorActionPreference = "Stop"

function Normalize-UaePhone {
  param([string]$Phone)
  if ([string]::IsNullOrWhiteSpace($Phone)) { return $null }

  $p = $Phone.Trim()
  $p = $p -replace "[^0-9+]", ""

  if ($p -match "^00971") { $p = "+971" + $p.Substring(5) }
  elseif ($p -match "^971") { $p = "+$p" }
  elseif ($p -match "^0\d+") { $p = "+971" + $p.Substring(1) }
  elseif ($p -match "^\d+") { $p = "+$p" }

  if ($p -notmatch "^\+971\d{7,9}$") { return $null }
  return $p
}

function Get-ProfileUrls {
  param([int]$Start, [int]$End)

  $all = New-Object System.Collections.Generic.List[string]
  for ($i = $Start; $i -le $End; $i++) {
    $smUrl = "https://www.yellowpages-uae.com/sitemap/profile/profile-$i.xml"
    try {
      [xml]$xml = (Invoke-WebRequest -Uri $smUrl -UseBasicParsing -TimeoutSec 60).Content
      $urls = @($xml.urlset.url.loc)
      foreach ($u in $urls) {
        if ($u) { $all.Add($u) }
      }
    }
    catch {
      continue
    }
  }

  return $all
}

function Parse-ProfilePage {
  param([string]$Url)

  $html = (Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 45).Content

  $name = ""
  $nameMatch = [regex]::Match($html, '<h1[^>]*>(?<n>.*?)</h1>', 'Singleline')
  if ($nameMatch.Success) {
    $name = ($nameMatch.Groups['n'].Value -replace '<[^>]+>', '').Trim()
  }

  if ([string]::IsNullOrWhiteSpace($name)) {
    return @()
  }

  $city = "UAE"
  $cityMatch = [regex]::Match($html, 'City\s*:\s*</span><span>(?<c>[^<]+)</span>', 'IgnoreCase')
  if ($cityMatch.Success -and -not [string]::IsNullOrWhiteSpace($cityMatch.Groups['c'].Value)) {
    $city = $cityMatch.Groups['c'].Value.Trim()
  }

  $phonesRaw = [regex]::Matches($html, 'tel:\+?\d[\d\-\s]{6,16}') |
    ForEach-Object { $_.Value -replace '^tel:', '' } |
    Sort-Object -Unique

  $phones = New-Object System.Collections.Generic.List[string]
  foreach ($pr in $phonesRaw) {
    $pn = Normalize-UaePhone -Phone $pr
    if ($pn -and $pn -ne '+97142832133') {
      $phones.Add($pn)
    }
  }

  $phones = $phones | Sort-Object -Unique
  if (-not $phones -or $phones.Count -eq 0) {
    return @()
  }

  $rows = @()
  foreach ($p in $phones) {
    $phoneType = if ($p -match '^\+9715\d{8}$') { 'mobile' } else { 'landline_or_tollfree' }
    $rows += [pscustomobject]@{
      date          = (Get-Date -Format 'yyyy-MM-dd')
      lead_name     = $name
      business      = $name
      area          = $city
      phone_or_link = $p
      channel       = 'WhatsApp'
      status        = 'NEW'
      next_action   = 'Review and send compliant outreach'
      next_date     = (Get-Date -Format 'yyyy-MM-dd')
      notes         = "YellowPages UAE profile | $phoneType | $Url"
    }
  }

  return $rows
}

$profileUrls = Get-ProfileUrls -Start $ProfileSitemapStart -End $ProfileSitemapEnd
if (-not $profileUrls -or $profileUrls.Count -eq 0) {
  throw 'No profile URLs found from sitemap.'
}

$profileUrls = $profileUrls | Select-Object -First $MaxProfilesToScan

$leads = New-Object System.Collections.Generic.List[object]
$seen = @{}
$scanned = 0

foreach ($url in $profileUrls) {
  if ($leads.Count -ge $Target) { break }

  try {
    $rows = Parse-ProfilePage -Url $url
    foreach ($r in $rows) {
      $key = ($r.business.Trim().ToLowerInvariant() + '|' + $r.phone_or_link)
      if ($seen.ContainsKey($key)) { continue }
      $seen[$key] = $true
      $leads.Add($r)
      if ($leads.Count -ge $Target) { break }
    }
  }
  catch {
    # Skip pages that fail due to network or parsing issues.
  }

  $scanned++
  if ($scanned % 200 -eq 0) {
    Write-Host "Scanned $scanned profiles | leads: $($leads.Count)"
  }
}

if ($leads.Count -eq 0) {
  throw 'No leads extracted from profile pages.'
}

$final = $leads | Sort-Object area, business, phone_or_link
if ($final.Count -gt $Target) {
  $final = $final | Select-Object -First $Target
}

$final | Export-Csv -Path $OutCsv -Delimiter ";" -NoTypeInformation -Encoding UTF8
Write-Host "Saved $($final.Count) leads to $OutCsv"
