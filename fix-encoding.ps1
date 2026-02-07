$f = 'c:\git\thisismydemo.github.io\content\post\2026-02-18-the-myth-of-old-tech.md'
$bytes = [System.IO.File]::ReadAllBytes($f)

# Double-encoded UTF-8 fix:
# Read as UTF-8 -> encode as CP1252 to recover original bytes -> decode as UTF-8
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$cp1252 = [System.Text.Encoding]::GetEncoding(1252)
$originalBytes = $cp1252.GetBytes($text)
$fixed = [System.Text.Encoding]::UTF8.GetString($originalBytes)

Write-Host "Has checkmark: $($fixed.Contains([char]0x2705))"
Write-Host "Has cross: $($fixed.Contains([char]0x274C))"
Write-Host "Has emdash: $($fixed.Contains([char]0x2014))"
Write-Host "Has arrow-r: $($fixed.Contains([char]0x2192))"
Write-Host "Has arrow-l: $($fixed.Contains([char]0x2190))"

$idx = $fixed.IndexOf("Basic Live Migration")
if ($idx -gt 0) {
    Write-Host "Sample: $($fixed.Substring($idx, 80))"
}

$utf8noBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($f, $fixed, $utf8noBom)
Write-Host "File saved successfully."
