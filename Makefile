.PHONY: all dockerfiles images deploy

dockerfiles:
	@scripts/generate-dockerfiles

images:
	@scripts/build-images

deploy:
	@scripts/deploy $(DEPLOY_ARGS)

all: dockerfiles images deploy
