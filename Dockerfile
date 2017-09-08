FROM ubuntu

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

ENTRYPOINT ["tail", "-f", "/dev/null"]