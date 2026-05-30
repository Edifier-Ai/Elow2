import type { FastifyPluginAsync } from "fastify";

export const registerCatalogRoutes: FastifyPluginAsync = async (app) => {
  app.get("/", async () => ({
    stickers: [
      { id: "foam-01", name: "Foam Shell", rarity: "base", isPremium: false },
      { id: "moon-cup", name: "Moon Cup", rarity: "premium", isPremium: true }
    ],
    characters: [{ id: "first-sip", name: "First Sip", unlockRule: "Create first record" }],
    themes: [
      { id: "gallery-white", name: "Gallery White", isPremium: false },
      { id: "studio-clay", name: "Studio Clay", isPremium: true }
    ]
  }));
};
