FROM ubuntu

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user
#ADD mydata /home/user/mydata

ENTRYPOINT ["tail", "-f", "/dev/null"]