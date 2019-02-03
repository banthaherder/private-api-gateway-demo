# Builds lambda functions into a tmp dir and zips them for deployment
build:
	mkdir -p .tmp .tmp/go-bin .tmp/zips
	for d in lambda-src/*; do \
		for subdir in $$d; do \
			mkdir -p ./.tmp/go-bin/$${subdir##*/}; \
			for file in $$subdir/*; do \
				f=$${file##*/}; \
				env GOOS=linux GOARCH=amd64 go build -o ./.tmp/go-bin/$${subdir##*/}/main $$file; \
				zip -ruj ./.tmp/zips/$${f%.*}.zip ./.tmp/go-bin/$${subdir##*/}/main; \
			done; \
		done; \
	done;