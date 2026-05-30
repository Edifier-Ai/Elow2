import { describe, expect, test } from "vitest";
import { buildServer } from "../src/server.js";

describe("backend scaffold", () => {
  test("returns stable local auth responses", async () => {
    const app = buildServer();

    const apple = await app.inject({ method: "POST", url: "/auth/apple" });
    const emailStart = await app.inject({ method: "POST", url: "/auth/email/start" });
    const emailVerify = await app.inject({ method: "POST", url: "/auth/email/verify" });

    expect(apple.statusCode).toBe(200);
    expect(apple.json()).toEqual({ token: "local-dev-token", user: { id: "local-user" } });
    expect(emailStart.statusCode).toBe(200);
    expect(emailStart.json()).toEqual({ sent: true });
    expect(emailVerify.statusCode).toBe(200);
    expect(emailVerify.json()).toEqual({ token: "local-dev-token", user: { id: "local-user" } });
    await app.close();
  });

  test("returns stable local health response", async () => {
    const app = buildServer();

    const response = await app.inject({ method: "GET", url: "/health" });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ ok: true });
    await app.close();
  });

  test("returns stable local iap response", async () => {
    const app = buildServer();

    const response = await app.inject({ method: "POST", url: "/iap/verify" });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ status: "active", type: "lifetime", expiresAt: null });
    await app.close();
  });

  test("returns stable local sync responses", async () => {
    const app = buildServer();

    const push = await app.inject({ method: "POST", url: "/sync/push" });
    const pull = await app.inject({ method: "GET", url: "/sync/pull" });

    expect(push.statusCode).toBe(200);
    expect(push.json()).toEqual({ accepted: true, cursor: "local-cursor" });
    expect(pull.statusCode).toBe(200);
    expect(pull.json()).toEqual({ cursor: "local-cursor", records: [] });
    await app.close();
  });

  test("returns stable local catalog response", async () => {
    const app = buildServer();

    const response = await app.inject({ method: "GET", url: "/catalog/" });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({
      stickers: [
        { id: "foam-01", name: "Foam Shell", rarity: "base", isPremium: false },
        { id: "moon-cup", name: "Moon Cup", rarity: "premium", isPremium: true }
      ],
      characters: [{ id: "first-sip", name: "First Sip", unlockRule: "Create first record" }],
      themes: [
        { id: "gallery-white", name: "Gallery White", isPremium: false },
        { id: "studio-clay", name: "Studio Clay", isPremium: true }
      ]
    });
    await app.close();
  });
});
