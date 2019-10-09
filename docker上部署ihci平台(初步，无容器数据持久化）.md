##                                docker上部署ihci平台

#### 开发机

安装docker 

```shell
curl -sSL https://get.docker.com | sudo sh
```

把自己的用户加入docker用户组（注意，输入命令之后，要先注销，再登录才会生效）

```shell
sudo usermod -aG docker your-usrname
```

启动docker

```shell
Ubuntu：　docker daemon -g /local/docker/lib &

CentOs:  sudo systemctl start docker
```

安装docker-compose

```shell 
sudo pip install docker-compose
```

创建运行docker-compose的文件夹

```shell
mkdir Docker && cd Docker
```

编写docker-compose.yml文件

```shell
vim docker-compose.yml
```

把下面的内容复制过去

```dockerfile
version: '3.7' # specify docker-compose version
#version 关系到和docker版本的兼容性，具体的关联可以上网搜，我当初的docker版本是19.03.2，然后写的version就是3.7
	
# Define the services/containers to be run
services:
  ihci: #name of the first service
    build: iHCI  # specify the directory of the Dockerfile
    ports:
        - "5000:5000" #specify ports forwarding
    links: #注意这个links,它把下面两个容器服务的域名映射到了ihci容器服务中，下面会用到
      - mongo 
      - redis   

  mongo: # name of the second service
    image: mongo # specify image to build container from
    ports:
      - "27017:27017" # specify port forwarding

  redis: # name of the second service
    image: redis # specify image to build container from
    ports:
      - "6379:6379" # specify port forwarding
    command:
      redis-server   
```



接下来把项目文件夹（如iHCI)复制到Docker文件夹里

进入iHCI文件夹

```shell
cd iHCI
```

修改数据库连接url（此处为了简便，直接修改了开发模式的配置文件）

```
vim server/conf/config.dev.js
```

修改大概19行的redisConf对象的host字段为（即redis容器的域名映射）

```js
host: 'redis',
```

修改大概56行的连接mongo数据库的db字段为（mongo为mongo容器的域名映射)

```
db: 'mongodb://mongo/ihci',
```

然后，修改redis连接时的配置

```shell
vim server/middleware/redis/redis.js
```

在第一行添加

```js
const conf = require('../../conf.js')
```

并把

```js
const client = redis.createClient()
```

修改为

```js
const client = redis.createClient(conf.redisConf)
```



接下来，编写Dockerfile

```shell
vim Dockerfile
```

把下面的内容复制过去

```dockerfile
# Create image based off of the official Node image
FROM node
# Create a directory where our app will be placed
RUN mkdir -p /usr/src

# Change directory so that our commands run inside this new dir
WORKDIR /usr/src

# Copy dependency definitions
COPY package.json /usr/src

# Install dependecies
# 这里如果已经安装的依赖，可以注释掉，省时间，且不容易出BUG
RUN npm install

# Get all the code needed to run the app
COPY . /usr/src

# Expose the port the app runs in
EXPOSE 5000

# Serve the app
#CMD ["npm", "start"]
CMD node ./server/startup.js

```

回到上级目录，即Docker目录

```shell
cd ../
```

创建镜像并运行容器（-d参数是表示后台运行，如果运行失败，建议去掉这个参数，查看控制台输出）

```shell
docker-compose up -d 
```

打开浏览器，输入

```
localhost:5000
```

即可看到运行结果



停止运行

```shell
docker-compose down
```

查看镜像

```shell
docker images
```

就会看到

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker_ihci         latest              a95bcc78f9d0        5 minutes ago       1.21GB
node                latest              fa0699832a2a        7 days ago          908MB
mongo               latest              cdc6740b66a7        2 weeks ago         361MB
redis               latest              f7302e4ab3a8        3 weeks ago         98.2MB
```

推送镜像到Docker hub上（要在www.hub.docker.com上注册。Docker hub是一个类似于github一样的网站，只是github是项目版本管理，而Docker hub是容器版本管理。）

```shell
docker login
docker tag docker_ihci:latest laisg/_ihci:latest
docker push laisg/docker_ihci:latest
```

注意，laisg是Docker hub的用户名，docker_ihci是容器名，latest是标签



#### 部署机

安装docker 

```shell
curl -sSL https://get.docker.com | sudo sh
```

把自己的用户加入docker用户组（注意，输入命令之后，要先注销，再登录才会生效）

```shell
sudo usermod -aG docker your-usrname
```

启动docker

```shell
Ubuntu：　docker daemon -g /local/docker/lib &

CentOS:  sudo systemctl start docker
```

安装docker-compose

```shell 
sudo pip install docker-compose
```

拉取ihci平台的镜像(就是之前推送到Docker Hub上的镜像)，这里的镜像名对应与docker-compose.yml文件中的ihci服务的镜像名

```shell
docker pull laisg/docker_ihci
```

创建运行docker-compose的文件夹

```shell
mkdir ihci && cd ihci 
```

编写docker-compose.yml文件

```shell
vim docker-compose.yml
```

把下面的内容复制过去（注意，其实上面拉取ihci平台的镜像可以省略，只要docker-compose.yml里ihci容器服务的镜像名书写正确，docker-compose会自动拉取，像mongo和redis的一样，上面有拉取的步骤只是为了更直观）

```dockerfile
version: '3.7' # specify docker-compose version
#version 关系到和docker版本的兼容性，具体的关联可以上网搜，我当初的docker版本是19.03.2，然后写的version就是3.7

# Define the services/containers to be run
services:
  ihci: #name of the first service
    image: laisg/docker_ihci # specify image to build container from
    ports:
        - "5000:5000" #specify ports forwarding
    links:
      - mongo 
      - redis

  mongo: # name of the second service
    image: mongo # specify image to build container from
    ports:
      - "27017:27017" # specify port forwarding

  redis: # name of the second service
    image: redis # specify image to build container from
    ports:
      - "6379:6379" # specify port forwarding
    command:
      redis-server   

```

运行容器

```
docker-compose up -d 
```



