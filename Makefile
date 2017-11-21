.PHONY: run

IMAGE := jk

run: image
	docker run \
-p 4000:4000 \
-v ${PWD}:/home/ruby/src \
-w /home/ruby -ti \
${IMAGE} \
bundle exec jekyll serve -s src

.PHONY: image
image:
	cd docker && docker build -t ${IMAGE} .
