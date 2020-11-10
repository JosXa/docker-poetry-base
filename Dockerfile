FROM python:3.8-slim AS PoetryBase

RUN apt-get update
RUN apt-get install -y git curl libpq-dev gcc

# https://github.com/python-poetry/poetry/issues/1579#issuecomment-598570212
RUN python -m venv "/opt/venv"
RUN . /opt/venv/bin/activate
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - -y
ENV PATH="/root/.poetry/bin:/opt/venv/bin:$PATH"
RUN poetry config virtualenvs.create false

python -m pip install --upgrade pip
