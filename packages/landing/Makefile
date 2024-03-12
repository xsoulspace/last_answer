# https://tailwindcss.com/blog/standalone-cli
# update config: ./tailwindcss init
update-tailwind:
	curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64
	chmod +x tailwindcss-macos-arm64
	mv tailwindcss-macos-arm64 ./tailwindcss

watch-tailwind:
	./tailwindcss -i ./web/styles.css -o ./build/output.css --watch
compile-tailwind:
	./tailwindcss -i ./web/styles.css -o ./build/jaspr/output.css --minify
