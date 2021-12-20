all:
	docker build -t hypercdb/hypercdb:latest . 

push:
	docker push hypercdb/hypercdb:latest

login:
	docker login

develop:
	rm -rf ./postgresql-proxy
	# git clone --depth=1 ../etable/postgresql-proxy postgresql-proxy 
	rsync -av ../etable/postgresql-proxy ./ --exclude .git --exclude *.log
	docker build -f ./Dockerfile.devel -t hypercdb-devel . 
