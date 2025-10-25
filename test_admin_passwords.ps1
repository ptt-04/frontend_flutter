# Test different admin passwords
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing Admin Login with different passwords..." -ForegroundColor Green

$passwords = @("admin123", "admin", "password", "123456", "Admin123", "admin@123")

foreach ($password in $passwords) {
    Write-Host "`nTesting password: $password" -ForegroundColor Yellow
    
    $loginData = @{
        usernameOrEmail = "admin"
        password = $password
    } | ConvertTo-Json

    try {
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
        Write-Host "✅ Login successful with password: $password" -ForegroundColor Green
        Write-Host "Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Cyan
        Write-Host "Role: $($loginResponse.user.role)" -ForegroundColor Cyan
        
        # Test creating category with this token
        $headers = @{
            "Authorization" = "Bearer $($loginResponse.token)"
            "Content-Type" = "application/json"
        }
        
        $newCategory = @{
            name = "Test Category $(Get-Date -Format 'HHmmss')"
            description = "Test description"
            isActive = $true
        } | ConvertTo-Json

        try {
            $categoryResponse = Invoke-RestMethod -Uri "$baseUrl/category" -Method POST -Body $newCategory -Headers $headers
            Write-Host "✅ Category creation successful" -ForegroundColor Green
            Write-Host "Created category: $($categoryResponse.name) (ID: $($categoryResponse.id))" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Category creation failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        break
    } catch {
        Write-Host "❌ Login failed with password: $password" -ForegroundColor Red
    }
}

Write-Host "`n✅ Password testing completed!" -ForegroundColor Green
