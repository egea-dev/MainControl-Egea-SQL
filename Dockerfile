# Etapa de construcción
FROM node:18-alpine AS build
WORKDIR /app

# Argumentos de construcción para Vite
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_SUPABASE_MAIN_URL
ARG VITE_SUPABASE_MAIN_ANON_KEY
ARG VITE_SUPABASE_PRODUCTIVITY_URL
ARG VITE_SUPABASE_PRODUCTIVITY_ANON_KEY
ARG VITE_APP_VERSION
ARG VITE_PRINTER_API_KEY
ARG VITE_DATABASE_URL

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Etapa de producción
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
# Copiar configuración de Nginx para el proxy
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
