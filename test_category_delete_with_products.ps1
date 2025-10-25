# Test Category Delete with Products
$baseUrl = "http://localhost:9000/api"

Write-Host "Testing Category Delete with Products..." -ForegroundColor Green

# Test login with admin2
Write-Host "`n1. Login with admin2" -ForegroundColor Yellow
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
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test GET categories to see current state
Write-Host "`n2. Current Categories" -ForegroundColor Yellow
try {
    $categories = Invoke-RestMethod -Uri "$baseUrl/category" -Method GET
    Write-Host "✅ Found $($categories.Count) categories" -ForegroundColor Green
    $categories | ForEach-Object {
        Write-Host "  - $($_.name): $($_.description) (Products: $($_.productCount))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ GET Categories failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test GET products to see current state
Write-Host "`n3. Current Products" -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "$baseUrl/product" -Method GET
    Write-Host "✅ Found $($products.Count) products" -ForegroundColor Green
    $products | ForEach-Object {
        $categoryName = if ($_.category) { $_.category.name } else { "No Category" }
        Write-Host "  - $($_.name): $categoryName (CategoryId: $($_.categoryId))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ GET Products failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test DELETE a category that has products
Write-Host "`n4. Testing DELETE category with products" -ForegroundColor Yellow
# Find a category with products
$categoryWithProducts = $categories | Where-Object { $_.productCount -gt 0 } | Select-Object -First 1

if ($categoryWithProducts) {
    Write-Host "Deleting category: $($categoryWithProducts.name) (has $($categoryWithProducts.productCount) products)" -ForegroundColor Cyan
    
    try {
        $deleteResponse = Invoke-RestMethod -Uri "$baseUrl/category/$($categoryWithProducts.id)" -Method DELETE -Headers $headers
        Write-Host "✅ DELETE Category successful" -ForegroundColor Green
        Write-Host "Response: $($deleteResponse.message)" -ForegroundColor Cyan
        Write-Host "Products affected: $($deleteResponse.productsAffected)" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ DELETE Category failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $responseStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($responseStream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No category with products found to test delete" -ForegroundColor Yellow
}

# Test GET products after deletion to see if CategoryId is null
Write-Host "`n5. Products after category deletion" -ForegroundColor Yellow
try {
    $productsAfter = Invoke-RestMethod -Uri "$baseUrl/product" -Method GET
    Write-Host "✅ Found $($productsAfter.Count) products" -ForegroundColor Green
    $productsAfter | ForEach-Object {
        $categoryName = if ($_.category) { $_.category.name } else { "No Category" }
        Write-Host "  - $($_.name): $categoryName (CategoryId: $($_.categoryId))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ GET Products failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Category Delete with Products testing completed!" -ForegroundColor Green
