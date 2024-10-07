all: docker

docker: docker-build-crtpatch

docker-build-crtpatch:
	docker build -t ouestdarq/crtpatch:latest ./
