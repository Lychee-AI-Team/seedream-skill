FROM python:3.11-slim AS builder

LABEL org.opencontainers.image.title="volcengine-skill" \
      org.opencontainers.image.description="Production image for Volcengine API CLI skill" \
      org.opencontainers.image.source="https://github.com/mastercui/ai-agent-cli"

WORKDIR /app

COPY volcengine-api/requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r /app/requirements.txt


FROM python:3.11-slim AS runtime

LABEL org.opencontainers.image.title="volcengine-skill" \
      org.opencontainers.image.description="Production image for Volcengine API CLI skill" \
      org.opencontainers.image.source="https://github.com/mastercui/ai-agent-cli"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/volcengine-api

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app --home-dir /app app

COPY --from=builder /install /usr/local
COPY volcengine-api/ /app/volcengine-api/
COPY examples/ /app/examples/

RUN mkdir -p /app/output && chown -R app:app /app

USER app

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import toolkit" || exit 1

CMD ["python", "examples/quickstart.py"]
