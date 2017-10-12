FROM python:2.7-slim
WORKDIR /app
ADD . /app
RUN pip install -r requirements.txt
EXPOSE 80
ENV FLASK_DEBUG=1
CMD ["python", "app.py"]
