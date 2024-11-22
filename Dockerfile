# ========================================================== base ==========================================================
FROM python:3.13.0-bookworm AS base
ARG POETRY_VERSION=1.8
ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PIP_DEFAULT_TIMEOUT=100 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  PIP_NO_CACHE_DIR=1 \
  POETRY_VENV_PATH="/root/poetry" \
  VENV_PATH="/root/venv"

# ========================================================== poetry ==========================================================

FROM base AS poetry

WORKDIR /work

RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

# Install poetry
ARG POETRY_VERSION=1.8.0
RUN python3.13 -m virtualenv "$POETRY_VENV_PATH" &&\
  "$POETRY_VENV_PATH/bin/pip" install "poetry==$POETRY_VERSION" &&\
  "$POETRY_VENV_PATH/bin/poetry" config virtualenvs.prefer-active-python true &&\
  python3.13 -m virtualenv --no-pip --no-setuptools --copies $VENV_PATH

# Create venv
RUN python3.13 -m virtualenv --no-pip --no-setuptools --copies $VENV_PATH

# Install package dependencies
COPY ./pyproject.toml ./poetry.lock* ./
RUN . "$VENV_PATH/bin/activate" && "$POETRY_VENV_PATH/bin/poetry" install --no-root --without=dev

# ========================================================== build ==========================================================

FROM poetry AS build

ARG PACKAGE_VERSION=0.1.0
RUN --mount=src=.,target=.,rw\
  . "$VENV_PATH/bin/activate" && poetry version $PACKAGE_VERSION &&\
  . "$VENV_PATH/bin/activate" && poetry build -f wheel &&\
  pip install --target="$VENV_PATH/lib/python3.13/site-packages/" --no-deps dist/*.whl

# ========================================================== dev ==========================================================

FROM poetry AS dev

# Install package
COPY . .
RUN . "$VENV_PATH/bin/activate" && "$POETRY_VENV_PATH/bin/poetry" install --only-root

# install bash-completion
RUN DEBIAN_FRONTEND=noninteractive apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y bash-completion

# make sure poetry is in path
RUN mkdir -p $HOME/.local/bin && ln -s $POETRY_VENV_PATH/bin/poetry $HOME/.local/bin/poetry
RUN "$POETRY_VENV_PATH/bin/poetry" completions bash > $HOME/.poetry_completion.bash &&\
  echo ". $HOME/.poetry_completion.bash" >> $HOME/.bashrc

# make sure package's python is first in path
ENV PATH="$VENV_PATH/bin:${PATH}"

# Install dev dependencies
COPY ./poetry.lock* ./
RUN --mount=src=pyproject.toml,target=pyproject.toml\
  . "$VENV_PATH/bin/activate" && "$POETRY_VENV_PATH/bin/poetry" install --only dev

ENTRYPOINT ["python"]

# ========================================================== production ==========================================================

FROM base AS production

COPY --link --from=build $VENV_PATH $VENV_PATH

# make sure package's python is first in path
ENV PATH="$VENV_PATH/bin:${PATH}"

ENTRYPOINT ["python", "-m", "webhooktester"]