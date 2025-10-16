#!/usr/bin/env python3
"""
enumerate-entry-points.py - Extract Android entry points from manifest and code.

Usage: python3 enumerate-entry-points.py <apktool-output-dir>
Example: python3 enumerate-entry-points.py ../decode/apktool/
"""

import os
import re
import sys
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, List

class EntryPointEnumerator:
    def __init__(self, apktool_dir: str):
        self.apktool_dir = Path(apktool_dir)
        self.manifest_path = self.apktool_dir / "AndroidManifest.xml"
        
        if not self.manifest_path.exists():
            raise ValueError(f"AndroidManifest.xml not found")
        
        self.entry_points = {
            "activities": [],
            "services": [],
            "receivers": [],
            "providers": [],
            "permissions": [],
            "exported_components": []
        }
    
    def analyze(self) -> Dict:
        """Extract all entry points."""
        print("[*] Parsing AndroidManifest.xml...")
        
        tree = ET.parse(self.manifest_path)
        root = tree.getroot()
        ns = {'android': 'http://schemas.android.com/apk/res/android'}
        
        # Extract package
        self.entry_points["package"] = root.get('package')
        
        # Extract permissions
        for permission in root.findall('uses-permission'):
            perm_name = permission.get('{http://schemas.android.com/apk/res/android}name')
            if perm_name:
                self.entry_points["permissions"].append(perm_name)
        
        # Extract application components
        app = root.find('application')
        if app:
            for activity in app.findall('activity'):
                self._extract_component(activity, 'activity')
            
            for service in app.findall('service'):
                self._extract_component(service, 'service')
            
            for receiver in app.findall('receiver'):
                self._extract_component(receiver, 'receiver')
            
            for provider in app.findall('provider'):
                self._extract_component(provider, 'provider')
        
        return self.entry_points
    
    def _extract_component(self, element, comp_type: str):
        """Extract component from XML."""
        name = element.get('{http://schemas.android.com/apk/res/android}name')
        exported = element.get('{http://schemas.android.com/apk/res/android}exported')
        
        component = {
            "name": name,
            "type": comp_type,
            "exported": exported == "true"
        }
        
        if comp_type == 'activity':
            self.entry_points["activities"].append(component)
        elif comp_type == 'service':
            self.entry_points["services"].append(component)
        elif comp_type == 'receiver':
            self.entry_points["receivers"].append(component)
        elif comp_type == 'provider':
            self.entry_points["providers"].append(component)
        
        if component["exported"]:
            self.entry_points["exported_components"].append(component)


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 enumerate-entry-points.py <apktool-output-dir>")
        sys.exit(1)
    
    apktool_dir = sys.argv[1]
    
    if not os.path.isdir(apktool_dir):
        print(f"Error: Directory not found: {apktool_dir}")
        sys.exit(1)
    
    print(f"[*] Analyzing: {apktool_dir}")
    
    enumerator = EntryPointEnumerator(apktool_dir)
    entry_points = enumerator.analyze()
    
    # Save JSON
    output_file = Path(apktool_dir).parent.parent / "artifacts" / "entry-points.json"
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w') as f:
        json.dump(entry_points, f, indent=2)
    
    print(f"[*] Data saved to: {output_file}")
    print()
    
    print("Summary:")
    print(f"  Package:     {entry_points.get('package', 'Unknown')}")
    print(f"  Activities:  {len(entry_points.get('activities', []))}")
    print(f"  Services:    {len(entry_points.get('services', []))}")
    print(f"  Receivers:   {len(entry_points.get('receivers', []))}")
    print(f"  Providers:   {len(entry_points.get('providers', []))}")
    print(f"  Permissions: {len(entry_points.get('permissions', []))}")
    print(f"  Exported:    {len(entry_points.get('exported_components', []))}")


if __name__ == "__main__":
    main()
