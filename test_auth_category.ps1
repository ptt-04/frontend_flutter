# Test Authentication và Category API
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing Authentication and Category API..." -ForegroundColor Green

# Test login first
Write-Host "`n1. Testing Login" -ForegroundColor Yellow
$loginData = @{
    usernameOrEmail = "admin"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Cyan
    
    $token = $loginResponse.token
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    $token = $null
    $headers = @{
        "Content-Type" = "application/json"
    }
}

# Test GET Categories (should work without auth)
Write-Host "`n2. Testing GET /category" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/category" -Method GET
    Write-Host "✅ GET Categories successful" -ForegroundColor Green
    Write-Host "Found $($response.Count) categories" -ForegroundColor Cyan
} catch {
    Write-Host "❌ GET Categories failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test POST Category (requires auth)
if ($token) {
    Write-Host "`n3. Testing POST /category with authentication" -ForegroundColor Yellow
    $newCategory = @{
        name = "Test Category $(Get-Date -Format 'HHmmss')"
        description = "Test description for API testing"
        isActive = $true
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/category" -Method POST -Body $newCategory -Headers $headers
        Write-Host "✅ POST Category successful" -ForegroundColor Green
        Write-Host "Created category: $($response.name) (ID: $($response.id))" -ForegroundColor Cyan
        $newCategoryId = $response.id
    } catch {
        Write-Host "❌ POST Category failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
        $newCategoryId = $null
    }
} else {
    Write-Host "`n3. Skipping POST Category test (no token)" -ForegroundColor Yellow
}

Write-Host "`n✅ Authentication and Category API testing completed!" -ForegroundColor Green
