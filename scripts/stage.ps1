param ($stage)

$manifest = Get-Content -Raw .\manifest.in

if ($stage -eq 'prod') {
    $override = [PSCustomObject]@{
        bs_const = "enableProxy=false"
        localConfig = "false"
        debugLevel = "0"
    }
} elseif ($stage -eq 'dev') {
    $override = [PSCustomObject]@{
        bs_const = "enableProxy=true"
        localConfig = "false"
        debugLevel = "1"
    }
} else {
    Write-Error "Invalid stage: $stage"
    exit 1
}

# Split the content into lines and process each line
$modifiedLines = $manifest -split "`n" | ForEach-Object {
    $line = $_

    if ($line -match '^(.*)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()

        if ($override.$key -eq $null) {
            $line
        } else {
            $value = $override.$key
            "$key=$value"
        }
    }
}

$modifiedLines | Set-Content -Path .\manifest