FROM python:3.14.4-slim-bookworm AS base

WORKDIR /app

COPY ./services/ranking/requirements.txt /app/requirements.txt

RUN pip install --no-cache --upgrade -r /app/requirements.txt

FROM base AS style-check

COPY ./src /app/src

RUN ruff check . && ruff format --check --diff

FROM base AS final

WORKDIR /app

COPY ./api/proto ./api/proto

RUN python -m grpc_tools.protoc -I grpc/gen/python=./api/proto \
  --python_out=. --grpc_python_out=. \
  ./api/proto/*.proto

COPY ./services/ranking/src /app/src

ENTRYPOINT ["fastapi", "run", "src/main.py", "--port", "80"]