# Register Admin User
$baseUrl = "http://localhost:9000/api"

Write-Host "Registering Admin User..." -ForegroundColor Green

$registerData = @{
    username = "admin"
    email = "admin@barbershop.com"
    password = "admin123"
    firstName = "Admin"
    lastName = "User"
    phoneNumber = "0123456789"
    dateOfBirth = "1990-01-01T00:00:00Z"
    gender = "Male"
    role = 1  # Admin role
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Admin user registered successfully" -ForegroundColor Green
    Write-Host "Username: $($response.user.username)" -ForegroundColor Cyan
    Write-Host "Email: $($response.user.email)" -ForegroundColor Cyan
    Write-Host "Role: $($response.user.role)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n✅ Registration completed!" -ForegroundColor Green
