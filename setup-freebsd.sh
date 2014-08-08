#!/bin/sh
# Copyright (c) 2014 John Ko

install_pkg (){
	pkg-static info $1 > /dev/null 2> /dev/null || pkg-static install -y $1 || exit 1
}

for i in git py27-pip py27-fabric py27-Jinja2 ; do
	install_pkg $i
done

ln -shf python2.7 /usr/local/bin/python || exit 1

if [ ! -e $HOME/littlechef/fix ]; then
	git clone https://github.com/johnko-chef/littlechef-freebsd.git $HOME/littlechef || exit 1
fi
mkdir $HOME/new_kitchen
cd $HOME/new_kitchen
$HOME/littlechef/fix new_kitchen || exit 1

cat > $HOME/new_kitchen/littlechef.cfg <<EOF
[userinfo]
user = chef
keypair-file = ~/.ssh/id_rsa
encrypted_data_bag_secret = 
[kitchen]
node_work_path = /tmp/chef-solo/
EOF

# littlechef/fabric/paramiko can't use ecdsa keys
if [ ! -e ~/.ssh/id_rsa ]; then
	ssh-keygen -N '' -t rsa -b 4096 -f ~/.ssh/id_rsa
fi

cat <<EOF
Prepare node 10.123.234.35:
# pkg install -y rubygem-chef
# echo "chef:::::::/usr/home/chef:/bin/sh:" | /usr/sbin/adduser -w no -S -f -
# passwd chef
# install -d -o chef -g chef -m 700 /usr/home/chef/.ssh
# install -o chef -g chef -m 600 /usr/home/chef/.ssh/authorized_keys

You may want to:
# set path = (\$HOME/littlechef \$path)
# cd \$HOME/new_kitchen/cookbooks
# git clone https://github.com/johnko-chef/motd
# cd \$HOME/new_kitchen
# echo '{"name":"base","description":"The base role for all FreeBSD systems.","json_class":"Chef::Role","default_attributes":{},"override_attributes":{},"chef_type":"role","run_list":["recipe[motd]"],"env_run_lists":{}}' > roles/base.json
# echo '{"run_list":["role[base]"]}' > nodes/10.123.234.35.json
# fix node:10.123.234.35
EOF
