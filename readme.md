`webapp-docker` 🐋
===

Infrastructure to run a PHP web-application, typically Laravel, in Docker.

**Note: This repository is supposed to be a Git submodule of a web application.**

Ingredients
- [⛰️  Alpine](https://www.alpinelinux.org/)
- [⚙️  PHP-FPM 7.4](https://php-fpm.org/)
- [🌐 Nginx](https://nginx.org/en/)
- [📮 Redis](https://redis.io/)
- [👮 supervisord](http://supervisord.org/)

💾 Setup
---

Assuming an initial repository where the (Laravel) application lives in a sub-directory.
Add the `webapp-docker` repository as a Git submodule. 
Then copy the example `Makefile` and `.dockerignore` file. 

```bash
# Add submodule
git submodule add git@github.com:leggedrobotics/webapp-docker.git docker
# Copy example files
cp docker/dockerignore.example .dockerignore
cp docker/Makefile.example Makefile
```

In the Makefile, adjust the variables to reflect the name and directory of your app. 

```
APP_DIR = my-app
APP_NAME = my-app

...
```

🧰 Development
---

```bash
# build the development container
make build-development
# install composer dependencies locally
make composer-install
# install npm dependencies locally
make npm-install
# generate development certificates, assumes ${APP_NAME}.test
# override by setting APP_DOMAIN (env)var.
make dev-certs
# start the development server
make development
# watch assets
make npm-run-watch
# start a shell session in the development container
make sh
# start a Tinker (PHP REPL) session in the development container
make tinker
```
