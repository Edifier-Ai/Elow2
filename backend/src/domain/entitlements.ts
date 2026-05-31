export type EntitlementInput = {
  productId: string;
  expiresAt: string | null;
};

export type EntitlementState = {
  status: "active" | "expired";
  type: "annual" | "lifetime";
  expiresAt: string | null;
};

export function normalizeEntitlement(input: EntitlementInput): EntitlementState {
  if (input.productId === "whitebrew.lifetime") {
    return { status: "active", type: "lifetime", expiresAt: null };
  }

  if (input.expiresAt && Date.parse(input.expiresAt) > Date.now()) {
    return { status: "active", type: "annual", expiresAt: input.expiresAt };
  }

  return { status: "expired", type: "annual", expiresAt: input.expiresAt };
}
