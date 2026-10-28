mkdir -p $(pwd)/webui_data

podman run --detach --pull newer --replace --publish 8080:8080 \
  -e OPENAI_API_BASE_URL=http://host.containers.internal:8000/v1 -e OPENAI_API_KEY=vllmApikey \
  -e WEBUI_SECRET_KEY=change-me-to-a-long-random-secret -e ENABLE_SIGNUP=false \
  -e WEBUI_ADMIN_EMAIL="admin@openwebui.local" \
  -e WEBUI_ADMIN_PASSWORD="SecurePassword123" \
  -v $(pwd)/webui_data:/app/backend/data \
  -e WEBUI_AUTH=True \
  --name open-webui --restart always ghcr.io/open-webui/open-webui:main
