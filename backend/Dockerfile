FROM python:3.4-slim
WORKDIR /app
ADD . /app
RUN pip install -r requirements.txt

RUN apt-get update && apt-get install -y \
sqlite3

RUN sqlite3 jokes.db < db/create_db.sql
EXPOSE 80
ENV FLASK_DEBUG=1
ENV FLASK_APP=server/app.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]

