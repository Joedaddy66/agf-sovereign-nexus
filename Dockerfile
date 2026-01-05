FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY lazarus_core/ ./lazarus_core/
COPY schemas/ ./schemas/
COPY templates/ ./templates/
COPY pyproject.toml . 
RUN pip install -e .
USER 1000
EXPOSE 8080
CMD ["lazarus-omega-brief", "--help"]
