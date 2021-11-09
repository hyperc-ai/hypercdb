all:
	docker build -t hypercdb/hypercdb:latest . 

push:
	docker push hypercdb/hypercdb:latest

login:
	docker login