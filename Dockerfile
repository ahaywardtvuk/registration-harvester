FROM python:3.12-slim AS build

# Any python libraries that require system libraries to be installed will likely
# need the following packages in order to build
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y build-essential git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python -m pip install -U pip wheel

WORKDIR /worker
COPY . /worker
RUN python -m pip install --no-cache-dir --upgrade /worker


# Multi-stage build to remove build-essential and git from image
# Can instead use 'RUN apt-get remove build-essential git'
FROM python:3.12-slim

WORKDIR /worker

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=build /worker /worker

USER 8080

CMD ["fastapi", "run", "src/worker/main.py", "--port", "8080"]
