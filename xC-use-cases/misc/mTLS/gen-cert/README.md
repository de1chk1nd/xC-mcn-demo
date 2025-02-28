# Cert generation
## Prepare Cert generation
echo 01 > /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/serial
touch /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/index.txt

## Create CA
openssl genrsa -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/private/cakey.pem 4096
openssl req -new -x509 -days 3650 -config /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/etc/openssl.cnf -key /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/private/cakey.pem -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/certs/cacert.pem

openssl x509 -in /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/certs/cacert.pem -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/certs/cacert.pem -outform PEM

## Create Client Cert
openssl genrsa -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.key.pem 4096
openssl req -new -config /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/etc/openssl.cnf -key /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.key.pem -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.csr
openssl ca -config /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/etc/openssl.cnf -days 1650 -notext -batch -in /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.csr -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.cert.pem

cat /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/index.txt
openssl x509 -in /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.cert.pem -noout -serial

## Create Server Cert
openssl genrsa -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/server.key.pem 4096
openssl req -new -config /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/etc/openssl.cnf -key /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/server.key.pem -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/server.csr
openssl ca -config /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/etc/openssl.cnf -days 1650 -notext -batch -in /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/server.csr -out /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/server.cert.pem

cat /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/index.txt
openssl x509 -in /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/server.cert.pem -noout -serial

# xC Config
## Create Loadbalancer + CA
Name                : lb-mtls-echo
Domain              : mtls-echo.edge.de1chk1nd.de
Load Balancer Type  : HTTPS with Custom Certificate
Certificate         :
    Name            : cert-mtls-echo
    mTLS            : Enable
    Root CA         : Upload Root CA
    Certificate     : Upload Certificates
    Pool            : origin-aws-echo-eu-central-1 

# Test
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.cert.pem --key /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/client.key.pem --cacert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/certs/cacert.pem https://mtls-echo.edge.de1chk1nd.de:443

# Delete All Certs
rm /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/serial*
rm /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/index*
rm /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/private/*
rm /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/certs/*
rm /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/client_certs/*
rm /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/gen-cert/server_certs/*