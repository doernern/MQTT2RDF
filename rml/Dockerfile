FROM rmlio/rmlmapper-java:v8.0.0

USER root

RUN if command -v apt-get >/dev/null 2>&1; then \
      apt-get update && apt-get install -y --no-install-recommends python3 && \
      rm -rf /var/lib/apt/lists/*; \
    elif command -v apk >/dev/null 2>&1; then \
      apk add --no-cache python3; \
    else \
      echo "No supported package manager found" && exit 1; \
    fi