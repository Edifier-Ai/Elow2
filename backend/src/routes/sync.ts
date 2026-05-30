import type { FastifyPluginAsync } from "fastify";

export const registerSyncRoutes: FastifyPluginAsync = async (app) => {
  app.post("/push", async () => ({ accepted: true, cursor: "local-cursor" }));
  app.get("/pull", async () => ({ cursor: "local-cursor", records: [] }));
};
