https://community.f5.com/kb/technicalarticles/securing-applications-using-mtls-supported-by-f5-distributed-cloud/319377

Commands to generate CA Key and Cert: 
    openssl genrsa -out "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/certs/root-key.pem" 4096 
    openssl req -new -x509 -days 3650 -key "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/certs/root-key.pem" -out "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/misc/mTLS/certs/root-crt.pem"
Commands to generate Server Certificate:
    openssl genrsa -out cert-key2.pem 4096
    openssl req -new -sha256 -subj "/CN=mtls-echo.edge.de1chk1nd.de" -key cert-key2.pem -out cert2.csr 
    echo "subjectAltName=DNS:mtls-nginx.edge.de1chk1nd.de" >> ./etc/extfile.cnf 
    openssl x509 -req -sha256 -days 501 -in cert2.csr -CA root-crt.pem -CAkey root-key.pem -out
    cert2.pem -extfile extfile.cnf -CAcreateserial