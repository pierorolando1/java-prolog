FROM openjdk:17-slim

# Install SWI-Prolog and necessary dependencies
RUN apt-get update && apt-get install -y swi-prolog-java libsqlite3-dev
RUN apt-get install maven -y

# Instalar Maven
#RUN apk update && apk add maven

# Set the working directory in the container
WORKDIR /app

# Set environment variables
ENV SWI_HOME_DIR=/usr/lib/swi-prolog
ENV LD_LIBRARY_PATH=${SWI_HOME_DIR}/lib/x86_64-linux:${LD_LIBRARY_PATH}
ENV CLASSPATH=/usr/lib/swi-prolog/lib/jpl.jar:${CLASSPATH}
ENV LD_PRELOAD=/usr/lib/libswipl.so

# Copiar el archivo pom.xml y descargar dependencias
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiar el código fuente
COPY src /app/src

# Construir el proyecto
RUN mvn package

# Exponer el puerto en el que la aplicación estará escuchando
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["java", "-Djava.library.path=/usr/lib/swi-prolog/lib/x86_64-linux", "-jar", "target/java-prolog-api-1.0-SNAPSHOT.jar"]

