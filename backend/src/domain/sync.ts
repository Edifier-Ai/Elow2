export type SyncComparableRecord = {
  id: string;
  updatedAt: string;
  [key: string]: unknown;
};

export function chooseWinningRecord<T extends SyncComparableRecord>(local: T, incoming: T): T {
  const localTime = Date.parse(local.updatedAt);
  const incomingTime = Date.parse(incoming.updatedAt);

  if (incomingTime >= localTime) {
    return incoming;
  }

  return local;
}
