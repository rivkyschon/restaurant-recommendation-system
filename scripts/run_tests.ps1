# run_tests.ps1

# Function to check if a command exists
function Command-Exists {
    param (
        [string]$command
    )
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

# Check if Python is installed
if (-not (Command-Exists python)) {
    Write-Error "Python is not installed. Please install Python and try again."
    exit 1
}

# Navigate to the backend directory
Set-Location -Path "..\api"

# Run tests
Write-Output "Running unit tests..."
python -m unittest discover tests
if ($?) {
    Write-Output "Unit tests completed successfully."
} else {
    Write-Error "Unit tests failed."
    exit 1
}

Write-Output "Test runner script completed successfully."
