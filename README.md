# wireguard-poc

## 概要

wireguardでvpn構築のpoc。

- インスタンスタイプ：t3.nano
- OS：Ubuntu22.04

## 注意

秘密鍵はradio.pemを使用すること。

## 手順

```bash
sudo apt update
```

```bash
sudo apt -y upgrade
```

dateでtimezoneがJSTであるかの確認。

```bash
date
```

JSTでない場合は、以下のコマンドでJSTに設定する。

```bash
sudo timedatectl set-timezone Asia/Tokyo
```

必要なパッケージのインストール

```bash
sudo apt install wireguard wireguard-tools samba -y 
```
Wireguardの定義ファイルを格納するディレクトリのアクセス権を設定する。

```bash
sudo chmod 777 /etc/wireguard/
```

## サーバとの定義ファイルを作成する

以下のサイトで作成する。

[WireGuard Tools \- Configuration Generator](https://www.wireguardconfig.com/)
https://www.wireguardconfig.com/

### サーバ

```/etc/wireguard/wg0.conf```にサーバ側の定義を入れる。

起動する。

```bash
sudo wg-quick up wg0
```

### クライアント

クライアントに定義をコピペする。

Endpointは接続先のグローバルIPアドレスに変更する。

```bash
[Interface]
PrivateKey = aGhfdNq3UX7mqYzqIS5kO++T0EO/VzImU863GEz
ListenPort = 51820
Address = 10.0.0.2/24

[Peer]
PublicKey = XuWa4DI5X4DKZpcetyZ+WSEdRQwxp20iH5v6e
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = aa.aa.aa.aa:51820
```

## 疎通確認

双方向でpingで疎通確認する。

## sambaの導入

以下のコマンドでsambaを構成する。sambaユーザを作って、/srv/samba/public/を公開する。

```bash
sudo mkdir /srv/samba
sudo adduser --system --group --no-create-home samba
sudo chmod 775 /srv/samba/public/
sudo chown samba: /srv/samba/public/
sudo chmod 775 /srv/samba/public/
sudo pdbedit -a samba
```

```/etc/samba/smb.conf```を以下の通り定義する。

```bash
[global]
   guest account = samba

[Public]
   writeable = yes
   path = /srv/samba/public
   create mask = 0664
   directory mask = 0775
   force user = samba
   force group = samba
   guest ok = yes
   guest only = yes
```


```/etc/samba/smb.conf```の記述に誤りがないかを確認する。

```bash
sudo testparm
```

sambaをリスタートする。

```bash
sudo systemctl restart smbd
```

これでファイル共有もできる。

---
以下は途中経過。

## 手順

https://www.kabukigoya.com/2022/05/ubuntu-server-2204-ltswireguard.html

```bash
sudo apt update
```

```bash
sudo apt -y upgrade
```

dateでtimezoneがJSTであるかの確認。

```bash
date
```

```bash
sudo timedatectl set-timezone Asia/Tokyo
```

必要なパッケージのインストール。

```bash
sudo apt  install docker.io docker-compose git -y
```
ユーザを追加

```bash
sudo usermod -aG docker $USER
```

sudo apt install samba

sudo mkdir /srv/samba/public

sudo adduser --system --group --no-create-home samba

ubuntu@ip-10-99-0-162:/srv/samba$ sudo chown samba: /srv/samba/public/
ubuntu@ip-10-99-0-162:/srv/samba$ sudo chmod 775 /srv/samba/public/

sudo pdbedit -a samba
パスワードは不要


sudo testparm


[global]
   guest account = samba

[Public]
   writeable = yes
   path = /srv/samba/public
   create mask = 0664
   directory mask = 0775
   force user = samba
   force group = samba
   guest ok = yes
   guest only = yes

[ikuya]
   writeable = yes
   path = /srv/samba/ikuya
   create mask = 0664
   directory mask = 0775
   force user = ikuya
   force group = ikuya


sudo systemctl restart smbd

[WireGuard Tools \- Configuration Generator](https://www.wireguardconfig.com/)
https://www.wireguardconfig.com/

---

以下は不要となったメモ。

sudo timedatectl set-timezone Asia/Tokyo

sudo apt install wireguard wireguard-tools samba -y 

sudo chmod 777 /etc/wireguard/

wg genkey | tee /etc/wireguard/server.key


wg genkeyで秘密鍵を作成し、作成した秘密鍵から公開鍵をwg pubkeyで作成します。

cat /etc/wireguard/server.key | wg pubkey | tee /etc/wireguard/server.pub

クライアント側の鍵

wg genkey | tee /etc/wireguard/client.key

cat /etc/wireguard/client.key | wg pubkey | tee /etc/wireguard/client.pub


https://qiita.com/kangyufei/items/709c29a4b5c1f263f079


cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
ListenPort = 51820
# IPは実際のIP
Address = 192.168.1.1/32
# サーバの秘密鍵
PrivateKey = GKqr3AY56+Di+kE6Ig1nPxsIHS5W9DRaislhdaRdOUc=
PostUp = echo 1 > /proc/sys/net/ipv4/ip_forward; iptables -A FORWARD -i wg0 -o ens5 -j ACCEPT; iptables -A FORWARD -i ens5 -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
PostDown = echo 0 > /proc/sys/net/ipv4/ip_forward; iptables -D FORWARD -i wg0 -o ens5 -j ACCEPT; iptables -D FORWARD -i ens5 -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE

[Peer]
# クライアントの公開鍵
PublicKey = 4YE+0L+AVEMCjn4Na8/URZMCbYPq0bB+AbT4jnZANUk=
AllowedIPs = 10.99.0.88/32
Endpoint = 10.99.0.88:51820
EOF


https://qiita.com/kangyufei/items/709c29a4b5c1f263f079



sudo wg;ip addr;iptables -L;sysctl net.ipv4.ip_forwardZ
sudo wg-quick up wg0

違いを見る。

sudo wg;ip addr;iptables -L;sysctl net.ipv4.ip_forward


sudo wg-quick down wg0

sudo systemctl enable wg-quick@wg0

sudo systemctl status wg-quick@wg0





sudo mkdir /srv/samba

sudo adduser --system --group --no-create-home samba
sudo chmod 775 /srv/samba/public/
sudo chown samba: /srv/samba/public/
sudo chmod 775 /srv/samba/public/

sudo pdbedit -a samba


/etc/samba/smb.conf

[global]
   guest account = samba

[Public]
   writeable = yes
   path = /srv/samba/public
   create mask = 0664
   directory mask = 0775
   force user = samba
   force group = samba
   guest ok = yes
   guest only = yes

sudo testparm

sudo systemctl restart smbd