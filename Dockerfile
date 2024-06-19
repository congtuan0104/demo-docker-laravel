# Sử dụng hình ảnh PHP chính thức với Apache
FROM php:8.2-apache

# Cài đặt các phần mở rộng PHP cần thiết
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring pdo pdo_mysql zip \
    && curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs
    

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Sao chép nội dung dự án vào container
COPY . /var/www/html

# Sao chép tệp cấu hình Apache vào container
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Đặt quyền cho thư mục
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Thiết lập thư mục làm việc
WORKDIR /var/www/html

# Chạy Composer để cài đặt các gói PHP
RUN composer install

# Cài đặt các gói Node.js
RUN npm install

# Copy tệp .env.example thành .env và thiết lập APP_KEY
RUN cp .env.example .env
RUN php artisan key:generate

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]
