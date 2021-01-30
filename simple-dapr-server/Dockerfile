FROM python:3.7-slim

WORKDIR /app

ADD requirements.txt .
RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt

COPY *.py /app/

EXPOSE 50051

CMD [ "python", "server.py" ]