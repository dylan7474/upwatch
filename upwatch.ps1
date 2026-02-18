# ---------------------------------------------------------------------------
# NETWORK SENTINEL - POWERSHELL GUI EDITION
# Hyper-futuristic Site Monitor with Real-time Latency & Status Logs
# ---------------------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Configuration & State ---
$script:MaxSites = 5
$script:Sites = @() # List of custom objects: { URL, Status, History, RowIndex }
$script:PingInterval = 5 # Seconds
$script:ConfigPath = "$HOME\sentinel_config.json"

# --- UI Theme Colors ---
$color_bg      = [System.Drawing.Color]::FromArgb(5, 5, 5)
$color_panel   = [System.Drawing.Color]::FromArgb(15, 15, 20)
$color_cyan    = [System.Drawing.Color]::FromArgb(0, 243, 255)
$color_magenta = [System.Drawing.Color]::FromArgb(255, 0, 255)
$color_text    = [System.Drawing.Color]::FromArgb(226, 232, 240)
$color_gray    = [System.Drawing.Color]::FromArgb(51, 65, 85)

# --- Form Initialization ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "NEURAL-LINK | Network Sentinel"
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.BackColor = $color_bg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Font = New-Object System.Drawing.Font("Consolas", 10)

# --- Header ---
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "NETWORK SENTINEL_v4.0"
$lblTitle.Font = New-Object System.Drawing.Font("Impact", 24)
$lblTitle.ForeColor = $color_text
$lblTitle.Location = New-Object System.Drawing.Point(20, 20)
$lblTitle.AutoSize = $true
$form.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "STATUS: SYSTEM_LIVE // DATAFEED_ACTIVE"
$lblSub.Font = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Bold)
$lblSub.ForeColor = $color_cyan
$lblSub.Location = New-Object System.Drawing.Point(23, 60)
$lblSub.AutoSize = $true
$form.Controls.Add($lblSub)

# --- Monitoring Table (DataGridView) ---
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Size = New-Object System.Drawing.Size(580, 350)
$grid.Location = New-Object System.Drawing.Point(20, 100)
$grid.BackgroundColor = $color_panel
$grid.ForeColor = $color_text
$grid.GridColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
$grid.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$grid.AllowUserToAddRows = $false
$grid.RowHeadersVisible = $false
$grid.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$grid.ReadOnly = $true
$grid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$grid.DefaultCellStyle.BackColor = $color_panel
$grid.ColumnHeadersDefaultCellStyle.BackColor = $color_bg
$grid.ColumnHeadersDefaultCellStyle.ForeColor = $color_cyan
$grid.EnableHeadersVisualStyles = $false

$grid.Columns.Add("Status", "NODE") | Out-Null
$grid.Columns.Add("URL", "PROTOCOL / ADDR") | Out-Null
$grid.Columns.Add("Latency", "LATENCY_RTT") | Out-Null
$grid.Columns[0].Width = 80
$form.Controls.Add($grid)

# --- Input Section ---
$txtUrl = New-Object System.Windows.Forms.TextBox
$txtUrl.Location = New-Object System.Drawing.Point(20, 470)
$txtUrl.Size = New-Object System.Drawing.Size(460, 40)
$txtUrl.BackColor = [System.Drawing.Color]::Black
$txtUrl.ForeColor = $color_cyan
$txtUrl.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$txtUrl.Font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($txtUrl)

$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "INJECT_NODE"
$btnAdd.Location = New-Object System.Drawing.Point(490, 470)
$btnAdd.Size = New-Object System.Drawing.Size(110, 30)
$btnAdd.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnAdd.FlatAppearance.BorderColor = $color_cyan
$btnAdd.ForeColor = $color_cyan
$form.Controls.Add($btnAdd)

$btnRemove = New-Object System.Windows.Forms.Button
$btnRemove.Text = "PURGE_NODE"
$btnRemove.Location = New-Object System.Drawing.Point(490, 510)
$btnRemove.Size = New-Object System.Drawing.Size(110, 30)
$btnRemove.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRemove.FlatAppearance.BorderColor = $color_magenta
$btnRemove.ForeColor = $color_magenta
$form.Controls.Add($btnRemove)

# --- Sidebar: Event Log ---
$lblLogTitle = New-Object System.Windows.Forms.Label
$lblLogTitle.Text = "EVENT_STREAM"
$lblLogTitle.ForeColor = $color_magenta
$lblLogTitle.Location = New-Object System.Drawing.Point(620, 100)
$lblLogTitle.AutoSize = $true
$form.Controls.Add($lblLogTitle)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location = New-Object System.Drawing.Point(620, 125)
$txtLog.Size = New-Object System.Drawing.Size(240, 325)
$txtLog.BackColor = $color_panel
$txtLog.ForeColor = [System.Drawing.Color]::LightSlateGray
$txtLog.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$txtLog.ReadOnly = $true
$form.Controls.Add($txtLog)

# --- Save/Load Config Buttons ---
$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = "UPLOAD_CONFIG"
$btnSave.Location = New-Object System.Drawing.Point(750, 20)
$btnSave.Size = New-Object System.Drawing.Size(110, 30)
$btnSave.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnSave.ForeColor = $color_cyan
$form.Controls.Add($btnSave)

# --- Functions ---

function Add-Log {
    param([string]$Message, [System.Drawing.Color]$Color)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $txtLog.SelectionStart = 0
    $txtLog.SelectionLength = 0
    $txtLog.SelectionColor = $Color
    $txtLog.SelectedText = "> [$timestamp] $Message`r`n"
}

function Update-Grid {
    $grid.Rows.Clear()
    foreach ($s in $script:Sites) {
        $rowIdx = $grid.Rows.Add($s.Status, $s.URL, $s.Latency)
        if ($s.Status -eq "GREEN") { $grid.Rows[$rowIdx].Cells[0].Style.ForeColor = [System.Drawing.Color]::Lime }
        elseif ($s.Status -eq "AMBER") { $grid.Rows[$rowIdx].Cells[0].Style.ForeColor = [System.Drawing.Color]::Orange }
        elseif ($s.Status -eq "RED") { $grid.Rows[$rowIdx].Cells[0].Style.ForeColor = [System.Drawing.Color]::Red }
    }
}

function Save-Config {
    $data = $script:Sites | Select-Object URL
    $data | ConvertTo-Json | Out-File $script:ConfigPath
    Add-Log "CONFIG_SYNCED_TO_DISK" $color_cyan
}

function Load-Config {
    if (Test-Path $script:ConfigPath) {
        $json = Get-Content $script:ConfigPath | ConvertFrom-Json
        # Check if json is a single object or an array
        $items = if ($json -is [array]) { $json } else { @($json) }
        foreach ($item in $items) {
            $script:Sites += [PSCustomObject]@{
                URL = $item.URL
                Status = "GRAY"
                History = @()
                Latency = "OFFLINE"
            }
        }
        Update-Grid
        Add-Log "RESTORED_NODES_FROM_STORAGE" $color_cyan
    }
}

$btnAdd.Add_Click({
    $url = $txtUrl.Text.Trim()
    if ($url -eq "") { return }
    if ($script:Sites.Count -ge $script:MaxSites) { 
        Add-Log "ERR: BUFFER_OVERFLOW" $color_magenta 
        return 
    }
    
    $script:Sites += [PSCustomObject]@{
        URL = $url
        Status = "GRAY"
        History = @()
        Latency = "WAITING..."
    }
    $txtUrl.Text = ""
    Update-Grid
    Add-Log "INJECTED: $url" $color_cyan
})

$btnRemove.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $selectedUrl = $grid.SelectedRows[0].Cells[1].Value
        $script:Sites = $script:Sites | Where-Object { $_.URL -ne $selectedUrl }
        Update-Grid
        Add-Log "PURGED: $selectedUrl" $color_magenta
    }
})

$btnSave.Add_Click({ Save-Config })

# --- Monitoring Loop (Timer) ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $script:PingInterval * 1000
$timer.Add_Tick({
    foreach ($site in $script:Sites) {
        # Basic cleanup: remove protocol and trailing slashes for Test-Connection
        $cleanUrl = $site.URL -replace "^https?://", ""
        $cleanUrl = $cleanUrl.Split('/')[0] 
        
        try {
            $ping = Test-Connection -ComputerName $cleanUrl -Count 1 -ErrorAction Stop
            $site.Latency = "$($ping.ResponseTime) MS"
            $site.History += $true
        } catch {
            $site.Latency = "DROPPED"
            $site.History += $false
        }

        # Maintain window of last 12 samples (approx 1 minute at 5s interval)
        if ($site.History.Count -gt 12) { $site.History = $site.History[-12..-1] }

        # Logic: 
        # AMBER: > 3 drops in last 30s (approx 6 samples)
        # RED: > 10 drops in last 1min (approx 12 samples)
        $last6 = $site.History | Select-Object -Last 6
        $drops30s = ($last6 | Where-Object { $_ -eq $false }).Count
        $drops60s = ($site.History | Where-Object { $_ -eq $false }).Count

        $newStatus = "GREEN"
        if ($drops60s -ge 10) { $newStatus = "RED" }
        elseif ($drops30s -ge 3) { $newStatus = "AMBER" }

        if ($site.Status -ne $newStatus) {
            Add-Log "STATE_SHIFT [$cleanUrl]: $($site.Status) >> $newStatus" ([System.Drawing.Color]::White)
            $site.Status = $newStatus
        }
    }
    Update-Grid
})

# --- Entry Point ---
Load-Config
$timer.Start()
Add-Log "SENTINEL_CORE_INITIALIZED" $color_cyan
$form.ShowDialog() | Out-Null
