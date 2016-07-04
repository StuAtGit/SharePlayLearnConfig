##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Server configuration
#

server {
    listen 80;
    server_name *.shareplaylearn.com;
    rewrite  ^ https://shareplaylearn.com$request_uri? redirect;
}

server {
	client_max_body_size 1G;
	# SSL configuration
	#
	listen 443 ssl default_server;
	ssl_certificate /etc/letsencrypt/live/www.shareplaylearn.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/www.shareplaylearn.com/privkey.pem;

	ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

	ssl_prefer_server_ciphers on;

	ssl_protocols TLSv1.2;
	root /var/www/shareplaylearn.com/;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html index.php;

	add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
	ssl_session_cache shared:SSL:10m;

	server_name *.shareplaylearn.com;

	location /auth_api {
		proxy_pass http://127.0.0.1:1443/auth_api;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	}	
}
