#!/bin/bash
set -e

cd /home/rafa/Documents/GitHub/revanced-research/apps/tiktok/36.5.4

# ===== STEP 1: JVM Descriptor Verification =====
echo "=== STEP 1: JVM Descriptor Verification ==="

# JADX: UEU.LIZJ method signature
echo "JADX - UEU.LIZJ method:" > verification/01-jvm-descriptors.txt
grep -n "public static final String LIZJ" decompiled-jadx/sources/p003X/UEU.java >> verification/01-jvm-descriptors.txt 2>&1 || echo "Not found in JADX"

echo -e "\n" >> verification/01-jvm-descriptors.txt

# Smali: UEU.LIZJ method descriptor
echo "JADX - AbstractC82063UGk.m11879LJ method:" >> verification/01-jvm-descriptors.txt
grep -n "public static String m11879LJ" decompiled-jadx/sources/p003X/AbstractC82063UGk.java >> verification/01-jvm-descriptors.txt 2>&1 || echo "Not found in JADX"

echo -e "\n" >> verification/01-jvm-descriptors.txt

# Smali: Find method signatures
echo "Smali - UEU.LIZJ descriptor:" >> verification/01-jvm-descriptors.txt
grep -n "\.method.*LIZJ" decompiled-smali-full/smali_classes15/X/UEU.smali | head -5 >> verification/01-jvm-descriptors.txt 2>&1 || echo "Not found in Smali"

echo -e "\n" >> verification/01-jvm-descriptors.txt

echo "Smali - UGk.m11879LJ descriptor:" >> verification/01-jvm-descriptors.txt
grep -n "\.method.*m11879LJ" decompiled-smali-full/smali_classes15/X/UGk.smali | head -5 >> verification/01-jvm-descriptors.txt 2>&1 || echo "Not found in Smali"

# ===== STEP 2: Smali Shard Path Mapping =====
echo -e "\n=== STEP 2: Smali Shard Path Mapping ===" >> verification/01-jvm-descriptors.txt

echo "Finding UEU.smali location:" >> verification/01-jvm-descriptors.txt
find decompiled-smali-full -name "UEU.smali" >> verification/01-jvm-descriptors.txt 2>&1

echo "Finding UGk.smali location:" >> verification/01-jvm-descriptors.txt
find decompiled-smali-full -name "UGk.smali" >> verification/01-jvm-descriptors.txt 2>&1

echo "Finding WrapDefaultWhatsappChannel location:" >> verification/01-jvm-descriptors.txt
find decompiled-smali-full -name "WrapDefaultWhatsappChannel.smali" >> verification/01-jvm-descriptors.txt 2>&1

echo "✓ Step 1-2 complete"

