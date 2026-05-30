import type { FastifyPluginAsync } from "fastify";

export const registerIapRoutes: FastifyPluginAsync = async (app) => {
  app.post("/verify", async () => ({ status: "active", type: "lifetime", expiresAt: null }));
};
