FROM python:2.7-slim
WORKDIR /app
ADD . /app
RUN pip install -r webroot/requirements.txt
EXPOSE 80
ENV FLASK_DEBUG=1
CMD ["python", "app.py"]
