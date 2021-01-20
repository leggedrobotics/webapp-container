`webapp-container` 🐋
===

Scripts and tools to run a PHP web-application - meaning [Laravel](https://laravel.com/), right now - in [Docker](https://www.docker.com/).

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

🧩 Extending
---

Add features to the images or change behavior by adding Make targets or extending the images with Dockerfiles.

Via a Dockerfile in the root of the project.

```dockerfile
ARG BASE_IMG=my-app-development-base
FROM $BASE_IMG AS development

# Extend the development base image with some extra packages
RUN --mount=type=cache,target=/etc/apk/cache apk --update-cache add \
  php-mysqli \
  php-pdo_mysql
```

Then, adding to the `Makefile`:

```
# ... rest of the Makefile
include docker/makefile.mk

build-development: build-development-base
	${BUILD} -t ${APP_NAME}-development \
		--target development \
		.
```

Now, run `make build-development` and `make development` is usual

> **TODO** Adding `supervisord` services

📦 Production
---

Getting ready for production by building a container that includes sources and compiled assets.
Extend the `Dockerfile` and `Makefile` to accomodate the necessary steps.

Example `Makefile`

```makefile
# ... rest of the Makefile

# Build production by extending the base image 
# (target `build-base`, image name `${APP_NAME}-base`)
build-production: build-base
	${BUILD} --target production \
		--build-arg BASE_IMG=${APP_NAME}-base \
		-t ${APP_NAME}-production \
		.

production: build-production
	${DOCKER} run -ti --rm \
		--name ${APP_NAME}-production \
		-p80:80 -p443:443 \
		-v${APP_NAME}-certs:/certs \
		-v${APP_NAME}-production-storage:/opt/storage \
		${APP_NAME}-production
```

Then to run: 
```bash
# build production container
make build-production
# optionally, tag and push the container
#  docker tag my-app-production my.registry.io/my-app
#  docker push my.registry.io/my-app
# test the production container locally
make production
```

🦭 Podman or other container tools
---
_The UTF-8 emoji for a Seal is not widely supported..._

Using [Podman](https://podman.io/) is simple due to the partial command-line compatibility. 

```bash
DOCKER=podman BUILD=podman\ build make development
```

Or set the environment variables in your `Makefile`.
