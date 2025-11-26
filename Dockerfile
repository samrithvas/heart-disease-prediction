############################################
#        STAGE 1 — BUILD DEPS
############################################
FROM python:3.11-slim AS builder

# Install system dependencies needed to build ML packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libatlas-base-dev \
        liblapack-dev \
        gfortran \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

# Install deps to a temporary folder
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt

############################################
#        STAGE 2 — FINAL RUNTIME
############################################
FROM python:3.11-slim

WORKDIR /app

# Install only required system libs (runtime only)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libatlas-base-dev \
        liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder stage
COPY --from=builder /install /usr/local

# Copy your application
COPY . .

EXPOSE 8501

CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
