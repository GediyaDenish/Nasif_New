# Node Ts

Nasif Server Application


## How to setup
    create package.json with default value run below command
    => npm init -y

    install dev dependency
    => npm i -D typescript ts-node nodemon debug @types/express @types/express-session @types/node @types/http-errors @types/cors @types/morgan @types/compression @types/hapi__joi @types/bcrypt @types/jsonwebtoken @types/passport @types/passport-jwt @types/passport-local @types/mongoose-paginate-v2 @types/cookie-parser @types/twilio @types/axios @types/body-parser @types/jwt-decode @types/cron @types/socket.io

    install dependency
    => npm i express express-session dotenv envalid mongoose cors morgan compression @hapi/joi module-alias bcrypt jsonwebtoken passport passport-jwt passport-local mongoose-paginate-v2 cookie-parser twilio @aws-sdk/client-s3 axios body-parser jwt-decode cron moment socket.io firebase-admin

    create tsconfig.json with default value run below command
    => npx tsc --init

    set below point in package.json
    => "dev" : "DEBUG=app:* NODE_ENV=dev nodemon ./src/server.ts",
    => "start" : "NODE_ENV=prod node ./dist/server.js",
    => "build": "npx tsc"

    set below point in tsconfig.json
    => "rootDir": "./src", 
    => "outDir": "./dist",
    => "moduleResolution": "node",
    => "include": ["./src"]
    => "baseUrl": "./src",
    => "paths": {
        "@/resources/*" : ["resources/*"],
        "@/utils/*" : ["utils/*"],
        "@/middleware/*" : ["middleware/*"],
       },

    to run dev environment run below command
    => npm run dev

    to run production environment run below command
    => npm run start

    to buid app run below command
    => npm run build


## To deploy in server 
    Install pm2 
    Go to uploded folder and run below compand
    => pm2 start "npm run start" --name Nasif
    => pm2 start "npm run dev" --name Nasif-dev
    => pm2 start "npm run staging" --name Nasif-test


## Apache file config
ProxyPreserveHost On
ProxyTimeout 999999

RewriteEngine on

RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]

RewriteRule ^/?(.*) "ws://localhost:8080/$1" [P,L]

<Location /api/>
        ProxyPass http://localhost:8080/be/
        ProxyPassReverse http://localhost:8080/be/
</Location>

<Location /socket.io/>
        ProxyPass http://localhost:8080/socket.io/
        ProxyPassReverse http://localhost:8080/socket.io/
</Location>

<Directory /var/www/html-live>
        #Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        Allow from all
</Directory>