import contracts from './contracts.json' assert { type: 'json' };
import { TronWeb } from "tronweb"
import { keccak256, toUtf8Bytes } from "ethers";  // ethers v6+
import { hextoString, sleep } from 'tronweb/utils';
import fs from 'fs';

const nodeURL = `https://lb.drpc.live/tron/${process.env.DRPC_API_KEY}`;
// Add this tiny helper (top-level, near your imports)
class RetryableError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "RetryableError";
    }
}

function isRetryable(e: any, status?: number, json?: any) {
    // Network / fetch abort / DNS / reset / timeout
    const msg = String(e?.message || e);
    if (
        msg.includes("network") ||
        msg.includes("ECONNRESET") ||
        msg.includes("ETIMEDOUT") ||
        msg.includes("ENOTFOUND") ||
        msg.includes("socket hang up") ||
        msg.includes(" The operation was aborted") || // AbortController
        msg.includes("fetch failed")
    ) return true;

    // HTTP status: rate limit / transient server errors
    if (status && (status === 429 || status >= 500)) return true;

    // JSON-RPC errors that are often transient
    const code = json?.error?.code;
    if (typeof code === "number" && [-32000, -32001, -32002, -32603].includes(code)) return true;

    return false;
}

function toOptions(retryOrOpts?: number | {
    retries?: number;
    baseDelayMs?: number;
    timeoutMs?: number;
}) {
    if (typeof retryOrOpts === "number") {
        return { retries: retryOrOpts, baseDelayMs: 400, timeoutMs: 10_000 };
    }
    return { retries: retryOrOpts?.retries ?? 3, baseDelayMs: retryOrOpts?.baseDelayMs ?? 400, timeoutMs: retryOrOpts?.timeoutMs ?? 10_000 };
}

// --- Replacement ---
async function callContract(
    contract: string,
    signature: string,
    retryOrOpts: number | { retries?: number; baseDelayMs?: number; timeoutMs?: number } = 3
) {
    const { retries, baseDelayMs, timeoutMs } = toOptions(retryOrOpts);

    const hash = keccak256(toUtf8Bytes(signature));
    const selector = "0x" + hash.slice(2, 10);

    const body = {
        jsonrpc: "2.0",
        method: "eth_call",
        params: [
            {
                to: `0x${TronWeb.address.toHex(contract).replace(/^41/, "")}`,
                data: selector
            },
            "latest"
        ],
        id: 1
    };

    // console.log(signature, selector);
    // console.log(body);

    const attempts = Math.max(1, retries);
    let lastError: any;

    for (let attempt = 1; attempt <= attempts; attempt++) {
        const ctrl = new AbortController();
        const timer = setTimeout(() => ctrl.abort(), timeoutMs);

        try {
            const res = await fetch(nodeURL, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(body),
                signal: ctrl.signal
            });

            let json: any = null;
            try {
                json = await res.json();
            } catch (parseErr) {
                // Non-JSON or empty response
                if (isRetryable(parseErr, res.status)) {
                    throw new RetryableError(`Non-JSON response (status ${res.status})`);
                }
                throw new Error(`Failed to parse JSON (status ${res.status})`);
            } finally {
                clearTimeout(timer);
            }

            if (!res.ok) {
                if (isRetryable(null, res.status, json)) {
                    throw new RetryableError(`HTTP ${res.status}`);
                }
                throw new Error(`HTTP ${res.status}: ${JSON.stringify(json)}`);
            }

            if (json?.error) {
                if (isRetryable(null, res.status, json)) {
                    throw new RetryableError(`RPC error ${json.error.code}: ${json.error.message}`);
                }
                throw new Error(`RPC error ${json.error.code}: ${json.error.message}`);
            }

            const hexValue: string | undefined = json?.result;
            // Treat "0x" (empty) as no result
            if (!hexValue || hexValue.toLowerCase() === "0x") {
                throw new Error(`No result for ${signature} on ${contract}`);
            }

            // console.log(json);
            return hexValue;

        } catch (err: any) {
            clearTimeout(timer);
            lastError = err;

            const retryable = err instanceof RetryableError || isRetryable(err);
            if (!retryable || attempt === attempts) {
                // Bubble up final error or non-retryable error
                throw err;
            }

            // Exponential backoff with jitter
            const backoffMs = Math.floor(baseDelayMs * Math.pow(2, attempt - 1));
            const jitter = Math.floor(backoffMs * (0.7 + Math.random() * 0.6)); // 70%–130%
            const delay = Math.min(30_000, jitter); // cap individual delay
            console.warn(
                `callContract retry ${attempt}/${attempts} for ${signature} on ${contract} after ${delay}ms: ${err?.message || err}`
            );
            await sleep(delay);
            continue;
        }
    }

    // Shouldn’t reach here, but just in case:
    throw lastError ?? new Error(`Unknown error calling ${signature} on ${contract}`);
}

for (const contract of contracts) {
    const filename = `trc20-metadata/${contract}.json`;
    if (fs.existsSync(filename)) {
        // console.log(`Skipping ${contract}, file already exists`);
        continue;
    } else {
        console.log(`Processing ${contract}...`);
    }

    const data: { decimals?: number | null; symbol?: string | null; name?: string | null, contract: string, name_str?: string, symbol_str?: string } = {
        decimals: null,
        symbol: null,
        name: null,
        contract,
    };
    try {
        // // Fetch decimals
        const decimalsHex = await callContract(contract, "decimals()"); // 313ce567
        if (decimalsHex) {
            const decimals = parseInt(decimalsHex, 16);
            if (decimals > 18 || decimals < 0) throw new Error(`Invalid decimals: ${decimals}`);
            else data.decimals = decimals;
        }

        // Fetch symbol
        data.symbol = await callContract(contract, "symbol()"); // 95d89b41
        data.name = await callContract(contract, "name()"); // 06fdde03
        if (data.decimals !== null) {
            data.name_str = parse_string(data.name);
            data.symbol_str = parse_string(data.symbol);
            fs.writeFileSync(filename, JSON.stringify(data, null, 2));
            console.log(`  -> ${data.name_str} (${data.symbol_str}), decimals: ${data.decimals}`);
        }

    } catch (err) {
        // console.error("Error:", err);
    }
}


function parse_string(str) {
    const data = hextoString(str)
        .replace(/[\u0000-\u001F0-9]/g, '') // removes control chars and digits
        .replace(/\\"/g, '')
        .trim();
    if (data.length === 0) return undefined;
    return data;
}