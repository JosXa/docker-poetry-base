UNFINISHED
FROM python:3.9-slim as PoetryBase

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y git curl gcc libpq-dev libffi-dev g++
WORKDIR /app

FROM base as builder

ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.1.3

RUN pip install "poetry==$POETRY_VERSION"
RUN python -m venv /venv

COPY pyproject.toml poetry.lock ./
RUN . /venv/bin/activate && poetry install --no-dev --no-root

COPY . .
RUN . /venv/bin/activate && poetry build

FROM base as final

COPY --from=builder /venv /venv
COPY --from=builder /app/dist .
COPY docker-entrypoint.sh ./

RUN . /venv/bin/activate && pip install *.whl
CMD ["./docker-entrypoint.sh"]



FROM python:3.8-slim AS PoetryBase

RUN apt-get update
RUN apt-get install -y git curl libpq-dev gcc

# https://github.com/python-poetry/poetry/issues/1579#issuecomment-598570212
RUN python -m venv "/opt/venv"
RUN . /opt/venv/bin/activate
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - -y
ENV PATH="/root/.poetry/bin:/opt/venv/bin:$PATH"
RUN poetry config virtualenvs.create false

RUN python -m pip install --upgrade pip

# Most of my projects use Poe as a script runner
RUN pip install poethepoet

ENV PYTHONUNBUFFERED=1
