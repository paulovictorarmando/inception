FROM debian:bookworm
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
    chmod 777 /var/lib/mysql /run/mysqld
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh
EXPOSE 3306
ENTRYPOINT ["/setup.sh"]


#docker tem dois times
# Build time: docker build
# runtime: docker run
# build: construção da imagem, instalação de dependências, configuração do ambiente
# runtime: execução do container, inicialização do serviço, monitoramento do processo


#Dockerfile:
    #👉 prepara a imagem “sem volume”

#setup.sh:
    #👉 corrige tudo que o volume pode estragar

#   docker build -t mariadb-custom
#lê o Dockerfile
#executa cada RUN
#cria a imagem final

#   docker images
#Ver imagens:

#   docker ps - Ver se o container está rodando
