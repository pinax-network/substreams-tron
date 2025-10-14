import contracts from './contracts.json' assert { type: 'json' };
import { TronWeb } from "tronweb"
import { keccak256, toUtf8Bytes } from "ethers";  // ethers v6+
import { hextoString, sleep } from 'tronweb/utils';
import fs from 'fs';

const nodeURL = `https://lb.drpc.live/tron/${process.env.DRPC_API_KEY}`;

async function callContract(contract, signature, retry = 3) {
    // const signature = "decimals()";
    const hash = keccak256(toUtf8Bytes(signature));
    const selector = "0x" + hash.slice(2, 10);

    // Request body
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
    console.log(signature, selector)
    console.log(body)

    const res = await fetch(nodeURL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });


    console.log(res)
    const json = await res.json();
    console.log(json)
    const hexValue = json?.result;

    await sleep(500);

    if (!hexValue) throw new Error(`No result for ${signature} on ${contract}`);
    return hexValue;
}

function hexToUtf8(hex) {
    const bytes = hex.match(/.{1,2}/g).map(byte => parseInt(byte, 16));
    return new TextDecoder().decode(Uint8Array.from(bytes)).replace(/\0/g, "");
}

for (const contract of contracts) {
    const filename = `trc20-metadata/${contract}.json`;
    if (fs.existsSync(filename)) {
        console.log(`Skipping ${contract}, file already exists`);
        continue;
    }

    const data: { decimals?: number | null; symbol?: string | null; name?: string | null } = {
        decimals: null,
        symbol: null,
        name: null
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
        const symbolHex = await callContract(contract, "symbol()"); // 95d89b41
        if (symbolHex) {
            const symbol = hexToUtf8(symbolHex).trim();
            if (symbol.length > 32) throw new Error(`Invalid symbol: ${symbol}`);
            else data.symbol = parse_string(symbol);
        }

        // // Fetch name
        const nameHex = await callContract(contract, "name()"); // 06fdde03
        if (nameHex) {
            const name = hexToUtf8(nameHex).trim();
            if (name.length > 64) throw new Error(`Invalid name: ${name}`);
            else data.name = parse_string(name);
        }
        console.log(contract, data);
        if (data.decimals !== null || data.symbol !== null || data.name !== null) {
            fs.writeFileSync(filename, JSON.stringify(data, null, 2));
        }

    } catch (err) {
        console.error("Error:", err);
    }
}


function parse_string(str) {
    const data = hextoString(str).replace(/\u0000/g, '').replace(/\u0001/g, '').replace(/\u0002/g, '').replace(/\u0003/g, '').replace(/\u0005/g, '').replace(/\u0006/g, '').replace(/\u0007/g, '').replace(/\u0008/g, '').replace(/\u000e/g, '').replace(/\u000f/g, '').trim();
    if (data.length === 0) return undefined;
    return data;
}