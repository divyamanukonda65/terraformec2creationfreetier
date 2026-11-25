#!/bin/bash
sudo yum install httpd -y
sudo service httpd start
sudo systemctl enable httpd
echo "<h1>Welcome to my website</h1>" | sudo tee /var/www/html/index.html
