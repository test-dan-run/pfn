# docker build -t pfn:v0.0.1

FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime

ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y sudo build-essential cmake \ 
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE 1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED 1

# Install pip requirements
ADD requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

#docker container starts with bash
WORKDIR /workspace
RUN ["bash"]