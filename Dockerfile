# Stage 1: Build assets
FROM node:18 as node-build
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Stage 2: PHP + Laravel
FROM php:8.2-fpm

# Cài extension PHP
RUN apt-get update && apt-get install -y \
    libonig-dev libxml2-dev zip unzip curl git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath

# Cài Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Cài Laravel
RUN composer install --optimize-autoloader --no-dev

# Copy assets đã build từ node
COPY --from=node-build /app/public/build /var/www/public/build

# Cổng Railway yêu cầu
EXPOSE 9000

# Start Laravel app
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=9000"]
# Sử dụng image PHP + NodeJS để build frontend
FROM node:18 as build-stage
WORKDIR /app
COPY . .
RUN npm install && npm run prod

# Copy files sang container chính
FROM php:8.2-fpm
WORKDIR /var/www/html
COPY --from=build-stage /app/public /var/www/html/public
