FROM aequitasventures/chatwoot-base:latest

RUN chmod +x docker/entrypoints/webpack.sh

EXPOSE 3035
CMD ["bin/webpack-dev-server"]
