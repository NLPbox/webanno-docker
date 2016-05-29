Installation
============

docker build -t webanno3 https://github.com/fkuhn/webanno3-docker.git

or 

docker build --no-cache=true -t webanno3 https://github.com/fkuhn/webanno3-docker.git


Usage
=====
The service starts via:

 docker run -i -t -p 18080:18080 webanno3
 
but is not showing content when going to localhost:1880 in a browser window. 
