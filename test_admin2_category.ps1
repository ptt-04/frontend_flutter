# Test login with admin2 and create category
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing login with admin2 and creating category..." -ForegroundColor Green

$loginData = @{
    usernameOrEmail = "admin2"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "Username: $($loginResponse.user.username)" -ForegroundColor Cyan
    Write-Host "Role: $($loginResponse.user.role)" -ForegroundColor Cyan
    Write-Host "Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Cyan
    
    # Test creating category
    $headers = @{
        "Authorization" = "Bearer $($loginResponse.token)"
        "Content-Type" = "application/json"
    }
    
    $newCategory = @{
        name = "Test Category $(Get-Date -Format 'HHmmss')"
        description = "Test description for API testing"
        isActive = $true
    } | ConvertTo-Json

    try {
        $categoryResponse = Invoke-RestMethod -Uri "$baseUrl/category" -Method POST -Body $newCategory -Headers $headers
        Write-Host "✅ Category creation successful" -ForegroundColor Green
        Write-Host "Created category: $($categoryResponse.name) (ID: $($categoryResponse.id))" -ForegroundColor Cyan
        
        # Test GET categories to see the new one
        Write-Host "`nTesting GET categories..." -ForegroundColor Yellow
        $categories = Invoke-RestMethod -Uri "$baseUrl/category" -Method GET
        Write-Host "✅ Found $($categories.Count) categories" -ForegroundColor Green
        $categories | ForEach-Object {
            Write-Host "  - $($_.name): $($_.description) (Products: $($_.productCount))" -ForegroundColor White
        }
        
    } catch {
        Write-Host "❌ Category creation failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $responseStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($responseStream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Testing completed!" -ForegroundColor Green
