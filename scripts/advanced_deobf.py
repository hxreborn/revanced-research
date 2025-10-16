#!/usr/bin/env python3
"""
Advanced deobfuscation analyzer for TikTok
Uses multiple heuristics to improve class naming:
1. Network/API patterns
2. Crypto/Security patterns
3. UI/View patterns
4. Storage patterns
5. Media handling patterns
"""

import os
import re
from pathlib import Path
from collections import defaultdict
import json

class AdvancedDeobfuscator:
    def __init__(self, source_dir):
        self.source_dir = Path(source_dir)

        # Pattern definitions
        self.patterns = {
            'API': [
                r'\.get\(', r'\.post\(', r'\.put\(', r'\.delete\(',
                r'HttpClient', r'OkHttp', r'Retrofit',
                r'request\(', r'response\(', r'endpoint', r'api',
                r'baseUrl', r'Authorization', r'Content-Type',
            ],
            'Crypto': [
                r'MessageDigest', r'Cipher', r'encrypt', r'decrypt',
                r'RSA', r'AES', r'MD5', r'SHA', r'SecretKey',
                r'PublicKey', r'PrivateKey', r'Signature',
            ],
            'Database': [
                r'ContentProvider', r'SQLite', r'Room', r'Realm',
                r'query\(', r'insert\(', r'update\(', r'delete\(',
                r'cursor\(', r'transaction', r'database',
            ],
            'Storage': [
                r'SharedPreferences', r'File', r'FileInputStream',
                r'FileOutputStream', r'Storage', r'cache',
                r'serialize', r'deserialize',
            ],
            'Media': [
                r'MediaPlayer', r'MediaRecorder', r'Camera',
                r'Bitmap', r'Drawable', r'ImageView',
                r'Video', r'Audio', r'Image', r'Encode',
            ],
            'Analytics': [
                r'Analytics', r'Tracker', r'Event', r'Track',
                r'Firebase', r'Mixpanel', r'log\(', r'report',
            ],
            'Network': [
                r'Socket', r'DatagramSocket', r'ServerSocket',
                r'URL', r'URLConnection', r'NetworkInterface',
            ],
            'UI': [
                r'Activity', r'Fragment', r'View', r'Dialog',
                r'RecyclerView', r'ListView', r'Layout', r'Widget',
                r'inflate', r'setContentView', r'findViewById',
            ],
            'Thread': [
                r'Thread', r'Runnable', r'Handler', r'Looper',
                r'ExecutorService', r'ThreadPool', r'async',
            ],
            'Permission': [
                r'Permission', r'CheckPermission', r'RequestPermission',
                r'PermissionManager', r'PermissionChecker',
            ],
        }

    def extract_api_pattern(self, content):
        """Extract all API-related patterns from file"""
        found_patterns = defaultdict(int)

        for category, patterns in self.patterns.items():
            for pattern in patterns:
                matches = len(re.findall(pattern, content, re.IGNORECASE))
                if matches > 0:
                    found_patterns[category] += matches

        return found_patterns

    def classify_class(self, content, found_patterns):
        """Classify based on patterns found"""
        if not found_patterns:
            return None

        # Get the category with highest score
        best_category = max(found_patterns.items(), key=lambda x: x[1])
        score = best_category[1]

        # Only classify if score is significant
        if score >= 2:
            return best_category[0]

        return None

    def analyze_file(self, file_path):
        """Analyze a single Java file"""
        try:
            with open(file_path, 'r', errors='ignore') as f:
                content = f.read()
        except:
            return None

        # Extract class name
        class_match = re.search(r'(?:public\s+)?(?:final\s+)?(?:abstract\s+)?class\s+(\w+)', content)
        if not class_match:
            return None

        class_name = class_match.group(1)

        # Get patterns
        patterns = self.extract_api_pattern(content)
        category = self.classify_class(content, patterns)

        # Extract some strings for manual analysis
        strings = re.findall(r'"([^"]{10,})"', content)

        return {
            'class_name': class_name,
            'category': category,
            'pattern_score': dict(patterns),
            'file': str(file_path.relative_to(self.source_dir)),
            'sample_strings': strings[:3],
        }

    def scan_all(self):
        """Scan all Java files"""
        java_files = list(self.source_dir.rglob('*.java'))
        print(f"[*] Scanning {len(java_files)} files...")

        results = []
        for i, java_file in enumerate(java_files):
            if i % 50000 == 0 and i > 0:
                print(f"[*] Processed {i}/{len(java_files)}...")

            result = self.analyze_file(java_file)
            if result and result['category']:
                results.append(result)

        return results

    def generate_report(self, results):
        """Generate categorized report"""
        by_category = defaultdict(list)

        for result in results:
            category = result['category']
            by_category[category].append(result['class_name'])

        print("\n" + "="*70)
        print("ADVANCED DEOBFUSCATION REPORT - API/FUNCTIONALITY CLASSIFICATION")
        print("="*70)

        for category in sorted(by_category.keys()):
            classes = sorted(set(by_category[category]))
            print(f"\n[{category.upper()}] {len(classes)} classes identified:")
            for cls in classes[:15]:
                print(f"  - {cls}")
            if len(classes) > 15:
                print(f"  ... and {len(classes)-15} more")

        print("\n" + "="*70)
        print(f"TOTAL CLASSIFIED: {len(results)} / {len(list(self.source_dir.rglob('*.java')))}")
        print("="*70)

if __name__ == '__main__':
    source_dir = '../apps/tiktok/36.5.4/decode/jadx/sources'

    if not os.path.exists(source_dir):
        print(f"Error: {source_dir} not found")
        exit(1)

    analyzer = AdvancedDeobfuscator(source_dir)
    results = analyzer.scan_all()

    # Generate report
    analyzer.generate_report(results)

    # Save detailed results
    output_file = '../apps/tiktok/36.5.4/analysis/api_classification.json'
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"\n[+] Detailed report saved to {output_file}")
