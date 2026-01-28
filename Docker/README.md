# SPA Welcome Docker

This folder contains a minimal single-page app (SPA) welcome page and a Dockerfile that serves it with nginx.

Build:

```
docker build -t spa-welcome:latest -f Docker/Dockerfile .
```

Run (maps container port 80 to host port 8080):

```
docker run --rm -p 8080:80 spa-welcome:latest
```

Open http://localhost:8080 to see the welcome page.
