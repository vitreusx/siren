# Siren

Welcome to the repository of _Siren_, a multi-source audio player and server.

## Running with Docker Compose

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
  - `WEB_PORT`: port, under which the React app is available from the host, defaults to `3000`;
- Environment variables, whose values need to be provided manually:
  - `SPOTIFY_CLIENT_ID`: Spotify client ID for the registered app;
  - `SPOTIFY_CLIENT_SECRET`: Spotify client secret for the registered app;
  - `DB_PASSWORD`: database password, may as well be random if `mongo` database from the Docker Compose file is used;
  - `FLASK_SECRET`: Flask server secret, may as well be random if `server` Flask server from the Docker Compose file is used.

One could therefore run:

```sh
export $(cat .env | xargs)
export $(cat .env.secret | xargs)
docker-compose up --build
```

The web application should then be available over at `http://localhost:${WEB_PORT}`.

A Spotify app (created in the [Dashboard](https://developer.spotify.com/dashboard/login)) is required for the functioning of the local instance. Moreover, a correct redirect URI (`${API_SERVER}/auth/spotify/callback`) must be added to the list of Redirect URIs in the settings.

## Running with K8s on a Minikube cluster

After loading the environment variables (see above), you should run

```sh
./minikube/setup-proxy.sh
```

This command setups up a load balancer, which we need in order to obtain the cluster IP. To get it, launch:

```sh
./minikube/wait-for-ip.sh
```

and wait 'til the `EXTERNAL-IP` value is not `<pending>`. After that, run

```sh
./minikube/deploy.sh
```

## Deploying to a cluster

The infrastructure is a single `t2.micro` instance as a control node, and 4 `t2.nano` instances for running the `web`, `server`, `mongo` and `proxy` deployments. We do not use EKS, so we don't get access to load balancers etc.

Instead of a load balancer, we use `NodePort` for a gateway. Because of this, after we deploy a proxy service with `./cluster/setup-proxy.sh`, we need to get the rebound Web and server port numbers (with `kubectl get svc proxy`, column `PORT(S)`). After that, it should suffice to run `./cluster/deploy.sh` and wait for all the pods to become operational (which might take a while).

> Currently, the service is available at `http://52.87.228.242:31809/`
