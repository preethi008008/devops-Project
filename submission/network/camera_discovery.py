#!/usr/bin/env python3
"""
camera_discovery.py — ONVIF Camera Discovery Tool
"""

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from urllib.parse import urlparse


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="ONVIF camera discovery parser")
    parser.add_argument(
        "--input",
        type=str,
        help="Path to ONVIF XML file (default: stdin)",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=3,
        help="Discovery timeout in seconds",
    )
    return parser.parse_args()


def parse_onvif_response(xml_content):
    """Parse ONVIF WS-Discovery XML and return list of camera dicts."""
    cameras = []

    namespaces = {
        "soap": "http://www.w3.org/2003/05/soap-envelope",
        "wsd": "http://schemas.xmlsoap.org/ws/2005/04/discovery",
        "wsa": "http://schemas.xmlsoap.org/ws/2004/08/addressing",
        "dn": "http://www.onvif.org/ver10/network/wsdl",
        "tds": "http://www.onvif.org/ver10/device/wsdl",
    }

    try:
        root = ET.fromstring(xml_content)
    except ET.ParseError:
        print("Invalid XML input", file=sys.stderr)
        return cameras

    for probe_match in root.findall(".//wsd:ProbeMatch", namespaces):
        camera = {
            "uuid": None,
            "model": None,
            "name": None,
            "location": None,
            "service_url": None,
            "ip": None,
        }

        # UUID
        addr = probe_match.find(".//wsa:Address", namespaces)
        if addr is not None and addr.text:
            camera["uuid"] = addr.text.split(":")[-1]

        # Service URL
        xaddr = probe_match.find(".//wsd:XAddrs", namespaces)
        if xaddr is not None and xaddr.text:
            url = xaddr.text.strip()
            camera["service_url"] = url
            parsed = urlparse(url)
            camera["ip"] = parsed.hostname

        # Optional fields
        scopes = probe_match.find(".//wsd:Scopes", namespaces)
        if scopes is not None and scopes.text:
            scope_text = scopes.text.lower()

            # Example parsing from scope metadata
            if "name" in scope_text:
                camera["name"] = scopes.text.split("/")[-1]

            if "location" in scope_text:
                camera["location"] = scopes.text.split("/")[-1]

        # Model may be embedded in types or scopes
        types = probe_match.find(".//wsd:Types", namespaces)
        if types is not None and types.text:
            camera["model"] = types.text.split(":")[-1]

        cameras.append(camera)

    return cameras


def main():
    args = parse_args()

    try:
        if args.input:
            with open(args.input, "r", encoding="utf-8") as f:
                xml_content = f.read()
        else:
            xml_content = sys.stdin.read()
    except Exception as e:
        print(f"Error reading input: {e}", file=sys.stderr)
        sys.exit(1)

    cameras = parse_onvif_response(xml_content)

    print(json.dumps(cameras, indent=2))


if __name__ == "__main__":
    main()