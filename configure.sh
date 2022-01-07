#!/bin/bash

 mkdir ~/.screen && chmod 700 ~/.screen
 export SCREENDIR=$HOME/.screen
 sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf
#下载xray
xray(){
wget -O /opt/xray.zip $xray
unzip -o /opt/xray.zip -d /opt/xray 
chmod +x /opt/xray/xray
cat > /opt/xray/config.json <<EOF
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 1506,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}
EOF

}
cf(){
#配置cf tunnel
wget -O /opt/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /opt/cloudflared
#生成授权证书
cat > /opt/cert.pem <<EOF
$CERT
EOF
}
xray
cf
supervisord -c /etc/supervisord.conf
