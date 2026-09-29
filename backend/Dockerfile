FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src /app/src
COPY alembic /app/alembic
COPY alembic.ini /app/

ENV PYTHONPATH=/app/src

CMD ["uvicorn", "expense_manager_backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
