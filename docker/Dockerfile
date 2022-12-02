FROM python:latest

WORKDIR /home

COPY main.py ./
COPY requirements.txt ./
COPY config.json ./

RUN ["pip3", "install", "-r", "requirements.txt"]
CMD ["python", "./main.py"]
