# Canvas docker

## Prerequiresite

* Docker
    * Install docker, docker-compose
    * Disable swap
* Nginx
* Linux package
    * ccze
    * certbot

## Setup new site

```bash
# Step 1: copy .env.production => .env
cp .env.production .env

# Step 2: update .env for secrets, public domain, etc.
#   COMPOSE_PROJECT_NAME        : the instance name, for example: canvas_schoolA
#   WEB_PORT                    : the internal port for canvas-lms
#   RCE_PORT                    : the internal port for canvas-rce
#   PUBLIC_DOMAIN               : the domain of canvas site, for example: schoolA.classcom.app
#   RCE_HOST                    : the domain of canvas-rce site, for example: rce.schoolA.classcom.app
#   ENABLE_HTTPS                : is true for production site
#   DB_PASSWORD                 : random text
#   ENCRYPTION_KEY              : random text
#   ENCRYPTION_SECRET           : random 32-character text
#   SIGNING_SECRET              : random 32-character text
# Optional:
#   PGADMIN_EMAIL               : email to access the pgadmin in case of using pgadmin to access db
#   PGADMIN_PASSWORD            : random password to access the pgadmin in case of using pgadmin to access db
#   PGADMIN_PORT                : choose a port to access pgadmin

# Update other config files in config folder if necessary

# Step 3: 
./pull.sh 

# Step 4: setting cassandra
./init-cassandra.sh
./run.sh web rails console
# > Setting.set('enable_page_views', 'cassandra')
# > exit

# Step 5: Create database
#   Fill in admin email, password and site name
./initdb.sh

# Step 6:
./up.sh --no-logs

# alternative: run and follow logs (Ctrl-C to stop following logs, the services are still running)
./up.sh

# Step 7: 
./nginx/enable-websocket.sh

# Step 8:
#   Update ./nginx/conf/site.conf
#       Rename upstream to the instance name, for example: canvas_schoolA and canvas_schoolA-rce
#       Modify ports according to the WEB_PORT and RCE_PORT in the .env file above
#       Update the corresponding upstream name in the proxy_pass below
#       
./nginx/enable-site.sh

# Step 9: enable HTTPS
sudo certbot --nginx

# Step 10:
#   Sync back updated nginx conf after certbot ran, so that we can centralize all changes in this folder.
./nginx/sync-site-conf.sh
#   Next time, if you want to change nginx conf, just change the nginx/conf/site.conf and run enable-site.sh again.

# Step 11:
#   Goto website http://*/accounts/self/settings, enable Analytics.
#   Check link http://*/accounts/self/analytics

```

## Other utilities

```bash
# View all logs
./logs.sh

# View logs of a specific service container
./logs.sh <service name>
# example
./logs.sh web
./logs.sh postgres
./logs.sh jobs
./logs.sh rce-api
./logs.sh cassandra

# view app/tmp/production.log
./logs.sh production

# disable site
./nginx/disable-site.sh



# [WARNING: DATA DELETION] 
# Clear all volumes for fresh installation
./down.sh -v

```