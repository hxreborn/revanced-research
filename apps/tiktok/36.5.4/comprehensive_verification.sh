#!/bin/bash
set +e  # Don't exit on errors, just continue

cd /home/rafa/Documents/GitHub/revanced-research/apps/tiktok/36.5.4

echo "Starting comprehensive verification..."

# ===== STEP 3: Share Plumbing =====
echo "=== STEP 3: Share Plumbing Verification ===" > verification/02-share-plumbing.txt

echo "ACTION_SEND - JADX:" >> verification/02-share-plumbing.txt
rg "ACTION_SEND|android\.intent\.action\.SEND" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/02-share-plumbing.txt
rg "ACTION_SEND|android\.intent\.action\.SEND" decompiled-jadx/sources/ | head -20 >> verification/02-share-plumbing.txt

echo -e "\nACTION_SEND - Smali:" >> verification/02-share-plumbing.txt
rg "android\.intent\.action\.SEND" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/02-share-plumbing.txt
rg "android\.intent\.action\.SEND" decompiled-smali-full/smali_*/ | head -20 >> verification/02-share-plumbing.txt

echo -e "\nEXTRA_TEXT - JADX:" >> verification/02-share-plumbing.txt
rg "EXTRA_TEXT|android\.intent\.extra\.TEXT" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/02-share-plumbing.txt
rg "EXTRA_TEXT|android\.intent\.extra\.TEXT" decompiled-jadx/sources/ | head -20 >> verification/02-share-plumbing.txt

echo -e "\nEXTRA_TEXT - Smali:" >> verification/02-share-plumbing.txt
rg "android\.intent\.extra\.TEXT" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/02-share-plumbing.txt
rg "android\.intent\.extra\.TEXT" decompiled-smali-full/smali_*/ | head -20 >> verification/02-share-plumbing.txt

echo -e "\nClipboardManager - JADX:" >> verification/02-share-plumbing.txt
rg "ClipboardManager|ClipData\.newPlainText" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/02-share-plumbing.txt
rg "ClipboardManager|ClipData\.newPlainText" decompiled-jadx/sources/ | head -20 >> verification/02-share-plumbing.txt

echo -e "\nClipboardManager - Smali:" >> verification/02-share-plumbing.txt
rg "ClipboardManager|ClipData|newPlainText" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/02-share-plumbing.txt
rg "ClipboardManager|ClipData|newPlainText" decompiled-smali-full/smali_*/ | head -20 >> verification/02-share-plumbing.txt

# ===== STEP 4: Invoke-Custom Analysis =====
echo -e "\n=== STEP 4: Invoke-Custom/Lambda Analysis ===" > verification/03-lambda-analysis.txt

echo "invoke-custom in Smali UEU:" >> verification/03-lambda-analysis.txt
rg "invoke-custom" decompiled-smali-full/smali_classes15/X/UEU.smali -B2 -A5 >> verification/03-lambda-analysis.txt 2>&1 || echo "No invoke-custom found"

echo -e "\nLambda classes in Smali:" >> verification/03-lambda-analysis.txt
find decompiled-smali-full/smali_classes15/X -name "*\$*" -type f | head -20 >> verification/03-lambda-analysis.txt 2>&1 || echo "No lambda classes found"

echo -e "\nJADX Lambda/Anonymous usage in UEU:" >> verification/03-lambda-analysis.txt
rg "-> \{|Function0|Function1|InterfaceC" decompiled-jadx/sources/p003X/UEU.java -B2 -A3 >> verification/03-lambda-analysis.txt 2>&1 || echo "No lambdas found"

# ===== STEP 5: Resource Strings =====
echo -e "\n=== STEP 5: Resource Strings Side-Channel ===" > verification/04-resource-strings.txt

echo "Share-related strings in res/:" >> verification/04-resource-strings.txt
find decompiled-smali-full/res -name "strings.xml" -type f | head -5 >> verification/04-resource-strings.txt 2>&1
rg "<string.*share|<string.*copy|<string.*link" decompiled-smali-full/res/ | head -20 >> verification/04-resource-strings.txt 2>&1 || echo "No share strings found"

echo -e "\nTracking parameters in res/:" >> verification/04-resource-strings.txt
rg "utm_|tt_chain|enter_from" decompiled-smali-full/res/ | head -20 >> verification/04-resource-strings.txt 2>&1 || echo "No tracking params found"

echo -e "\nAssets URL patterns:" >> verification/04-resource-strings.txt
find decompiled-smali-full/assets -type f | head -10 >> verification/04-resource-strings.txt 2>&1 || echo "No assets found"
rg "vm\.tiktok|www\.tiktok\.com|share_url" decompiled-smali-full/assets/ | head -20 >> verification/04-resource-strings.txt 2>&1 || echo "No URL patterns in assets"

# ===== STEP 6: URL Variants =====
echo -e "\n=== STEP 6: URL Variant Detection ===" > verification/05-url-variants.txt

echo "vm.tiktok.com - JADX:" >> verification/05-url-variants.txt
rg "vm\.tiktok\.com" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo "vm.tiktok.com - Smali:" >> verification/05-url-variants.txt
rg "vm\.tiktok\.com" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo -e "\nvt.tiktok.com - JADX:" >> verification/05-url-variants.txt
rg "vt\.tiktok\.com" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo "vt.tiktok.com - Smali:" >> verification/05-url-variants.txt
rg "vt\.tiktok\.com" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo -e "\nwww.tiktok.com/t/ - JADX:" >> verification/05-url-variants.txt
rg "www\.tiktok\.com/t/" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo "www.tiktok.com/t/ - Smali:" >> verification/05-url-variants.txt
rg "www\.tiktok\.com/t/" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo -e "\nm.tiktok.com - JADX:" >> verification/05-url-variants.txt
rg "m\.tiktok\.com" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo "m.tiktok.com - Smali:" >> verification/05-url-variants.txt
rg "m\.tiktok\.com" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo -e "\nCanonical www.tiktok.com/@user/video/ - JADX:" >> verification/05-url-variants.txt
rg "www\.tiktok\.com/@|/@.*/video/" decompiled-jadx/sources/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo "Canonical www.tiktok.com/@user/video/ - Smali:" >> verification/05-url-variants.txt
rg "www\.tiktok\.com/@|/@.*/video/" decompiled-smali-full/smali_*/ --files-with-matches | wc -l >> verification/05-url-variants.txt

echo "✓ All verification searches complete"

