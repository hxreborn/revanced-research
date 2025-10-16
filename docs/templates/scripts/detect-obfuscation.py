#!/usr/bin/env python3
"""
detect-obfuscation.py - Analyze APK for obfuscation techniques.

Usage: python3 detect-obfuscation.py <apktool-output-dir>
Example: python3 detect-obfuscation.py ../decode/apktool/
"""

import os
import re
import sys
import json
from pathlib import Path
from collections import Counter
from typing import Dict, List, Set

class ObfuscationDetector:
    def __init__(self, apktool_dir: str):
        self.apktool_dir = Path(apktool_dir)
        self.smali_dirs = list(self.apktool_dir.glob("smali*/"))
        
        if not self.smali_dirs:
            raise ValueError(f"No smali directories found in {apktool_dir}")
        
        self.results = {
            "obfuscation_detected": False,
            "obfuscation_level": "UNKNOWN",
            "characteristics": {},
            "statistics": {}
        }
    
    def analyze(self) -> Dict:
        """Run all detection methods."""
        print("[*] Analyzing obfuscation patterns...")
        
        smali_files = []
        for smali_dir in self.smali_dirs:
            smali_files.extend(list(smali_dir.rglob("*.smali"))[:500])
        
        print(f"[*] Found {len(smali_files)} smali files (sampled)")
        
        self.detect_class_names(smali_files)
        self.detect_method_names(smali_files)
        self.detect_string_encryption(smali_files)
        self.detect_obfuscator_signatures(smali_files)
        
        self.determine_obfuscation_level()
        
        return self.results
    
    def detect_class_names(self, smali_files: List[Path]):
        """Detect class name mangling."""
        print("[*] Analyzing class names...")
        
        short_name_count = 0
        total = 0
        
        for smali_file in smali_files[:100]:
            try:
                with open(smali_file, 'r', encoding='utf-8', errors='ignore') as f:
                    first_line = f.readline()
                    match = re.search(r'\.class\s+.*\s+(L[^;]+);', first_line)
                    if match:
                        class_name = match.group(1)
                        total += 1
                        simple_name = class_name.split('/')[-1]
                        if len(simple_name) <= 3:
                            short_name_count += 1
            except Exception:
                continue
        
        if total > 0:
            ratio = short_name_count / total
            self.results["statistics"]["short_class_ratio"] = ratio
            
            if ratio > 0.3:
                self.results["characteristics"]["class_name_mangling"] = True
                self.results["obfuscation_detected"] = True
            else:
                self.results["characteristics"]["class_name_mangling"] = False
    
    def detect_method_names(self, smali_files: List[Path]):
        """Detect method name mangling."""
        print("[*] Analyzing method names...")
        
        short_method_count = 0
        total = 0
        
        for smali_file in smali_files[:100]:
            try:
                with open(smali_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    methods = re.findall(r'\.method\s+.*\s+(\w+)\(', content)
                    
                    for method in methods:
                        if method not in ['<init>', '<clinit>']:
                            total += 1
                            if len(method) <= 2:
                                short_method_count += 1
            except Exception:
                continue
        
        if total > 0:
            ratio = short_method_count / total
            self.results["statistics"]["short_method_ratio"] = ratio
            
            if ratio > 0.4:
                self.results["characteristics"]["method_name_mangling"] = True
                self.results["obfuscation_detected"] = True
            else:
                self.results["characteristics"]["method_name_mangling"] = False
    
    def detect_string_encryption(self, smali_files: List[Path]):
        """Detect encrypted strings."""
        print("[*] Detecting string encryption...")
        
        encryption_matches = 0
        
        for smali_file in smali_files[:100]:
            try:
                with open(smali_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    if re.search(r'decrypt\(|deobfuscate\(|Base64\.decode', content):
                        encryption_matches += 1
            except Exception:
                continue
        
        if encryption_matches > 5:
            self.results["characteristics"]["string_encryption"] = True
            self.results["obfuscation_detected"] = True
        else:
            self.results["characteristics"]["string_encryption"] = False
    
    def detect_obfuscator_signatures(self, smali_files: List[Path]):
        """Detect known obfuscators."""
        print("[*] Detecting obfuscator signatures...")
        
        signatures = {
            "ProGuard": [r'# This file is automatically generated by ProGuard'],
            "R8": [r'# Compiler: R8', r'\.class.*\$r8\$'],
            "DexGuard": [r'com/guardsquare/dexguard'],
        }
        
        detected = set()
        
        for smali_file in smali_files[:100]:
            try:
                with open(smali_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    for obfuscator, patterns in signatures.items():
                        for pattern in patterns:
                            if re.search(pattern, content, re.IGNORECASE):
                                detected.add(obfuscator)
                                break
            except Exception:
                continue
        
        if detected:
            self.results["obfuscator"] = ", ".join(detected)
    
    def determine_obfuscation_level(self):
        """Determine overall obfuscation level."""
        char = self.results["characteristics"]
        
        score = 0
        if char.get("class_name_mangling"):
            score += 2
        if char.get("method_name_mangling"):
            score += 2
        if char.get("string_encryption"):
            score += 3
        
        if score == 0:
            self.results["obfuscation_level"] = "NONE"
            self.results["obfuscation_detected"] = False
        elif score <= 2:
            self.results["obfuscation_level"] = "LOW"
        elif score <= 5:
            self.results["obfuscation_level"] = "MEDIUM"
        else:
            self.results["obfuscation_level"] = "HIGH"


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 detect-obfuscation.py <apktool-output-dir>")
        sys.exit(1)
    
    apktool_dir = sys.argv[1]
    
    if not os.path.isdir(apktool_dir):
        print(f"Error: Directory not found: {apktool_dir}")
        sys.exit(1)
    
    print(f"[*] Analyzing: {apktool_dir}")
    
    detector = ObfuscationDetector(apktool_dir)
    results = detector.analyze()
    
    print()
    print("=" * 60)
    print("OBFUSCATION ANALYSIS")
    print("=" * 60)
    print()
    
    print(f"Obfuscation Detected: {results['obfuscation_detected']}")
    print(f"Obfuscation Level:    {results['obfuscation_level']}")
    print()
    
    print("Characteristics:")
    for char, present in results["characteristics"].items():
        status = "YES" if present else "NO"
        print(f"  {char:30} {status}")
    print()
    
    # Save JSON
    output_file = Path(apktool_dir).parent.parent / "artifacts" / "obfuscation-report.json"
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"[*] Full report saved to: {output_file}")


if __name__ == "__main__":
    main()
