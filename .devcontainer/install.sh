#!/usr/bin/env bash

rm -rf ./docker-ca
mkdir -p ./docker-ca
cd ./docker-ca

#相关配置信息
SERVER="10.230.214.11"
COUNTRY="CN"
STATE="bj"
CITY="bj"
ORGANIZATION="org"
ORGANIZATIONAL_UNIT="dev"
EMAIL="abc@qq.com"

###开始生成文件###
echo "开始生成文件"

#生成ca私钥(使用aes256加密)
openssl genrsa -out ca-key.pem 2048
#生成ca证书，填写配置信息
openssl req -new -x509 -days 3650 -key ca-key.pem -sha256 -out ca.pem -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$SERVER/emailAddress=$EMAIL"

#生成server证书私钥文件
openssl genrsa -out server-key.pem 2048
#生成server证书请求文件
openssl req -subj "/CN=$SERVER" -new -key server-key.pem -out server.csr
#创建扩展配置文件，添加SANs
echo "subjectAltName=DNS:$SERVER,IP:$SERVER" > server-extfile.cnf
#使用CA证书及CA密钥以及上面的server证书请求文件进行签发，生成server自签证书
openssl x509 -req -days 3650 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile server-extfile.cnf

#生成client证书RSA私钥文件
openssl genrsa -out client-key.pem 2048
#生成client证书请求文件
openssl req -subj '/CN=client' -new -key client-key.pem -out client-client.csr

sh -c 'echo "extendedKeyUsage=clientAuth" > client-extfile.cnf'
#生成client自签证书（根据上面的client私钥文件、client证书请求文件生成）
openssl x509 -req -days 3650 -in client-client.csr -CA ca.pem -CAkey ca-key.pem  -CAcreateserial -out client-cert.pem  -extfile client-extfile.cnf

#更改密钥权限
chmod 0400 ca-key.pem client-key.pem server-key.pem
#更改密钥权限
chmod 0444 ca.pem server-cert.pem client-cert.pem
#删除无用文件
rm *.csr *.srl *.cnf

echo "生成文件完成"



ssh wcni-kind  'mkdir -p /etc/docker/certs'
scp ./*  wcni-kind:/etc/docker/certs

echo '{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://0.0.0.0:2376"
  ],
  "tls": true,
  "tlscacert": "/etc/docker/certs/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem",
  "tlsverify": true
}' > daemon.json

scp ./daemon.json  wcni-kind:/etc/docker/daemon.json
ssh wcni-kind  'cat /etc/docker/daemon.json'
ssh wcni-kind  'systemctl daemon-reload && systemctl restart docker'

docker context rm remote-tcp -f
curl https://${SERVER}:2376/version --cert `pwd`/client-cert.pem --key `pwd`/client-key.pem --cacert `pwd`/ca.pem
docker context create remote-tcp --docker "host=tcp://${SERVER}:2376,ca=`pwd`/ca.pem,cert=`pwd`/client-cert.pem,key=`pwd`/client-key.pem"
docker context use remote-tcp
docker images






