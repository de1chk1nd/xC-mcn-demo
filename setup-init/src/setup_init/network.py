"""Network utilities for the setup process."""

import sys
from typing import Optional

import requests


PUBLIC_IP_SERVICES = [
    "https://api.ipify.org",
    "https://ifconfig.me/ip",
    "https://icanhazip.com",
]

REQUEST_TIMEOUT = 10  # seconds


def get_public_ip() -> str:
    """
    Fetch the operator's public IP address.

    Tries multiple services for redundancy. Returns the IP as a string
    (without CIDR suffix).

    Raises:
        RuntimeError: If all services fail
    """
    errors = []

    for url in PUBLIC_IP_SERVICES:
        try:
            response = requests.get(url, timeout=REQUEST_TIMEOUT)
            response.raise_for_status()
            ip = response.text.strip()
            # Basic validation
            if ip and "." in ip:
                return ip
        except requests.RequestException as e:
            errors.append(f"{url}: {e}")
            continue

    raise RuntimeError(
        f"Failed to detect public IP. Tried: {', '.join(PUBLIC_IP_SERVICES)}\n"
        f"Errors: {'; '.join(errors)}"
    )


def get_public_ip_cidr() -> str:
    """
    Fetch the operator's public IP with /32 CIDR suffix.

    Returns the IP in the format "x.x.x.x/32" for use in security groups.
    """
    ip = get_public_ip()
    return f"{ip}/32"
