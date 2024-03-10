# https://tailwindcss.com/blog/standalone-cli
# update config: ./tailwindcss init
update-tailwind:
	curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64
	chmod +x tailwindcss-macos-arm64
	mv tailwindcss-macos-arm64 ./web/tailwindcss

watch-tailwind:
	./web/tailwindcss -i ./web/input.css -o ./web/output.css --watch
compile-tailwind:
	./web/tailwindcss -i ./web/input.css -o ./web/output.css --minify