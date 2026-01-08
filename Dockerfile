FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/lazarus_core/ ./src/lazarus_core/
COPY schemas/ ./schemas/
COPY templates/ ./templates/
COPY pyproject.toml .
COPY main.py .
RUN pip install -e .
USER 1000
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
