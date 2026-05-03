# build-lily58.ps1
# Simple ZMK builder for Lily58

# ============================================================================
# CONFIGURATION
# ============================================================================
$ZMK_PATH = "C:\zmk-dev\zmk"
$CONFIG_PATH = "C:\zmk-dev\silakka54-zmk-config\config"
$OUTPUT_PATH = "C:\zmk-dev\output"

# ============================================================================
# BUILD SCRIPT
# ============================================================================

Write-Host "`n=====================================================" -ForegroundColor Cyan
Write-Host "    ZMK Lily58 Builder" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Cyan

# Check if Docker is running
Write-Host "`nChecking Docker..." -ForegroundColor White
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Create output directory if missing
if (-not (Test-Path $OUTPUT_PATH)) {
    New-Item -ItemType Directory -Path $OUTPUT_PATH | Out-Null
}

# Build LEFT half
Write-Host "`nBuilding LEFT half..." -ForegroundColor Cyan
docker run --rm `
    -v "${ZMK_PATH}:/zmk" `
    -v "${CONFIG_PATH}:/config" `
    -v "${OUTPUT_PATH}:/output" `
    zmkfirmware/zmk-build-arm:3.5-branch `
    sh -c "cd /zmk && west build -d build/left -p -b nice_nano -s app/ -- -DSHIELD=lily58_left -DZMK_CONFIG=/config && cp build/left/zephyr/zmk.uf2 /output/lily58_left.uf2"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Left half complete" -ForegroundColor Green
} else {
    Write-Host "✗ Left half build failed" -ForegroundColor Red
    exit 1
}

# Build RIGHT half
Write-Host "`nBuilding RIGHT half..." -ForegroundColor Cyan
docker run --rm `
    -v "${ZMK_PATH}:/zmk" `
    -v "${CONFIG_PATH}:/config" `
    -v "${OUTPUT_PATH}:/output" `
    zmkfirmware/zmk-build-arm:3.5-branch `
    sh -c "cd /zmk && west build -d build/right -p -b nice_nano -s app/ -- -DSHIELD=lily58_right -DZMK_CONFIG=/config && cp build/right/zephyr/zmk.uf2 /output/lily58_right.uf2"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Right half complete" -ForegroundColor Green
} else {
    Write-Host "✗ Right half build failed" -ForegroundColor Red
    exit 1
}

# Success
Write-Host "`n=====================================================" -ForegroundColor Green
Write-Host "    BUILD COMPLETE!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "`nFirmware files:" -ForegroundColor White
Write-Host "  $OUTPUT_PATH\lily58_left.uf2" -ForegroundColor Cyan
Write-Host "  $OUTPUT_PATH\lily58_right.uf2" -ForegroundColor Cyan
Write-Host ""

# Open output folder
explorer $OUTPUT_PATH
