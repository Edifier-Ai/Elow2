import { describe, expect, it } from "vitest";
import { normalizeEntitlement } from "../src/domain/entitlements.js";

describe("normalizeEntitlement", () => {
  it("returns lifetime for lifetime product", () => {
    expect(normalizeEntitlement({ productId: "whitebrew.lifetime", expiresAt: null })).toEqual({
      status: "active",
      type: "lifetime",
      expiresAt: null
    });
  });
});
