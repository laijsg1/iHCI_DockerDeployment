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
