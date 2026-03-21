// =============================================================================
// K6 LOAD TEST SCRIPT — Podinfo Traffic Simulation
// =============================================================================
//
// Generates ~10 RPS of consistent HTTP traffic against Podinfo.
// Weighted distribution across endpoints to simulate realistic patterns:
//   70%  GET /           → main endpoint
//   15%  GET /healthz    → health check
//   10%  GET /status/200 → normal status
//    5%  GET /delay/1    → simulated latency (1 second)
//
// =============================================================================

import http from "k6/http";
import { check, sleep } from "k6";

// ---------------------------------------------------------------------------
// Configuration (injected via environment variables from CronJob)
// ---------------------------------------------------------------------------
const BASE_URL = __ENV.K6_TARGET_URL || "http://podinfo-lab.lab:9898";

export const options = {
    vus: parseInt(__ENV.K6_VUS || "10"),
    duration: __ENV.K6_DURATION || "5m",

    thresholds: {
        http_req_duration: ["p(95)<500"],  // 95% of requests must complete within 500ms
        http_req_failed: ["rate<0.05"],    // Error rate must be below 5%
    },
};

// ---------------------------------------------------------------------------
// Weighted endpoint selection
// ---------------------------------------------------------------------------
const endpoints = [
    { path: "/", weight: 70 },
    { path: "/healthz", weight: 15 },
    { path: "/status/200", weight: 10 },
    { path: "/delay/1", weight: 5 },
];

// Build cumulative weight array for fast lookup
const cumulativeWeights = [];
let totalWeight = 0;
for (const ep of endpoints) {
    totalWeight += ep.weight;
    cumulativeWeights.push({ path: ep.path, cumWeight: totalWeight });
}

function pickEndpoint() {
    const rand = Math.random() * totalWeight;
    for (const item of cumulativeWeights) {
        if (rand < item.cumWeight) {
            return item.path;
        }
    }
    return endpoints[0].path;
}

// ---------------------------------------------------------------------------
// Main test function — each VU runs this in a loop
// ---------------------------------------------------------------------------
export default function () {
    const path = pickEndpoint();
    const url = `${BASE_URL}${path}`;

    const res = http.get(url);

    check(res, {
        "status is 2xx": (r) => r.status >= 200 && r.status < 300,
    });

    // ~1 request per second per VU → 10 VUs = ~10 RPS
    sleep(1);
}
