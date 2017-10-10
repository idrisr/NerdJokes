# used to bootstrap from the perfect assistant
# then manually altered to add the ssh credentials 
# for getting the stuff from git and turning off strict 
# host checking. 

FROM perfectlysoft/perfectassistant:3.1.1
RUN apt-get -y upgrade
RUN apt-get -y update && apt-get install -y sqlite3 
RUN apt-get -y update && apt-get install -y libsqlite3-dev

RUN apt-get -y update && apt-get install -y libpq-dev
RUN apt-get -y update && apt-get install -y libmysqlclient-dev
# Perfect-COpenSSL-Linux.git-2228894759197591513/PADockerfile
RUN apt-get -y update && apt-get install -y libssl-dev

# Perfect-LinuxBridge.git-8438373625838459355/PADockerfile 
RUN apt-get -y update && apt-get install -y uuid-dev

# Perfect-libpq-linux.git--5427667007737584143/PADockerfile
RUN apt-get -y update && apt-get install -y libpq-dev

# Perfect-mysqlclient-Linux.git--5527222578176936166/PADockerfile
RUN apt-get -y update && apt-get install -y libmysqlclient-dev
RUN sed -i -e 's/-fabi-version=2 -fno-omit-frame-pointer//g' /usr/lib/x86_64-linux-gnu/pkgconfig/mysqlclient.pc
RUN rm -rf /var/lib/apt/lists/*

