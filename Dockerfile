# =========================
# 1. Base PHP image
# =========================
FROM php:8.2-fpm

# =========================
# 2. Install system deps
# =========================
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    nginx \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd \
    && apt-get clean

# =========================
# 3. Install Composer
# =========================
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# =========================
# 4. Set working directory
# =========================
WORKDIR /var/www/html

# =========================
# 5. Copy Laravel files
# =========================
COPY . .

# =========================
# 6. Install PHP dependencies
# =========================
RUN composer install --no-dev --optimize-autoloader

# =========================
# 7. Permissions
# =========================
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# =========================
# 8. Nginx config
# =========================
COPY docker/nginx.conf /etc/nginx/sites-available/default

# =========================
# 9. Expose port
# =========================
EXPOSE 80

# =========================
# 10. Start services
# =========================
CMD service nginx start && php-fpm
