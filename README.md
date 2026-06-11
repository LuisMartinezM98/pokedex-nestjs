<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

# Ejecutar en desarrollo
1. Clonar el repositorio
2. Ejecutar
```
pnpm install
```
3. Tener NEST CLI instalado
```
npm i -g @nestjs/cli
```

4. Levantar la base de datos
```
docker compose up -d
```

# Stack usado
* MongoDBŒ
* Nest

5. Clonar el archivo __.env.template__ y renombrar la copia a __.env__

6. Llenar las variables de entorno definidas en el __.env__

7. Ejecutar la aplicacion en dev:
```
pnpm start:dev
```

8. Reconstruir la base de datos con la semilla
```
https://localhost:3000/api/seed
```


# Production Build
1. Crear el archivo ```.env.prod```
2. Llenar las variables de entorno de prod
3. Crear la nueva imagen 
```
docker-compose -f docker-compose.prod.yaml --env-file .env.prod up --build
```

# Notas
Heroku redeploy sin cambios:
```
git commit --allow-empty -m "Tigger Heroky deploy"
git push heroku <master|main>
```