# docker-laravel-oracle

- PHP 7.3
- Oracle Instant Client 11


    docker build . -t php:7.3-oracle


    docker run -it --rm -p 80:80 -v $PDW:/var/www/html laravel-oracle