## 分布式web站点测试系统

在多个测试点（SITE），测试网站的性能，结果集中保存。


### 当前测试点

| 测试点缩写 | 学校                         |
| :--------- | :----------------------------
| USTC       | 中国科学技术大学 教育网出口  |
| USTCCT     | 中国科学技术大学 电信出口    |
| USTCCMCC   | 中国科学技术大学 移动出口    |
| USTCCU     | 中国科学技术大学 联通出口    |
| XCVTC      | 宣城职业技术学院             |
| DLMU       | 大连海事大学                 |
| PKU        | 北京大学                 |
| HUST       | 华中科技大学                 |
| SEA        | 华盛顿大学（西雅图）             |

### docker 运行方式

1. 参照下面gpg --gen-key 生成自己的密钥 mykey.txt，假定放在目录 /home/james/mykey/mykey.txt。 my-public-key.txt 请发给我。

2. 运行以下命令（请修改SITE=??? -v home/james/mykey 这2个地方）

```
docker pull bg6cq/httpcheck
docker run -e SITE=test -e SLEEP=60 -e DEBUG=1 \
    -v /home/james/mykey:/keys \
    --name http_check bg6cq/httpcheck
```
* SITE是测试站点缩写
* SLEEP是一轮测试后sleep时间，建议30或60

如果看到类似以下的信息，说明运行正常。如果 gpg result: 不是0，一般是公钥没有在服务器上。

```
hostname: www.xjtu.edu.cn
url: http://www.xjtu.edu.cn/images/14/12/11/1tf5znre9c/20190506011.jpg
result:www,site=test,host=www.xjtu.edu.cn code=10,dns_time=0.0005,connect_time=0.0424,response_time=0.0425,transfer_time=0.2146,content_len=275655,transfer_rate=1284626
gpg result: 0<br>
www,site=test,host=www.xjtu.edu.cn code=10,dns_time=0.0005,connect_time=0.0424,response_time=0.0425,transfer_time=0.2146,content_len=275655,transfer_rate=1284626<br>
send to influx result:string(0) ""
```
这时，切换另一个终端，执行以下命令停止并删除之前的，重新执行放到后台运行。
```
docker container stop http_check
docker container rm http_check
docker run -d -e SITE=test -e SLEEP=60 -v /home/james/mykey:/keys --name http_check bg6cq/httpcheck
```

执行以下命令，可以在httpcheck docker更新时，自动下载更新并重启运行：

```
docker pull containrrr/watchtower
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower http_check
```

### 工作原理：

1. 结果收集服务器

   http://ipv6.ustc.edu.cn/httpcheck/report.php

   收集测试点(SITE)的测试结果，通过gpg验证签名，放入influxdb。

2. 测试点(SITE)
  
   测试点定期运行测试程序，对多个网站进行测试

   每个测试结果，gpg签名后，作为附件文件 report 通过http提交给 结果收集服务器。

### SITE 安装步骤

#### 1. 创建一个独立的用户，专门用于运行测试程序

#### 2. 以该用户的身份，执行`gpg --gen-key`命令生成gpg密钥

最简单方式，稍微修改以下脚本中的Name-Real Name-Email:

```
gpg --batch --gen-key <<EOF
%no-protection
Key-Type:1
Key-Length:1024
Subkey-Type:1
Subkey-Length:1024
Name-Real: HTTPtest USTC
Name-Email: httptest@ustc.edu.cn
Expire-Date:0
EOF

gpg --export-secret-key --armor > mykey.txt
gpg --export --armor > my-public-key.txt
```

获得的mykey.txt是私钥，自己留着；my-pubic-key.txt是公钥，发给我即可。

下面是手工执行的方式：

注意：为了工作方便，提示输入私钥密码时，请输入2次回车，不使用密码。这也是使用一个独立用户运行测试的原因。

```
$ gpg --gen-key
gpg (GnuPG) 1.4.20; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 1024
Requested keysize is 1024 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct? (y/N) y

You need a user ID to identify your key; the software constructs the user ID
from the Real Name, Comment and Email Address in this form:
    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

Real name: USTC httpcheck
Email address: httpcheck@ustc.edu.cn
Comment: 
You selected this USER-ID:
    "USTC httpcheck <httpcheck@ustc.edu.cn>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
You need a Passphrase to protect your secret key.

gpg: gpg-agent is not available in this session
You don't want a passphrase - this is probably a *bad* idea!
I will do it anyway.  You can change your passphrase at any time,
using this program with the option "--edit-key".

We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

Not enough random bytes available.  Please do some other work to give
the OS a chance to collect more entropy! (Need 189 more bytes)
```

最后一步可能需要等一段时间以生成密钥。

命令执行完毕后，执行 `gpg --export --armor` 导出公钥，发给  james@ustc.edu.cn 以便放到ipv6.ustc.edu.cn上用于验证签名。

#### 3. 执行以下命令安装程序

```
cd
git clone --recursive https://github.com/bg6cq/httpcheck.git
cd httpcheck/httptest
make
cd ..
cp run.sample run.sh

vi run.sh

把其中的SITE改为自己的缩写
```

如果make 出现错误，请用root执行`yum -y install git curl gcc openssl-devel`之类的命令安装gcc，openssl-devel等。

#### 4. 执行 run.sh 

运行run.sh 开始测试。

我使用的run.sh如下，运行方式是`screen bash run.sh`。
```
#!/bin/bash

DEBUG=1
SITE=ustc
export DEBUG
export SITE
while true; do
        date
        bash runhttpcheck.sh
        git pull
        echo sleep 30
        sleep 30
done
```

### 查看结果

发送公钥后，会获得一个用户名和密码，使用该用户名和密码，可以登录 http://202.38.95.107:3000 查看结果，也可以在上面建立自己的dashboard。

### 添加修改要监测的网站和url

请fork后修改urls.txt或按照以下格式把信息发给我，我来改。

修改后，其他测试点需要执行 git pull 才会取到新的信息。

数据格式
```
主机名 URL
```
