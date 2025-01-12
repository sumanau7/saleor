FROM python:3.5
ENV PYTHONUNBUFFERED 1

RUN \
 apt-get -y update && \
 apt-get install -y npm && \
 apt-get clean && \
 ln -s /usr/bin/nodejs /usr/bin/node

ADD requirements.txt /app/requirements.txt
RUN cd /app && pip install -r requirements.txt

ADD package.json /app/package.json
RUN cd /app && npm install

RUN useradd -ms /bin/bash saleor

ADD . /app
WORKDIR /app

ENV PATH $PATH:/app/node_modules/.bin
RUN echo "{\"allow_root\": true }" > ~/.bowerrc
RUN bower install && grunt
RUN python manage.py collectstatic --noinput

EXPOSE 8000
ENV PORT 8000

ENTRYPOINT ["/app/compose/entrypoint.sh"]
CMD uwsgi saleor/wsgi/uwsgi.ini
