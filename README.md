
<p align="center">
  <img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" />
  <img src="https://raw.githubusercontent.com/PokeAPI/media/master/logo/pokeapi_256.png" width="180" alt="PokéAPI" />
</p>

<h1 align="center">Pokédex API</h1>

<p align="center">
  API RESTful para la gestión de Pokémon construida con <strong>NestJS</strong>, <strong>MongoDB</strong> y <strong>PokéAPI</strong>.
  Incluye operaciones CRUD completas, paginación, semilla de datos desde la PokéAPI y despliegue con Docker.
</p>

<p align="center">
  <a href="http://nestjs.com/" target="_blank"><img src="https://img.shields.io/badge/NestJS-11-E0234E?style=for-the-badge&logo=nestjs" alt="NestJS 11" /></a>
  <a href="https://www.mongodb.com/" target="_blank"><img src="https://img.shields.io/badge/MongoDB-8-47A248?style=for-the-badge&logo=mongodb" alt="MongoDB 8" /></a>
  <a href="https://www.docker.com/" target="_blank"><img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker" alt="Docker" /></a>
  <a href="https://pokeapi.co/" target="_blank"><img src="https://img.shields.io/badge/PokéAPI-EF5350?style=for-the-badge" alt="PokéAPI" /></a>
  <a href="https://pnpm.io/" target="_blank"><img src="https://img.shields.io/badge/pnpm-F69220?style=for-the-badge&logo=pnpm" alt="pnpm" /></a>
</p>

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Stack Tecnológico](#-stack-tecnológico)
- [Arquitectura](#-arquitectura)
- [Endpoints de la API](#-endpoints-de-la-api)
- [Requisitos Previos](#-requisitos-previos)
- [Configuración](#-configuración)
  - [Variables de Entorno](#variables-de-entorno)
  - [Desarrollo Local](#desarrollo-local)
  - [Producción con Docker](#producción-con-docker)
- [Seed de Datos](#-seed-de-datos)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Scripts Disponibles](#-scripts-disponibles)
- [Pruebas](#-pruebas)
- [Licencia](#-licencia)

---

## ✨ Características

- **CRUD completo** de Pokémon con validaciones y paginación.
- **Búsqueda flexible**: por número de Pokédex, nombre o ID de MongoDB.
- **Seed automático**: carga 650 Pokémon desde la [PokéAPI](https://pokeapi.co/) oficial.
- **Validación de datos** con `class-validator` y Joi.
- **Paginación configurable** mediante variable de entorno.
- **Frontend estático** servido desde `public/`.
- **Despliegue multi-entorno** con docker-compose (dev y prod).
- **Build multi-etapa** de Docker para imágenes de producción optimizadas.

---

## 🛠 Stack Tecnológico

| Tecnología        | Versión | Propósito                           |
|-------------------|---------|-------------------------------------|
| [NestJS](https://nestjs.com/) | 11 | Framework backend Node.js |
| [MongoDB](https://www.mongodb.com/) | 8 | Base de datos NoSQL |
| [Mongoose](https://mongoosejs.com/) | 8 | ODM para MongoDB |
| [PokéAPI](https://pokeapi.co/) | — | Fuente de datos de Pokémon |
| [Docker](https://www.docker.com/) | — | Contenedores y orquestación |
| [pnpm](https://pnpm.io/) | — | Gestor de paquetes |
| [Joi](https://joi.dev/) | — | Validación de variables de entorno |
| [class-validator](https://github.com/typestack/class-validator) | — | Validación de DTOs |

---

## 🏗 Arquitectura

```
Cliente HTTP (curl / Postman / Frontend)
        │
   ┌────┴────┐
   │  NestJS  │
   │  App     │
   └────┬────┘
        │
   ┌────┴─────────────────────┐
   │  ServeStaticModule        │  ──>  /  (index.html)
   │  (public/)                │
   └────┬──────────────────────┘
        │
   ┌────┴──────────────┐
   │  ConfigModule       │  ──>  .env (Joi validation)
   │  (app.config)       │
   └────┬──────────────┘
        │
   ┌────┴──────────────────────────────┐
   │  MongooseModule                    │  ──>  MongoDB
   │  (esquema: name, no)               │
   └────┬──────────────────────────────┘
        │
   ┌────┴───────┐   ┌──────┴──────┐   ┌──────┴─────┐
   │ Pokemon    │   │  Seed       │   │  Common    │
   │ Module     │   │  Module     │   │  Module    │
   │            │   │             │   │            │
   │ Controller │   │  Controller │   │ AxiosAdapt │
   │ Service    │   │  Service    │   │ MongoIdPipe│
   │ DTOs       │   │  → PokéAPI  │   │ Pagination │
   │ Entity     │   │             │   │ HttpAdapt  │
   └────────────┘   └─────────────┘   └────────────┘
```

### Módulos

| Módulo | Descripción |
|--------|-------------|
| **PokemonModule** | CRUD de Pokémon con modelo Mongoose (name, no). |
| **SeedModule** | Pobla la base de datos con 650 Pokémon desde la PokéAPI. |
| **CommonModule** | Utilidades compartidas: adaptador HTTP (axios), pipes personalizados, DTOs genéricos. |

---

## 📡 Endpoints de la API

> Todos los endpoints están prefijados con `/api`.

### Pokémon

| Método   | Ruta                 | Descripción                                      | Validación         |
|----------|----------------------|--------------------------------------------------|--------------------|
| `POST`   | `/api/pokemon`       | Crear un nuevo Pokémon                           | CreatePokemonDto   |
| `GET`    | `/api/pokemon`       | Listar todos los Pokémon (con paginación)        | PaginationDto      |
| `GET`    | `/api/pokemon/:term` | Buscar por número, nombre o ID de MongoDB        | —                  |
| `PATCH`  | `/api/pokemon/:term` | Actualizar parcialmente un Pokémon               | UpdatePokemonDto   |
| `DELETE` | `/api/pokemon/:id`   | Eliminar un Pokémon por ID de MongoDB            | MongoIdPipe        |

#### Paginación

La ruta `GET /api/pokemon` acepta los siguientes query parameters:

| Parámetro | Tipo   | Default | Descripción                     |
|-----------|--------|---------|---------------------------------|
| `limit`   | number | `10`    | Cantidad de resultados por página |
| `offset`  | number | `0`     | Número de registros a saltar    |

> El límite por defecto se configura mediante la variable `DEFAULT_LIMIT`.

#### Búsqueda flexible

`GET /api/pokemon/:term` intenta la resolución en este orden:

1. **Número** (`no`): si el término es un número positivo.
2. **ID de MongoDB**: si el término es un ObjectId válido (24 caracteres hexadecimales).
3. **Nombre**: búsqueda exacta case-insensitive.

### Seed

| Método | Ruta          | Descripción                                           |
|--------|---------------|-------------------------------------------------------|
| `GET`  | `/api/seed`   | Elimina todos los Pokémon y carga 650 desde PokéAPI |

### Frontend

| Método | Ruta | Descripción                  |
|--------|------|------------------------------|
| `GET`  | `/`  | Sirve `public/index.html`    |

---

## 📋 Requisitos Previos

- [Node.js](https://nodejs.org/) ≥ 22
- [pnpm](https://pnpm.io/) (`npm i -g pnpm`)
- [Docker](https://www.docker.com/) y [Docker Compose](https://docs.docker.com/compose/)
- [NestJS CLI](https://docs.nestjs.com/cli/overview) (`npm i -g @nestjs/cli`)

---

## ⚙️ Configuración

### Variables de Entorno

| Variable         | Requerida | Default | Descripción                             |
|------------------|-----------|---------|-----------------------------------------|
| `MONGODB_URI`    | ✅        | —       | URI de conexión a MongoDB               |
| `PORT`           | ❌        | `3000`  | Puerto del servidor                     |
| `DEFAULT_LIMIT`  | ❌        | `10`    | Límite por defecto en paginación        |

### Desarrollo Local

1. **Clonar el repositorio**

   ```bash
   git clone <repo-url>
   cd pokedex
   ```

2. **Instalar dependencias**

   ```bash
   pnpm install
   ```

3. **Configurar variables de entorno**

   ```bash
   cp .env.template .env
   ```

   Edita `.env` con los valores adecuados. Ejemplo:

   ```env
   MONGODB_URI=mongodb://127.0.0.1:27017/nest-pokemon
   PORT=3000
   DEFAULT_LIMIT=10
   ```

4. **Levantar MongoDB con Docker**

   ```bash
   docker compose up -d
   ```

   Esto inicia un contenedor con MongoDB 5 en `localhost:27017`.

5. **Iniciar la aplicación**

   ```bash
   pnpm start:dev
   ```

   El servidor estará disponible en `http://localhost:3000`.

6. **Poblar la base de datos**

   ```bash
   curl http://localhost:3000/api/seed
   ```

### Producción con Docker

1. **Crear el archivo de entorno de producción**

   ```bash
   cp .env.template .env.prod
   ```

   Edita `.env.prod` con los valores de producción. Asegúrate de que `MONGODB_URI` apunte a la base de datos correcta dentro de la red de Docker (ej. `mongodb://db:27017/nest-pokemon`).

2. **Construir y levantar los servicios**

   ```bash
   docker compose -f docker-compose.prod.yaml --env-file .env.prod up --build
   ```

   Esto construye la imagen de la aplicación con un build multi-etapa (solo dependencias de producción) y levanta junto con MongoDB.

---

## 🌱 Seed de Datos

El endpoint `GET /api/seed` realiza las siguientes operaciones:

1. **Elimina** todos los documentos de Pokémon existentes.
2. **Solicita** 650 Pokémon a `https://pokeapi.co/api/v2/pokemon?limit=650`.
3. **Inserta** en lote (`insertMany`) los datos obtenidos en MongoDB.

> ⚠️ Esta operación es destructiva: reemplaza por completo la colección de Pokémon.

---

## 📁 Estructura del Proyecto

```
pokedex/
├── public/                  # Frontend estático
│   ├── index.html
│   └── css/styles.css
├── src/
│   ├── common/              # Módulo compartido
│   │   ├── adapters/        #   AxiosAdapter (HTTP client)
│   │   ├── dto/             #   PaginationDto
│   │   ├── interfaces/      #   HttpAdapter interface
│   │   └── pipes/           #   ParseMongoIdPipe
│   ├── config/              # Configuración de NestJS
│   │   ├── app.config.ts    #   Variables de entorno
│   │   └── joi.validation.ts #   Esquema de validación Joi
│   ├── pokemon/             # Módulo de Pokémon
│   │   ├── dto/             #   CreatePokemonDto, UpdatePokemonDto
│   │   ├── entities/        #   Pokemon entity (Mongoose schema)
│   │   ├── pokemon.controller.ts
│   │   ├── pokemon.module.ts
│   │   └── pokemon.service.ts
│   ├── seed/                # Módulo de seed
│   │   ├── seed.controller.ts
│   │   ├── seed.module.ts
│   │   └── seed.service.ts
│   ├── app.module.ts        # Módulo raíz
│   └── main.ts              # Punto de entrada
├── test/                    # Pruebas e2e
│   ├── app.e2e-spec.ts
│   └── jest-e2e.json
├── mongo/                   # Datos persistentes de MongoDB (volumen Docker)
├── docker-compose.yaml      # Docker Compose para desarrollo
├── docker-compose.prod.yaml # Docker Compose para producción
├── Dockerfile               # Build multi-etapa para producción
├── .env.template            # Plantilla de variables de entorno
└── package.json
```

---

## 📜 Scripts Disponibles

| Script            | Comando                              | Descripción                          |
|-------------------|--------------------------------------|--------------------------------------|
| `start:dev`       | `nest start --watch`                 | Desarrollo con recarga automática    |
| `start:debug`     | `nest start --debug --watch`         | Desarrollo con depuración            |
| `start:prod`      | `node dist/main`                     | Producción                           |
| `build`           | `nest build`                         | Compilar TypeScript                  |
| `lint`            | `eslint "{src,test}/**/*.ts" --fix`  | Análisis estático y corrección       |
| `format`          | `prettier --write "src/**/*.ts"`     | Formateo de código                   |
| `test`            | `jest`                               | Pruebas unitarias                    |
| `test:watch`      | `jest --watch`                       | Pruebas unitarias en modo watch      |
| `test:cov`        | `jest --coverage`                    | Pruebas unitarias con cobertura      |
| `test:e2e`        | `jest --config ./test/jest-e2e.json` | Pruebas end-to-end                   |

---

## 🧪 Pruebas

```bash
# Pruebas unitarias
pnpm test

# Pruebas con cobertura
pnpm test:cov

# Pruebas end-to-end
pnpm test:e2e
```

Actualmente el proyecto incluye un test e2e de ejemplo en `test/app.e2e-spec.ts`.

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request para sugerir cambios.

---

## 📄 Licencia

Este proyecto es de uso educativo y no está afiliado oficialmente con Nintendo, Game Freak ni The Pokémon Company. Los datos de Pokémon son proporcionados por [PokéAPI](https://pokeapi.co/).
