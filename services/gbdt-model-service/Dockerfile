FROM python:3.11

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache --upgrade -r requirements.txt

COPY ./src /code/src

CMD ["fastapi", "run", "src/main.py", "--port", "80"]
