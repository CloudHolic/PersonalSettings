Invoke-Expression (&starship init powershell)

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

function ll { eza -l --icons --git }
function la { eza -la --icons --git }
function lt { eza --tree --level=2 --icons }
Set-Alias -Name cat -Value bat

function gs { git status }
function ga { git add @args }
function gc { git commit -m @args }
function gp { git push }
function gl { git pull }
function glog { git log --oneline --graph --decorate --all }

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

function prof { notepad $PROFILE }
function reload { . $PROFILE }

function sysinfo {
	Write-Host "OS: " -NoNewline -ForegroundColor Cyan
	(Get-CimInstance Win32_OperatingSystem).Caption
	Write-Host "CPU: " -NoNewline -ForegroundColor Cyan
	(Get-CimInstnace Win32_Processor).Name
	Write-Host "RAM: " -NoNewline -ForegroundColor Cyan
	"{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
}

Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
	$result = Get-Content (Get-PSReadlineOption).HistorySavePath | fzf --tac
	if ($result) {
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
	}
}

function search-fzf-file {
	$result = fzf
	if ($result) {
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
	}
}
Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock { search-fzf-file }

Set-Alias vi nvim
Set-Alias vim nvim
$env:EDITOR = "nvim"