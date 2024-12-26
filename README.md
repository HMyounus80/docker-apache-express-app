# Setting Up Apache2 with HTTPS for a Dockerized Express.js Backend Application

This document provides a step-by-step guide to configure Apache2 as a reverse proxy for a Dockerized backend application running on localhost:8000. It also explains how to secure the setup with HTTPS and associate a domain name.

## Prerequisites

1. A Linux server with root or sudo privileges.
2. Docker installed and running on the server.
3. Apache2 installed on the server.
4. A domain name pointing to your server's public IP address.


---

## Step 1: Prepare the Server

### Update the System

Ensure the server is up-to-date:

```bash
sudo apt update && sudo apt upgrade -y
```

### Install Apache2

Install the Apache2 web server:

```bash
sudo apt install apache2 -y
```

Enable and start Apache2:

```bash
sudo systemctl start apache2
sudo systemctl enable apache2
```

Verify Apache2 is running:

```bash
sudo systemctl status apache2
```

---

## Step 2: Verify Docker Application

Ensure Docker is installed:

```bash
docker --version
```

If Docker is not installed, install it:

```bash
sudo apt install docker.io -y
```

Check the running Docker containers:

```bash
docker ps
```

Sample output:

```plaintext
CONTAINER ID   IMAGE             COMMAND                  PORTS                    NAMES
12345abcde     express_backend   "npm start"             0.0.0.0:8000->8000/tcp   backend_container
```

This confirms that the backend application is running on **localhost:8000**.

---

## Step 3: Configure Apache2 as a Reverse Proxy

### Enable Required Modules

Enable Apache2 proxy modules:

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo systemctl restart apache2
```

### Create Apache2 Configuration File

Create a new virtual host configuration file for your domain:

```bash
sudo nano /etc/apache2/sites-available/yourdomain.conf
```

Add the following content:

```plaintext
<VirtualHost *:80>
    ServerName yourdomain.com
    ServerAlias www.yourdomain.com

    ProxyPreserveHost On
    ProxyPass / http://localhost:8000/
    ProxyPassReverse / http://localhost:8000/

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Save and close the file.

### Enable the Site

Enable the configuration:

```bash
sudo a2ensite yourdomain.conf
sudo systemctl reload apache2
```

---

## Step 4: Set Up HTTPS with SSL Certificate

### Create a Self-Signed SSL Certificate (For Testing)

Create a directory for the certificates:

```bash
sudo mkdir /etc/apache2/certs
```

Generate the SSL certificate and key:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/certs/ssl_key.key -out /etc/apache2/certs/ssl_cert.crt
```

During the process, you will be prompted to enter details such as country, state, and domain.

### Update Apache2 Configuration for HTTPS

Create a new virtual host configuration file:

```bash
sudo nano /etc/apache2/sites-available/yourdomain-ssl.conf
```

Add the following content:

```plaintext
<VirtualHost *:443>
    ServerName yourdomain.com
    ServerAlias www.yourdomain.com

    SSLEngine On
    SSLCertificateFile /etc/apache2/certs/ssl_cert.crt
    SSLCertificateKeyFile /etc/apache2/certs/ssl_key.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:8000/
    ProxyPassReverse / http://localhost:8000/

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Save and close the file.

### Enable the SSL Site

Enable the SSL configuration:

```bash
sudo a2ensite yourdomain-ssl.conf
sudo systemctl reload apache2
```

---

## Step 5: Configure the Domain

Ensure your domain points to your server's public IP address. Update your domain's DNS settings with an **A Record**:

- Name: `@`
- Type: `A`
- Value: Server's Public IP Address

---

## Step 6: Test the Setup

Open a browser and navigate to your domain:

- **[http://yourdomain.com](http://yourdomain.com)**
- **[https://yourdomain.com](https://yourdomain.com)**

Both URLs should route to your backend application.

---

## Notes for Production

1. **Use a Trusted SSL Certificate**: For production, use a certificate from a trusted Certificate Authority (CA) like Let's Encrypt.
   ```bash
   sudo apt install certbot python3-certbot-apache
   sudo certbot --apache -d yourdomain.com -d www.yourdomain.com
   ```
2. **Secure Docker**: Ensure the Docker container is secure and optimized for production.
3. **Monitor Logs**: Regularly monitor Apache2 and application logs for errors.
   ```bash
   sudo tail -f /var/log/apache2/error.log
   ```



