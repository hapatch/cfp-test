FROM --platform=linux/amd64 python:3.10-alpine AS builder

WORKDIR /code
COPY src/requirements.txt /code
RUN pip3 install -r requirements.txt

COPY src/ /code

EXPOSE 3000

CMD ["gunicorn", "-b", ":3000", "wsgi"]