.PHONY: all dockerfiles images

dockerfiles:
	@scripts/generate-dockerfiles

images:
	@scripts/build-images

deploy:
	@scripts/deploy $(DEPLOY_ARGS)

all: dockerfiles images
