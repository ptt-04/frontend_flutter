# Test Cart API
Write-Host "Testing Cart API..." -ForegroundColor Green

# Wait for backend to start
Start-Sleep -Seconds 10

# Login
Write-Host "1. Logging in..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:9000/api/auth/login" -Method POST -ContentType "application/json" -Body '{"usernameOrEmail":"testuser","password":"test123"}'
$token = $loginResponse.token
Write-Host "Login successful! Token: $($token.Substring(0, 20))..." -ForegroundColor Green

# Test Get Cart
Write-Host "2. Testing Get Cart..." -ForegroundColor Yellow
try {
    $cartResponse = Invoke-RestMethod -Uri "http://localhost:9000/api/cart" -Method GET -Headers @{"Authorization"="Bearer $token"}
    Write-Host "Get Cart successful!" -ForegroundColor Green
    Write-Host "Cart items: $($cartResponse.cartItems.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "Get Cart failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Add to Cart
Write-Host "3. Testing Add to Cart..." -ForegroundColor Yellow
try {
    $addResponse = Invoke-RestMethod -Uri "http://localhost:9000/api/cart/add" -Method POST -ContentType "application/json" -Headers @{"Authorization"="Bearer $token"} -Body '{"productId":1,"quantity":1}'
    Write-Host "Add to Cart successful!" -ForegroundColor Green
} catch {
    Write-Host "Add to Cart failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Get Cart again
Write-Host "4. Testing Get Cart again..." -ForegroundColor Yellow
try {
    $cartResponse = Invoke-RestMethod -Uri "http://localhost:9000/api/cart" -Method GET -Headers @{"Authorization"="Bearer $token"}
    Write-Host "Get Cart successful!" -ForegroundColor Green
    Write-Host "Cart items: $($cartResponse.cartItems.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "Get Cart failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Cart API test completed!" -ForegroundColor Green
