sudo yum install portmap -y
tar -xzf rpc*
chmod 777 rpc*
cd rpc*
./configure
make
make install 
rpc.rstatd
