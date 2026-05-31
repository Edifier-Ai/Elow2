import { describe, expect, it } from "vitest";
import { chooseWinningRecord } from "../src/domain/sync.js";

describe("chooseWinningRecord", () => {
  it("keeps the newest updatedAt value", () => {
    const older = { id: "r1", name: "Old", updatedAt: "2026-05-01T00:00:00.000Z" };
    const newer = { id: "r1", name: "New", updatedAt: "2026-05-02T00:00:00.000Z" };

    expect(chooseWinningRecord(older, newer)).toEqual(newer);
  });
});
