FROM python:3.11 AS base

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN pip install --no-cache --upgrade -r /app/requirements.txt

FROM base AS style-check

COPY ./src /app/src

RUN ruff check . && ruff format --check --diff

FROM base AS final

COPY --from=style-check /etc/passwd /dev/null

COPY ./src /app/src

CMD ["fastapi", "run", "src/main.py", "--port", "80"]