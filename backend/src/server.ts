import cors from "@fastify/cors";
import Fastify from "fastify";
import { registerAuthRoutes } from "./routes/auth.js";
import { registerCatalogRoutes } from "./routes/catalog.js";
import { registerIapRoutes } from "./routes/iap.js";
import { registerSyncRoutes } from "./routes/sync.js";

export function buildServer() {
  const app = Fastify({ logger: true });
  app.register(cors, { origin: true });
  app.get("/health", async () => ({ ok: true }));
  app.register(registerAuthRoutes, { prefix: "/auth" });
  app.register(registerSyncRoutes, { prefix: "/sync" });
  app.register(registerIapRoutes, { prefix: "/iap" });
  app.register(registerCatalogRoutes, { prefix: "/catalog" });
  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = buildServer();
  const port = Number(process.env.PORT ?? 8787);
  await app.listen({ host: "127.0.0.1", port });
}
