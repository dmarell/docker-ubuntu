FROM ubuntu

RUN useradd -ms /bin/bash pipeline
USER pipeline
WORKDIR /home/pipeline
ADD node-app /home/pipeline/node-app

ENTRYPOINT ["tail", "-f", "/dev/null"]