#!/usr/bin/env python3
"""Generate JWT tokens and JWKS for the JWT validation use case.

Creates:
  - A valid JWT (correct issuer + audience claims)
  - An invalid JWT (wrong issuer claim)
  - A JWKS (JSON Web Key Set) containing the CA public key

All tokens are signed with RS256 using the lab CA private key.
The JWKS contains the corresponding public key for xC to validate.
"""

import json
import sys
import base64
import hashlib
import time
from pathlib import Path

try:
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric.rsa import RSAPublicNumbers
    import jwt
except ImportError:
    print("ERROR: Required packages not installed.")
    print("  pip install PyJWT cryptography")
    sys.exit(1)


def load_private_key(key_path: str):
    """Load RSA private key from PEM file."""
    with open(key_path, "rb") as f:
        return serialization.load_pem_private_key(f.read(), password=None)


def generate_jwks(private_key) -> dict:
    """Generate a JWKS from the RSA private key's public component."""
    public_key = private_key.public_key()
    public_numbers = public_key.public_numbers()

    # Base64url encode the modulus and exponent
    def b64url(num: int, length: int) -> str:
        return base64.urlsafe_b64encode(
            num.to_bytes(length, byteorder="big")
        ).decode("utf-8").rstrip("=")

    n_bytes = (public_numbers.n.bit_length() + 7) // 8

    # Key ID from SHA-256 thumbprint
    kid = hashlib.sha256(
        json.dumps({
            "e": b64url(public_numbers.e, 3),
            "kty": "RSA",
            "n": b64url(public_numbers.n, n_bytes),
        }, sort_keys=True, separators=(",", ":")).encode()
    ).hexdigest()[:16]

    return {
        "keys": [
            {
                "kty": "RSA",
                "alg": "RS256",
                "use": "sig",
                "kid": kid,
                "n": b64url(public_numbers.n, n_bytes),
                "e": b64url(public_numbers.e, 3),
            }
        ]
    }


def generate_token(private_key, kid: str, issuer: str, audience: str, subject: str, exp_hours: int = 8760) -> str:
    """Generate a signed JWT token."""
    now = int(time.time())
    payload = {
        "iss": issuer,
        "aud": audience,
        "sub": subject,
        "iat": now,
        "exp": now + (exp_hours * 3600),
    }
    headers = {
        "kid": kid,
        "alg": "RS256",
    }
    return jwt.encode(payload, private_key, algorithm="RS256", headers=headers)


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <ca-key-path> <student-name> <output-dir>")
        sys.exit(1)

    ca_key_path = sys.argv[1]
    student = sys.argv[2]
    output_dir = Path(sys.argv[3])
    output_dir.mkdir(parents=True, exist_ok=True)

    # Load CA private key
    private_key = load_private_key(ca_key_path)
    print(f"Loaded CA private key from: {ca_key_path}")

    # Generate JWKS
    jwks = generate_jwks(private_key)
    kid = jwks["keys"][0]["kid"]
    jwks_path = output_dir / "jwks.json"
    with open(jwks_path, "w") as f:
        json.dump(jwks, f, indent=2)
    print(f"JWKS written to: {jwks_path}")

    # Valid issuer/audience
    valid_issuer = f"https://lab.{student}.xc-mcn-lab.aws"
    valid_audience = f"https://jwt.{student}.xc-mcn-lab.aws"

    # Token 1: Valid (correct issuer + audience)
    valid_token = generate_token(
        private_key, kid,
        issuer=valid_issuer,
        audience=valid_audience,
        subject=f"{student}@xc-mcn-lab",
    )
    token_path = output_dir / "valid.jwt"
    with open(token_path, "w") as f:
        f.write(valid_token)
    print(f"Valid token written to: {token_path}")

    # Token 2: Invalid (wrong issuer)
    invalid_token = generate_token(
        private_key, kid,
        issuer="https://evil.attacker.com",
        audience=valid_audience,
        subject="attacker@evil.com",
    )
    token_path = output_dir / "invalid.jwt"
    with open(token_path, "w") as f:
        f.write(invalid_token)
    print(f"Invalid token written to: {token_path}")

    print(f"\nIssuer:   {valid_issuer}")
    print(f"Audience: {valid_audience}")


if __name__ == "__main__":
    main()
