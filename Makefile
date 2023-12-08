all: smallstep

smallstep:
	docker build -t proxymurder/smallstep:latest ./