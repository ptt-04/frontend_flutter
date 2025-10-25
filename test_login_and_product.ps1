# Test login với admin2
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing Login with admin2..." -ForegroundColor Green

$loginData = @{
    usernameOrEmail = "admin2"
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
