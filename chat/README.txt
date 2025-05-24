# Instrucciones para Clientes

Bienvenido a la aplicación de chat. Sigue estos pasos para conectarte y usar el sistema como cliente:

## 1. Requisitos previos
- Tener instalado Elixir en tu sistema.
- Clonar este repositorio en tu computadora.

## 2. Instalación
1. Abre una terminal en la carpeta del proyecto.
2. Ejecuta el siguiente comando para instalar las dependencias:
   ```shell
   mix deps.get
   ```

## 3. Iniciar el servidor de chat
1. En una terminal, ejecuta:
   ```shell
   iex -S mix
   ```
2. El servidor de chat estará listo para aceptar conexiones de clientes.

## 4. Conectarse como cliente
1. Abre otra terminal en la carpeta del proyecto.
2. Ejecuta el cliente con:
   ```shell
   iex -S mix
   ```
3. Usa los comandos proporcionados por la aplicación para:
   - Registrarte o iniciar sesión.
   - Unirte a una sala de chat.
   - Enviar y recibir mensajes.

## 5. Comandos útiles
- Consulta la documentación interna o los mensajes de ayuda en la consola para ver los comandos disponibles.

## 6. Salir
- Para salir, puedes usar `Ctrl+C` dos veces en la terminal.

---
Si tienes dudas, revisa los archivos en la carpeta `lib/` para más detalles sobre las funciones disponibles.
