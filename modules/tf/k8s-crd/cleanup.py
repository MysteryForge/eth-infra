#!/usr/bin/env python3

import sys
import json
from typing import Dict, Any

def read_stdin() -> str:
    return sys.stdin.read()

def remove_path(data: Dict[str, Any], path: str) -> Dict[str, Any]:
    selected_key, *other_path = path.split('.')

    result = {}
    for key, value in data.items():
        if key == selected_key:
            if other_path:
                result[key] = remove_path(value, '.'.join(other_path))
        else:
            result[key] = value

    return result

invalid_paths = ["status", "metadata.creationTimestamp"]

def main():
    try:
        # Read and parse input
        input_data = json.loads(read_stdin())
        crd = json.loads(input_data['data'])

        # Remove invalid paths
        result = crd
        for path in invalid_paths:
            result = remove_path(result, path)

        # Output result
        print(json.dumps({
            'data': json.dumps(result)  # Changed from json.stringify to json.dumps
        }))

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()