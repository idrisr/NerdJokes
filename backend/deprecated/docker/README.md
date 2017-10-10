# Build the container
* `docker build`
# Deploy the container
* `docker run -i -v ~/Desktop/perfectDocker:/root -t  [image from above] /bin/bash -c /root/deploy.sh`

# TODO
* fix path of the db file
* figure out how to expose the port
* publish the image somewhere
