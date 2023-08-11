export function toFixed(num?: BigInt): string {
  if (!num) {
    return "0.00";
  }

  let numValue = num.valueOf() / BigInt(10 ** 18);
  return Number(numValue.toString()).toFixed(2);
}

export function toBigInt(num?: number): BigInt {
  if (!num) {
    return BigInt(0);
  }

  return BigInt(num * 10 ** 18);
}

export function toNumber(num?: BigInt): number {
  if (!num) {
    return 0;
  }

  return Number(num.valueOf() / BigInt(10 ** 18));
}
