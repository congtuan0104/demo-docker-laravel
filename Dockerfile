# Sử dụng image PHP chính thức với Apache
FROM php:8.1-apache

# Thiết lập các biến môi trường
ENV DEBIAN_FRONTEND noninteractive

# Cài đặt các phần mở rộng PHP và các công cụ cần thiết
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Kích hoạt module Apache mod_rewrite
RUN a2enmod rewrite

# Thiết lập thư mục làm việc
WORKDIR /var/www/html

# Sao chép tệp composer.json và composer.lock trước khi sao chép mã nguồn
COPY composer.json composer.lock ./

# Chạy Composer để cài đặt các phụ thuộc
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist || { cat /var/www/html/composer.log && false; }

# Sao chép mã nguồn vào container
COPY . .

# Thiết lập quyền truy cập
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Lệnh để chạy container
CMD ["apache2-foreground"]
