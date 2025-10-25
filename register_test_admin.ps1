# Register new admin user
$baseUrl = "http://localhost:9000/api"

Write-Host "Registering new Admin User..." -ForegroundColor Green

$registerData = @{
    username = "admin2"
    email = "admin2@barbershop.com"
    password = "admin123"
    firstName = "Admin"
    lastName = "User"
    phoneNumber = "0123456789"
    dateOfBirth = "1990-01-01T00:00:00Z"
    gender = "Male"
    role = 3  # Admin role
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Admin user registered successfully" -ForegroundColor Green
    Write-Host "Username: $($response.user.username)" -ForegroundColor Cyan
    Write-Host "Email: $($response.user.email)" -ForegroundColor Cyan
    Write-Host "Role: $($response.user.role)" -ForegroundColor Cyan
    
    # Test login immediately
    Write-Host "`nTesting login with new admin..." -ForegroundColor Yellow
    $loginData = @{
        usernameOrEmail = "admin2"
        password = "admin123"
    } | ConvertTo-Json

    try {
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
        Write-Host "✅ Login successful" -ForegroundColor Green
        Write-Host "Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Cyan
        
        # Test creating category
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
        
    } catch {
        Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n✅ Registration and testing completed!" -ForegroundColor Green
