FROM python:3.10-slim AS compiler

ARG SERVER_PORT
RUN test -n "${SERVER_PORT}"
ENV SERVER_PORT=${SERVER_PORT}

ARG WEB_PORT
RUN test -n "${WEB_PORT}"
ENV WEB_PORT=${WEB_PORT}

COPY requirements.txt .
RUN pip install -r ./requirements.txt

COPY compile.py .
COPY nginx.conf.j2 .
RUN python ./compile.py

FROM nginx:1.21.6
COPY --from=compiler nginx.conf /etc/nginx/conf.d

CMD ["nginx", "-g", "daemon off;"]
