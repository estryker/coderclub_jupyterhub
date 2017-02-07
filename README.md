# coderclub_jupyterhub

## Setup instructions and config files to setup Jupyterhub on AWS for CoderClub

## Features include:
* a Ruby Kernel
* Github authentication
* preloaded with coderclub lessons

## Perhaps soon to come
* a Spark Kernel

## Setup instructions
* Follow [these instructions](https://github.com/jupyterhub/jupyterhub/wiki/Deploying-JupyterHub-on-AWS) up to the section marked Configuring JupyterHub:   
* Instead, use the included jupyterhub_config.py
* git clone https://github.com/jupyterhub/dockerspawner.git
* git clone https://github.com/jupyterhub/dockerspawner.git

```
cd dockerspawner
sudo pip3 install -r requirements.txt
sudo python3 setup.py install
```

* Copy in the Dockerfile from here into singleuser/
* run: sudo docker build -t jupyterhub/singleuser singleuser
* sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to 8443
** Note that if you ever have to rebuild the docker image, run this to allow port 443 calls through (mainly with the gem installs)

First, get the rule that sets up the PREROUTING, probably line 2:

```
sudo iptables -t nat --line-numbers -L
```

Then remove the PREROUTING line:

```
sudo iptables -t nat -D PREROUTING 2
```

* create a jupyterhub_start.sh script that sets up environment variables w/ github credentials and starts the server:

```
$ export OAUTH_CALLBACK_URL=https://<host.domain.name>/hub/oauth_callback
$ export GITHUB_CLIENT_ID=<client id from Github>
$ export GITHUB_CLIENT_SECRET=<client secret from Github>
$ jupyterhub -f ./jupyterhub_config.py
```

* make it executable:
```
chmod +x jupyterhub_start.sh
```

* run it!

```
sudo ./jupyterhub_start.sh
```
