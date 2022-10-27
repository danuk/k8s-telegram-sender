FROM python:3.9
WORKDIR /app
ENTRYPOINT ["python", "/app/tlgrm_send.py"]

COPY ./app /app

RUN pip install -r /app/requirements.txt

