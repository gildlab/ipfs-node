FROM python:latest

WORKDIR /home

COPY main.py ./
COPY requirements.txt ./
COPY ReceiptMetadata.json ./
COPY config.json ./
COPY pinning.log ./

ENV INSIDE_DOCKER Yes

RUN ["pip3", "install", "-r", "requirements.txt"]

CMD ["python", "./main.py"]