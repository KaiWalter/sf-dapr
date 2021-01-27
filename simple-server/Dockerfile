FROM python:3.7-slim

WORKDIR /app

ADD requirements.txt .
RUN pip install -r requirements.txt

COPY *.py /app/

ENV PORT=80

CMD [ "python", "server.py" ]