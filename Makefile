all: build

build:
	@docker build --tag=deadpoets/dns-dhcp .
