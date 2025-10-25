# Test và tạo admin user
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing Admin User Creation..." -ForegroundColor Green

# Test đăng ký admin user
Write-Host "`n1. Registering admin user" -ForegroundColor Yellow
$registerData = @{
    username = "admin"
    email = "admin@barbershop.com"
    password = "admin123"
    firstName = "Admin"
    lastName = "User"
    phoneNumber = "0123456789"
    dateOfBirth = "1990-01-01T00:00:00Z"
    gender = "Male"
    role = 3
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Admin user registered successfully" -ForegroundColor Green
    Write-Host "Username: $($registerResponse.user.username)" -ForegroundColor Cyan
    Write-Host "Role: $($registerResponse.user.role)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Register failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

# Test login với admin
Write-Host "`n2. Login with admin" -ForegroundColor Yellow
$loginData = @{
    usernameOrEmail = "admin"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "Username: $($loginResponse.user.username)" -ForegroundColor Cyan
    Write-Host "Role: $($loginResponse.user.role)" -ForegroundColor Cyan
    
    $headers = @{
        "Authorization" = "Bearer $($loginResponse.token)"
        "Content-Type" = "application/json"
    }
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`n✅ Admin user setup completed!" -ForegroundColor Green
