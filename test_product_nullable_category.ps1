# Test tạo sản phẩm không có danh mục
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing Create Product without Category..." -ForegroundColor Green

# Test login với admin
Write-Host "`n1. Login with admin" -ForegroundColor Yellow
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
    exit 1
}

# Test tạo sản phẩm không có danh mục
Write-Host "`n2. Creating product without category" -ForegroundColor Yellow
$productData = @{
    name = "Sản phẩm test không danh mục"
    description = "Đây là sản phẩm test để kiểm tra tính năng nullable category"
    price = 50000
    categoryId = $null
    stockQuantity = 10
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/product" -Method POST -Body $productData -Headers $headers
    Write-Host "✅ Product created successfully" -ForegroundColor Green
    Write-Host "Product ID: $($createResponse.id)" -ForegroundColor Cyan
    Write-Host "Product Name: $($createResponse.name)" -ForegroundColor Cyan
    Write-Host "Category ID: $($createResponse.categoryId)" -ForegroundColor Cyan
    Write-Host "Category: $($createResponse.category)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Create product failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

# Test tạo sản phẩm có danh mục
Write-Host "`n3. Creating product with category" -ForegroundColor Yellow
$productDataWithCategory = @{
    name = "Sản phẩm test có danh mục"
    description = "Đây là sản phẩm test với danh mục"
    price = 75000
    categoryId = 1
    stockQuantity = 5
} | ConvertTo-Json

try {
    $createResponse2 = Invoke-RestMethod -Uri "$baseUrl/product" -Method POST -Body $productDataWithCategory -Headers $headers
    Write-Host "✅ Product with category created successfully" -ForegroundColor Green
    Write-Host "Product ID: $($createResponse2.id)" -ForegroundColor Cyan
    Write-Host "Product Name: $($createResponse2.name)" -ForegroundColor Cyan
    Write-Host "Category ID: $($createResponse2.categoryId)" -ForegroundColor Cyan
    Write-Host "Category Name: $($createResponse2.category.name)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Create product with category failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n✅ Product creation testing completed!" -ForegroundColor Green
