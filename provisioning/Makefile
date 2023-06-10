export BRANCH := $(shell git branch --contains | fgrep '*' | cut -d ' ' -f 2)

build: isucon12-qualify mitamae.tar.gz
.PHONY: build clean certs
	packer build qualify.pkr.hcl

blackauth:
	cd ../blackauth && GOOS=linux GOARCH=amd64 go build -o ../provisioning/blackauth .

clean:
	rm -rf mitamae.tar.gz isucon12-qualify* blackauth initial_data.tar.gz

initial_data.tar.gz:
	gh release download -p $@

isucon12-qualify:
	gh repo clone isucon/isucon12-qualify -- --depth=1 --branch=$(BRANCH)
	cd isucon12-qualify/bench && GOOS=linux GOARCH=amd64 make

mitamae.tar.gz: initial_data.tar.gz blackauth certs
	install blackauth mitamae/cookbooks/blackauth/
	tar czvf mitamae.tar.gz mitamae/

certs:
	gh release -R KOBA789/t.isucon.pw download -p 'key.pem' -p 'fullchain.pem' --dir mitamae/cookbooks/nginx/tls/ --clobber
