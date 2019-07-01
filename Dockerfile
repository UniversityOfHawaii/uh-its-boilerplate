#
# runs a simple web server to serve the boilerplate
#
FROM nginx:mainline-alpine
COPY ./html /usr/share/nginx/html
