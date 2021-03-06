.PHONY: check build-development composer-install build-npm npm-install npm-run-watch development build-production production

APP_DIR ?= app
APP_NAME ?= app
APP_DOMAIN ?= ${APP_NAME}.test

NGINX_CONF ?= standalone.conf

PWD=$(shell pwd)
DOCKER ?= docker
BUILD ?= ${DOCKER} buildx build
UID=$(shell id -u)
GID=$(shell id -g)

check:
	@which ${DOCKER} >/dev/null || ( echo "Error: Docker is not installed"; exit 1 )

build-base: check
	${BUILD} -f docker/Dockerfile \
	  --target base \
	  --build-arg UID=${UID} \
	  --build-arg GID=${GID} \
	  --build-arg NGINX_CONF=${NGINX_CONF} \
	  -t ${APP_NAME}-base \
	  .

build-development-base: check
	${BUILD} -f docker/Dockerfile \
	  --target development \
	  --build-arg UID=${UID} \
	  --build-arg GID=${GID} \
	  --build-arg NGINX_CONF=${NGINX_CONF} \
	  -t ${APP_NAME}-development \
	  -t ${APP_NAME}-development-base \
	  .

build-development: build-development-base

build-npm: check
	${BUILD} -f docker/npm/Dockerfile \
		--build-arg UID=${UID} \
		--build-arg APP_DIR=${APP_DIR} \
		-t ${APP_NAME}-npm-base \
		-t ${APP_NAME}-npm \
		docker/npm

composer-install: check build-development
	${DOCKER} run -ti --rm --name ${APP_NAME}-composer-install -v${PWD}/${APP_DIR}:/opt ${APP_NAME}-development composer install

npm-install: check build-npm
	${DOCKER} run -ti --rm --name ${APP_NAME}-npm-install -v${PWD}/${APP_DIR}:/opt ${APP_NAME}-npm install

npm-run-watch: check
	${DOCKER} run -ti --rm --name ${APP_NAME}-watch -v${PWD}/${APP_DIR}:/opt ${APP_NAME}-npm run watch

npm-run-prod: check
	${DOCKER} run -ti --rm --name ${APP_NAME}-watch -v${PWD}/${APP_DIR}:/opt ${APP_NAME}-npm run prod

development: check build-development
	${DOCKER} run -ti --rm --name ${APP_NAME}-development \
		-p80:80 -p443:443 \
		-v${PWD}/${APP_DIR}:/opt \
		-v${PWD}/docker/certs:/certs \
		-v${APP_NAME}-development-home:/home/app \
		${APP_NAME}-development

sh: check
	${DOCKER} exec -ti -uapp ${APP_NAME}-development sh

tinker: check
	${DOCKER} exec -ti -uapp ${APP_NAME}-development php artisan tinker

docker/certs/fullchain.pem: docker/certs/generate.sh
	cd docker/certs && ./generate.sh ${APP_DOMAIN}

docker/certs/dhparam.pem:
	cd docker/certs && openssl dhparam -out dhparam.pem 2048

dev-certs: docker/certs/fullchain.pem docker/certs/dhparam.pem



