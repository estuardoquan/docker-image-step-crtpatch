all: docker-smallstep-service

docker-smallstep-service:
	docker build -t proxymurder/smallstep:latest ./