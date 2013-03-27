#
# Clean/Compile Life-cycle
#
UNAME := $(shell uname)

all: clean compile

clean:
	make -C _layouts clean
	rm -rf _site


compile:
	make -C _layouts
	bundle exec jekyll --no-server --no-safe --no-auto
	bundle exec compass compile -c compass.rb


runserver: clean compile
	bundle exec foreman start


.PHONY: all clean compile runserver

#
# Developer Setup
#

setup:
ifeq ($(UNAME), Darwin)
	sudo easy_install Pygments
else
	sudo apt-get -y install python-pygments
endif
	bundle install

setup_js:
	bundle exec compass install -r zurb-foundation foundation/upgrade -c compass.rb

.PHONY: setup
