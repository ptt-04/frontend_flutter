# Tạo admin user mới
$baseUrl = "http://localhost:9000/api"

Write-Host "Creating new admin user..." -ForegroundColor Green

# Đăng ký admin user mới
$registerData = @{
    username = "admin3"
    email = "admin3@barbershop.com"
    password = "admin123"
    firstName = "Admin"
    lastName = "Three"
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
    
    # Login với admin3
    Write-Host "`nLogging in with admin3..." -ForegroundColor Yellow
    $loginData = @{
        usernameOrEmail = "admin3"
        password = "admin123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "Username: $($loginResponse.user.username)" -ForegroundColor Cyan
    Write-Host "Role: $($loginResponse.user.role)" -ForegroundColor Cyan
    
    $headers = @{
        "Authorization" = "Bearer $($loginResponse.token)"
        "Content-Type" = "application/json"
    }
    
    # Test tạo sản phẩm không có danh mục
    Write-Host "`nTesting Create Product without Category..." -ForegroundColor Yellow
    $productData = @{
        name = "Sản phẩm test không danh mục"
        description = "Đây là sản phẩm test để kiểm tra tính năng nullable category"
        price = 50000
        categoryId = $null
        stockQuantity = 10
    } | ConvertTo-Json
    
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/product" -Method POST -Body $productData -Headers $headers
    Write-Host "✅ Product created successfully" -ForegroundColor Green
    Write-Host "Product ID: $($createResponse.id)" -ForegroundColor Cyan
    Write-Host "Product Name: $($createResponse.name)" -ForegroundColor Cyan
    Write-Host "Category ID: $($createResponse.categoryId)" -ForegroundColor Cyan
    Write-Host "Category: $($createResponse.category)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n✅ Testing completed!" -ForegroundColor Green
