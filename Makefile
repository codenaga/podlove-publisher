prepareTest:
	bash bin/install-wp-tests.sh wordpress_test root '' localhost latest

test:
	./vendor/bin/phpunit -c phpunit.xml

release:
	bin/release.sh

format:
	php-cs-fixer fix . --config .php-cs-fixer.dist.php

validateFormat:
	php-cs-fixer fix . --config .php-cs-fixer.dist.php -v --dry-run --stop-on-violation --using-cache=no

update_subscribe_button:
	uname | grep -q Darwin && (xcode-select -p > /dev/null 2>&1 || xcode-select --install) || true
	which python3 > /dev/null || exit 1
	which yarn > /dev/null || exit 1
	rm -rf .tmppsb
	git clone https://github.com/podlove/podlove-subscribe-button.git .tmppsb
	cd .tmppsb && sed -i.bak '/"node-sass":/d' package.json
	cd .tmppsb && yarn install
	cd .tmppsb && yarn add sass
	cd .tmppsb && export PYTHON=$$(which python3) && npx gulp
	rm -rf lib/modules/subscribe_button/dist
	mv .tmppsb/dist lib/modules/subscribe_button/dist
	rm -rf .tmppsb

player:
	mkdir -p $(player_dst)/bin
	mkdir -p $(player_dst)/css
	mkdir -p $(player_dst)/img
	mkdir -p $(player_dst)/js/vendor
	cp -r $(player_src)/css/vendor $(player_dst)/css/vendor
	cp -r $(player_src)/img/* $(player_dst)/img
	cp -r $(player_src)/js/*.min.js $(player_dst)/js
	cp -r $(player_src)/js/vendor/*.min.js $(player_dst)/js/vendor

composer_with_prefixing:
	mkdir -p vendor-prefixed
	composer install --no-progress --prefer-dist --optimize-autoloader --no-dev
	composer prefix-dependencies
	rm -rf vendor/matomo
	rm -rf vendor/twig
	rm -rf vendor/monolog
	rm -rf vendor/psr
	composer dump-autoload --classmap-authoritative
	# composer install --no-progress --prefer-dist --optimize-autoloader --no-dev

install_php_scoper:
	mkdir -p vendor-prefixed
	composer require --dev bamarni/composer-bin-plugin:1.4.1
	composer bin php-scoper config minimum-stability dev
	composer bin php-scoper config prefer-stable true
	composer bin php-scoper require --dev --update-with-all-dependencies humbug/php-scoper:0.17.5

client_legacy:
	cd js && npm install
	cd js && NODE_ENV=production npm run build

client_next:
	cd client && npm install
	cd client && NODE_ENV=production npm run build

client: client_legacy client_next

build:
	make composer_with_prefixing
	make client

	rm -rf dist/*
	mkdir -p dist
	# move everything into dist
	rsync -r --exclude=.git --exclude=node_modules --exclude=./dist . dist
	# cleanup
	find dist -name "*.git*" | xargs rm -rf
	rm -rf dist/lib/modules/podlove_web_player/player_v2/player/podlove-web-player/libs
	rm -rf dist/lib/modules/podlove_web_player/player_v2/player/podlove-web-player/img/banner-772x250.png
	rm -rf dist/lib/modules/podlove_web_player/player_v2/player/podlove-web-player/img/banner-1544x500.png
	rm -rf dist/client/src
	rm -rf dist/client/package-lock.json
	rm -rf dist/tests
	rm -rf dist/vendor-bin
	rm -rf dist/vendor/bin
	rm -rf dist/vendor/phpunit/php-code-coverage
	rm -rf dist/vendor/phpunit/phpunit
	rm -rf dist/vendor/phpunit/phpunit-mock-objects
	rm -rf dist/vendor/twig/twig/test
	rm -rf dist/vendor/guzzle/guzzle/tests
	rm -f dist/.travis.yml
	rm -rf dist/bin
	rm -f dist/wprelease.yml
	rm -f dist/CONTRIBUTING.md
	rm -f dist/Makefile
	rm -f dist/phpunit.xml
	rm -f dist/Rakefile
	rm -f dist/README.md
	rm -f dist/*.code-workspace
	rm -f dist/.prettierrc
	rm -f dist/.editorconfig
	find dist -name "*composer.json" | xargs rm -rf
	find dist -name "*composer.lock" | xargs rm -rf
	find dist -name "*.swp" | xargs rm -rf
	# find dist/vendor -type d -iname "test" | xargs rm -rf
	# find dist/vendor -type d -iname "tests" | xargs rm -rf
	# player v2 / mediaelement
	find dist -iname "echo-hereweare.*" | xargs rm -rf
	find dist -iname "*.jar" | xargs rm -rf


install: install_php_scoper composer_with_prefixing
