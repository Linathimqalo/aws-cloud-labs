#!/bin/bash
set -e

# 1. Update and install required packages
dnf update -y
dnf install -y python3 python3-pip nginx

# 2. Install Flask and PostgreSQL adapter
pip3 install flask psycopg2-binary boto3

# 3. Create the Flask App
mkdir -p /opt/app
cat << 'EOF' > /opt/app/app.py
import os
import json
import boto3
import psycopg2
from flask import Flask, jsonify
from botocore.exceptions import ClientError

app = Flask(__name__)

def get_db_credentials():
    secret_name = "ec2-rds-lab-db-credentials"
    region_name = "eu-north-1"
    
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise e
    
    secret = get_secret_value_response['SecretString']
    return json.loads(secret)

@app.route('/')
def index():
    try:
        creds = get_db_credentials()
        conn = psycopg2.connect(
            host=creds['host'],
            database=creds['dbname'],
            user=creds['username'],
            password=creds['password']
        )
        
        cur = conn.cursor()
        cur.execute('''
            CREATE TABLE IF NOT EXISTS visits (
                id SERIAL PRIMARY KEY,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        cur.execute('INSERT INTO visits DEFAULT VALUES;')
        conn.commit()
        cur.execute('SELECT COUNT(*) FROM visits;')
        count = cur.fetchone()[0]
        
        cur.close()
        conn.close()
        
        return jsonify({
            "status": "success",
            "message": "Connected to PostgreSQL",
            "total_visits": count
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# 4. Create a systemd service to run the Flask app
# No more environment variables needed. The app fetches them itself.
cat << 'EOF' > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 /opt/app/app.py

[Install]
WantedBy=multi-user.target
EOF

# 5. Configure nginx
cat << 'EOF' > /etc/nginx/conf.d/flask.conf
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# 6. Start the services
systemctl daemon-reload
systemctl enable flaskapp.service
systemctl start flaskapp.service
systemctl enable nginx
systemctl start nginx