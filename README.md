## 分布式web站点测试系统

在多个测试点（SITE），测试网站的性能，结果集中保存。

### 工作原理：

1. 结果收集服务器

   http://ipv6.ustc.edu.cn/httpcheck/report.php

   收集测试点(SITE)的测试结果，通过gpg验证签名，放入influxdb。

2. 测试点(SITE)
  
   测试点定期运行测试程序，对多个网站进行测试

   每个测试结果，gpg签名后，作为附件文件 report 通过http提交给 结果收集服务器。

### SITE 安装步骤

1. 创建一个独立的用户，专门用于运行测试程序

2. 以该用户的身份，执行`gpg --gen-key`命令生成gpg密钥

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

3. 执行以下命令安装程序

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

4. 执行 run.sh 


### 查看结果

发送公钥后，会获得一个用户名和密码，使用该用户名和密码，可以登录 http://202.38.95.107:3000 查看结果，也可以在上面建立自己的dashboard。