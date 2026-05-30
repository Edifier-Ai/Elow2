import type { FastifyPluginAsync } from "fastify";

export const registerAuthRoutes: FastifyPluginAsync = async (app) => {
  app.post("/apple", async () => ({ token: "local-dev-token", user: { id: "local-user" } }));
  app.post("/email/start", async () => ({ sent: true }));
  app.post("/email/verify", async () => ({
    token: "local-dev-token",
    user: { id: "local-user" }
  }));
};
