param ([Parameter(Mandatory=$true, Position=0)][string]$GitRepo)

$GitRepo = $GitRepo.TrimEnd('\','/')

if (-not (Test-Path $GitRepo)) {
    Write-Error "Git directory not found: $GitRepo"
    exit 1
}

if (-not (Test-Path (Join-Path $GitRepo ".git"))) {
    Write-Error "Provided directory does not appear to be a Git repo: $GitRepo"
    exit 1
}

$DirName = Split-Path $GitRepo -Leaf
$VenvPath = Join-Path $HOME ".venv\$DirName"
$Requirements = Join-Path $GitRepo "requirements.txt"

if ((Test-Path $VenvPath) -and (-not (Test-Path (Join-Path $VenvPath "pyvenv.cfg")))) {
    Write-Error "VENV path does not appear to be a VENV: $VenvPath"
    exit 1
}

if (Test-Path (Join-Path $VenvPath "pyvenv.cfg")) {
    Write-Host "Deleting existing virtual environment at $VenvPath..."
    Remove-Item -Recurse -Force $VenvPath
}

Write-Host "Creating virtual environment at $VenvPath..."
python -m venv $VenvPath

if (Test-Path $Requirements) {
    Write-Host "Installing dependencies from $Requirements..."
    & "$VenvPath\Scripts\python.exe" -m pip install --upgrade pip
    & "$VenvPath\Scripts\python.exe" -m pip install -r $Requirements
} else {
    Write-Host "No requirements.txt found in $GitRepo, continuing without..."
}

Write-Host "Virtual environment setup complete."
