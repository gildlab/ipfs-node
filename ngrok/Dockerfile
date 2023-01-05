FROM ngrok/ngrok:debian

# include netcat as it can be useful for debugging connectivity
# with the ipfs container
USER root
RUN apt-get update
RUN apt-get install netcat -y

USER ngrok