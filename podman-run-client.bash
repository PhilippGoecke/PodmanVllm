podman build --no-cache --rm --file Containerfile.Client --tag vllm:client .
podman run --interactive --tty --env VLLM_API_KEY="API_KEY" vllm:client
