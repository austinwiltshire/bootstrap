#!/bin/sh

lpass login john.a.graham@gmail.com

if [ $? -eq 0 ]; then
	lpass show ssh/github_keys --format="%fv" | awk '/BEGIN RSA PRIVATE KEY/{flag=1} flag; /END RSA PRIVATE KEY/{flag=0}' > ~/.ssh/id_rsa
	lpass show ssh/github_keys --format="%fv" | grep ssh-rsa > ~/.ssh/id_rsa.pub
	chmod 600 ~/.ssh/id_rsa
	chmod 600 ~/.ssh/id_rsa.pub
	lpass logout -f
fi


