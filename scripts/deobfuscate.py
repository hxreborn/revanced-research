#!/usr/bin/env python3
"""
Intelligent deobfuscation script for TikTok APK
Uses heuristics to rename obfuscated classes based on:
- String constants and API calls
- Method patterns
- Class hierarchy
- Android framework patterns
"""

import os
import re
from pathlib import Path
from collections import defaultdict
import json

class Deobfuscator:
    def __init__(self, source_dir):
        self.source_dir = Path(source_dir)
        self.patterns = {}
        self.renames = {}

    def analyze_class(self, file_path):
        """Analyze a single Java file for naming hints"""
        with open(file_path, 'r', errors='ignore') as f:
            content = f.read()

        hints = {
            'strings': set(),
            'methods': set(),
            'interfaces': set(),
            'extends': None,
            'implements': [],
        }

        # Extract class name
        class_match = re.search(r'(?:public\s+)?(?:final\s+)?class\s+(\w+)', content)
        if not class_match:
            return None

        class_name = class_match.group(1)

        # Extract extends
        extends_match = re.search(r'class\s+\w+\s+extends\s+(\w+)', content)
        if extends_match:
            hints['extends'] = extends_match.group(1)

        # Extract implements
        implements_match = re.search(r'class\s+\w+\s+implements\s+([\w\s,]+)', content)
        if implements_match:
            hints['implements'] = [x.strip() for x in implements_match.group(1).split(',')]

        # Check if it's an interface
        if re.search(r'(?:public\s+)?interface\s+', content):
            hints['is_interface'] = True

        # Extract string literals
        strings = re.findall(r'"([^"]{5,})"', content)
        hints['strings'] = set(strings[:10])  # First 10 strings

        # Extract method names
        methods = re.findall(r'(?:public|private|protected)\s+\w+\s+(\w+)\s*\(', content)
        hints['methods'] = set(methods[:5])

        # Extract API calls
        api_calls = re.findall(r'\.(\w+)\s*\(', content)
        hints['api_calls'] = set(api_calls[:10])

        return class_name, hints

    def guess_class_purpose(self, hints):
        """Try to guess what a class does based on hints"""
        strings = hints.get('strings', set())
        methods = hints.get('methods', set())
        api_calls = hints.get('api_calls', set())

        # Look for service indicators
        if any(x in api_calls for x in ['startService', 'bindService', 'startForeground']):
            return 'Service'

        # Look for activity indicators
        if 'onCreate' in methods or 'onDestroy' in methods:
            return 'Activity'

        # Look for adapter indicators
        if 'getItemCount' in methods or 'onBindViewHolder' in methods:
            return 'Adapter'

        # Look for API/networking
        if any(x in strings for x in ['http', 'api', 'json', 'url']):
            return 'API'

        # Look for database
        if any(x in api_calls for x in ['query', 'insert', 'update', 'delete']):
            return 'Database'

        # Look for listener/callback patterns
        if hints.get('is_interface') or 'Listener' in hints.get('implements', []):
            return 'Listener'

        return None

    def scan_directory(self):
        """Scan all Java files and build a rename map"""
        java_files = list(self.source_dir.rglob('*.java'))
        print(f"[*] Found {len(java_files)} Java files")

        analysis = {}
        for i, java_file in enumerate(java_files):
            if i % 10000 == 0:
                print(f"[*] Analyzed {i}/{len(java_files)} files...")

            result = self.analyze_class(java_file)
            if result:
                class_name, hints = result
                purpose = self.guess_class_purpose(hints)
                analysis[class_name] = {
                    'file': str(java_file.relative_to(self.source_dir)),
                    'purpose': purpose,
                    'hints': {k: list(v) if isinstance(v, set) else v
                             for k, v in hints.items()},
                }

        return analysis

    def print_report(self, analysis):
        """Generate a report of guessed class purposes"""
        print("\n" + "="*60)
        print("DEOBFUSCATION ANALYSIS REPORT")
        print("="*60)

        by_purpose = defaultdict(list)
        for class_name, info in analysis.items():
            purpose = info.get('purpose') or 'Unknown'
            by_purpose[purpose].append(class_name)

        for purpose in sorted(by_purpose.keys()):
            classes = by_purpose[purpose]
            print(f"\n[{purpose}] {len(classes)} classes:")
            for cls in sorted(classes)[:10]:  # Show first 10
                print(f"  - {cls}")
            if len(classes) > 10:
                print(f"  ... and {len(classes)-10} more")

if __name__ == '__main__':
    source_dir = '../apps/tiktok/36.5.4/decode/jadx/sources'

    if not os.path.exists(source_dir):
        print(f"Error: {source_dir} not found")
        exit(1)

    deobf = Deobfuscator(source_dir)
    analysis = deobf.scan_directory()

    # Save analysis
    output_file = '../apps/tiktok/36.5.4/analysis/deobfuscation_report.json'
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w') as f:
        json.dump(analysis, f, indent=2)

    print(f"\n[+] Analysis saved to {output_file}")

    # Print summary
    deobf.print_report(analysis)

    # Statistics
    print("\n" + "="*60)
    print("STATISTICS")
    print("="*60)
    total = len(analysis)
    identified = sum(1 for v in analysis.values() if v.get('purpose'))
    print(f"Total classes: {total}")
    print(f"Identified purpose: {identified} ({100*identified//total}%)")
