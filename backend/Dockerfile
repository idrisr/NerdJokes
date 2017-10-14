FROM python:2.7-slim
WORKDIR /app
ADD . /app
RUN pip install -r requirements.txt

RUN apt-get update && apt-get install -y \
sqlite3

RUN sqlite3 jokes.db < db/create_db.sql
EXPOSE 80
ENV FLASK_DEBUG=1
CMD ["python", "app.py"]

