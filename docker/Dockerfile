FROM postgres:16-alpine

# Copiar scripts de inicialización
COPY ../migrations/*.sql /docker-entrypoint-initdb.d/

# Configuración de localización
ENV LANG=es_ES.utf8
ENV LC_ALL=es_ES.UTF-8

EXPOSE 5432
