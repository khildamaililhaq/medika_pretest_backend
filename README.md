# Medika API

Aplikasi API Rails untuk mengelola produk dan kategori dengan autentikasi OAuth2.

## Persyaratan Sistem

- Ruby 3.4.7
- PostgreSQL
- Docker (untuk deployment)
- Node.js (untuk asset compilation, jika diperlukan)

## Dependensi Sistem

- PostgreSQL 17.0
- Puma sebagai web server
- Redis (untuk cache, queue, dan cable jika diperlukan)

## Instalasi dan Menjalankan Aplikasi

### Menggunakan Docker

1. Clone repository ini:
   ```bash
   git clone <repository-url>
   cd medika-pretest-api
   cp .env.example .env
   ```

2. Jalankan aplikasi dengan Docker Compose:
   ```bash
   docker compose up --build
   ```

3. Setup database dan OAuth application:
   ```bash
   ./run rails db:setup
   ./run bundle exec rake auth:setup
   ```
   Untuk integrasi dengan frontend, gunakan kredensial `client_id` dan `client_secret` OAuth diatas
   `./run rails rswag` untuk regenerate dokumentasi Swagger 2.0

## Menjalankan Aplikasi
1. Untuk melihat dokumentasi bisa diakses di link `medika_pretest.localhost/api-docs`
2. untuk mempermudah semua command CLI setelah docker container running bisa diakses menggunakan prefix `./run` contoh: `./run bundle install`


## API Dokumentasi

API documentation tersedia melalui Swagger UI di `medika_pretest.localhost/api-docs` setelah aplikasi berjalan.

Endpoint utama:
- `POST /oauth/token`: Mendapatkan access token
- `GET /api/v1/products`: Mendapatkan daftar produk
- `GET /api/v1/categories`: Mendapatkan daftar kategori
- `POST /api/v1/auth/register`: Register user

## Services

- **Job Queues**: Menggunakan Delayed Job untuk background jobs
- **Cache**: Menggunakan Solid Cache
- **Queue**: Menggunakan Solid Queue
- **Cable**: Menggunakan Solid Cable untuk WebSocket

## Keamanan dan OWASP Compliance

Aplikasi ini mengikuti prinsip-prinsip OWASP (Open Web Application Security Project) untuk memastikan keamanan aplikasi:

### 1. Authentication & Authorization
- **OAuth 2.0**: Menggunakan Doorkeeper untuk autentikasi OAuth2 dengan flow password dan refresh token
- **Devise**: Implementasi authentication yang aman dengan password complexity requirements
- **Bearer Token**: Semua endpoint API dilindungi dengan Bearer token authentication

### 2. Input Validation & Sanitization
- **Strong Parameters**: Semua input divalidasi menggunakan strong parameters di controller
- **Model Validations**: Validasi presence dan uniqueness di model level
- **Parameter Filtering**: Sensitive data difilter dari log menggunakan `filter_parameter_logging`

### 3. Data Protection
- **Password Hashing**: Password di-hash menggunakan bcrypt dengan stretching factor yang sesuai
- **UUID Primary Keys**: Menggunakan UUID untuk primary keys untuk menghindari enumeration attacks
- **Database Encryption**: Data sensitif dienkripsi di database level

### 4. Access Control
- **CORS Configuration**: CORS dikonfigurasi dengan ketat, hanya mengizinkan origins tertentu di production
- **Rate Limiting**: Implementasi rate limiting untuk mencegah abuse
- **Session Management**: Session dikelola dengan aman menggunakan Devise

### 6. Error Handling & Logging
- **Error Sanitization**: Error messages tidak mengungkap informasi sensitif
- **Secure Logging**: Sensitive parameters difilter dari application logs
- **Health Checks**: Endpoint `/up` untuk monitoring tanpa mengungkap informasi sistem

### 7. Dependency Management
- **Bundle Audit**: Regular dependency scanning untuk vulnerabilities
- **Security Updates**: Dependencies menggunakan versi terbaru

### 8. Infrastructure Security
- **Docker Security**: Container dijalankan dengan non-root user
- **Environment Variables**: Konfigurasi sensitif menggunakan environment variables
- **Database Security**: Database credentials tidak di-hardcode

## Security Tools & Configurations

### Static Analysis
```bash
# Unit Test
./run test

# Security vulnerability scanning
./run bundle exec brakeman

# Code quality and security
./run bundle exec rubocop
```

### Testing
- **RSpec**: Comprehensive test suite dengan security-focused tests
- **Factory Bot**: Secure test data generation
- **Shoulda Matchers**: Validation testing

### Monitoring & Alerting
- **Health Checks**: Application health monitoring
- **Error Tracking**: Centralized error logging
- **Performance Monitoring**: Response time dan throughput monitoring