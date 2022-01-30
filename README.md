# Siren

Welcome to the repository of _Siren_, a multi-source audio player and server.

## Running locally

For the purposes of development, a `docker-compose.yml` file has been provided. It creates three services: a MongoDB database, a Flask API/auth server and an Nginx server for the React app. For its operation, setting the following environment variables is necessary:

- Environment variables with default values:
  - `COMPOSE_PROJECT_NAME`: optional Docker Compose prefix, defaults to `siren`;
  - `DB_PROT`: database protocol name for Flask, defaults to `mongodb`;
  - `DB_USER`: database username, defaults to `mongo`;
  - `DB_NAME`: database name, defaults to `siren`;
  - `DB_HOST`: database host, defaults to `mongo`, i.e. the name of the service in the Docker Compose;
  - `DB_PORT`: database port, defaults to standard `27017`;
  - `SERVER_HOST`: name of the server host, defaults to `server`, name of the service;
  - `FLASK_PORT`: Flask internal server port, defaults to `5000`;
  - `SERVER_PORT`: Flask server port, defaults to `8001`, needs to be available on the host machine;
  - `API_SERVER`: API server URL for the host, defaults to `http://localhost:${SERVER_PORT}`;
  - `AUTH_SERVER`: authentication server URL for the host, defaults to `${API_SERVER}`;
  - `HOMEPAGE`: Nginx server URL, defaults to `.`, used for setting the `homepage` field in `package.json`;
  - `WEB_PORT`: port, under which the React app is available from the host;
- Environment variables, whose values need to be provided manually:
  - `SPOTIFY_CLIENT_ID`: Spotify client ID for the registered app;
  - `SPOTIFY_CLIENT_SECRET`: Spotify client secret for the registered app;
  - `DB_PASSWORD`: database password, may as well be random if `mongo` database from the Docker Compose file is used;
  - `FLASK_SECRET`: Flask server secret, may as well be random if `server` Flask server from the Docker Compose file is used.

So, for example, one would copy `.env` file to `.env.local`, add the requisite secrets and run:

```sh
docker-compose --env-file .env.local up --build
```

A Spotify app (created in the [Dashboard](https://developer.spotify.com/dashboard/login)) is required for the functioning of the local instance. Moreover, a correct redirect URI (`${API_SERVER}/auth/spotify/callback`) must be added to the list of Redirect URIs in the settings.
