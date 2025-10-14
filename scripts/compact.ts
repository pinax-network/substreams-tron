import transfers from './trc20_transfer.json' assert { type: 'json' };

const contracts = [];

for (const row of transfers.data) {
    if (row["count()"] < 1000) continue;
    contracts.push(row.log_address);
}

Bun.write("contracts.json", JSON.stringify([...new Set(contracts)], null, 2));