# CardVerse Backend

Node.js, Express, MongoDB, JWT, and Socket.IO backend for CardVerse.

## Local setup

```bash
cp .env.example .env
npm install
npm run dev
```

Start MongoDB locally before the backend:

```bash
brew services start mongodb-community
```

The default development port is `5050`. Health checks:

```bash
curl http://localhost:5050/
curl http://localhost:5050/health
```

## Environment

Required:

- `MONGO_URI`
- `JWT_SECRET`
- `GOOGLE_CLIENT_IDS` (comma-separated OAuth client IDs accepted as token audiences)

Production deployments should set an explicit `CORS_ORIGIN`, use a long random
JWT secret, and point `MONGO_URI` to MongoDB Atlas or another secured MongoDB
deployment. Google sign-in posts an ID token to `POST /api/auth/google`; the
backend verifies its signature, issuer, expiry, and audience before issuing a
CardVerse JWT. Email/password registration and login endpoints are not exposed.

## Production

```bash
npm ci
npm run start:prod
```

Render, Railway, and Fly.io can run the backend with the production command.
Expose the configured `PORT`, allow WebSocket traffic, and configure persistent
MongoDB separately. Active rooms and live games are stored in memory, so a
single instance is recommended until a shared adapter such as Redis is added.
