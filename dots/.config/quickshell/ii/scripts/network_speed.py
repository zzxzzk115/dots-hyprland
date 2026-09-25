#!/usr/bin/env python3
"""Report physical network throughput without counting VPN traffic twice."""
import json
import time
from pathlib import Path


def counters(root=Path('/sys/class/net')):
    result = {}
    for interface in root.iterdir():
        if not (interface / 'device').exists():
            continue
        try:
            if (interface / 'operstate').read_text().strip() != 'up':
                continue
            stats = interface / 'statistics'
            result[interface.name] = (
                int((stats / 'rx_bytes').read_text()),
                int((stats / 'tx_bytes').read_text()),
            )
        except (OSError, ValueError):
            continue
    return result


def rates(previous, current, elapsed):
    if elapsed <= 0:
        return (0.0, 0.0)
    received = sent = 0
    for name, (rx, tx) in current.items():
        if name not in previous:
            continue
        old_rx, old_tx = previous[name]
        received += max(0, rx - old_rx)
        sent += max(0, tx - old_tx)
    return received / elapsed, sent / elapsed


def main():
    previous = {}
    last_time = time.monotonic()
    while True:
        current = counters()
        now = time.monotonic()
        down, up = rates(previous, current, now - last_time)
        print(json.dumps({'download': down, 'upload': up,
                          'interfaces': sorted(current)}), flush=True)
        previous, last_time = current, now
        time.sleep(2)


if __name__ == '__main__':
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        pass
