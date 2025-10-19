# Share URL Verification – 2025-10-19

## Target Review
| Target | Status | Evidence |
| --- | --- | --- |
| `com.p124ss.ugc.aweme.creation.base.ShareModel#getShareUrl()` / `setShareUrl()` | ❌ | `apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/ugc/aweme/creation/base/ShareModel.java:11-55` only defines Open Platform metadata; no share URL field or accessors present. |
| `com.appsflyer.share.ShareInviteHelper#generateInviteUrl()` | ✅ | `apps/tiktok/36.5.4/decompiled-jadx/sources/com/appsflyer/share/ShareInviteHelper.java:13-49` builds the AppsFlyer invite link with slug/domain settings. |
| `com.bytedance.android.livesdkapi.depend.model.live.Room#shareUrl` | ✅ | Field declaration at `apps/tiktok/36.5.4/decompiled-jadx/sources/com/bytedance/android/livesdkapi/depend/model/live/Room.java:472-512` with getter/setter at `apps/tiktok/36.5.4/decompiled-jadx/sources/com/bytedance/android/livesdkapi/depend/model/live/Room.java:1000-1013` and `apps/tiktok/36.5.4/decompiled-jadx/sources/com/bytedance/android/livesdkapi/depend/model/live/Room.java:1256-1267`, matching the map entry. |
| `com.p124ss.android.ugc.aweme.channel.share.channel.wrap.WrapDefaultWhatsappChannel#LJIJ(UGU, Context, InterfaceC54258JOz)` | ✅ | Method at `apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/android/ugc/aweme/channel/share/channel/wrap/WrapDefaultWhatsappChannel.java:19-60` pulls `AbstractC82063UGk.m11879LJ(content)` into WhatsApp intents. |
| `p003X.AbstractC82063UGk#m11879LJ(UGU)` | ✅ | `apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/AbstractC82063UGk.java:66-93` concatenates channel text, title, and `content.LIZIZ`/`content.LIZJ`. |
| `p003X.UEU#LIZJ(int, String, String, String)` | ✅ | `apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/UEU.java:62-89` rewrites the long URL via `C82001UEa.LIZ` and returns the canonicalized/shortened result. |
| `com.p124ss.android.ugc.aweme.relation.share.InviteFriendsSheetPackage#LJIILIIL(InterfaceC82111UIg)` | ✅ | `apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/android/ugc/aweme/relation/share/InviteFriendsSheetPackage.java:31-49` feeds `UEU.LIZJ(...)` into `UGU`/`UGT` share content objects. |

## Share URL Flow
- **Aweme → SharePackage Builder:** `BaseSharePackage` stores the builder’s `url` field (`UJ3.LJI(...)`) directly on construction (`apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/android/ugc/aweme/share/base/model/BaseSharePackage.java:22-54`). Upstream builder assembly (`apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/C54243JOk.java`) was not fully decompiled, leaving the exact Aweme field → builder wiring unconfirmed.
- **Builder → URL Generator:** Channel-specific packages (e.g. `InviteFriendsSheetPackage`) immediately pass `this.url` into `UEU.LIZJ`, which canonically rewrites or shortens the link before placing it in `UGU`/`UGT` payloads (`apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/android/ugc/aweme/relation/share/InviteFriendsSheetPackage.java:31-49`).
- **Generator → Channel Text:** `AbstractC82063UGk.m11879LJ` assembles the outbound text block using `UGU/UGT` fields; wrap channels such as WhatsApp reuse that helper before filling `Intent` extras (`apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/AbstractC82063UGk.java:66-93`, `apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/android/ugc/aweme/channel/share/channel/wrap/WrapDefaultWhatsappChannel.java:31-60`).
- **Generator → Clipboard:** `CopyLinkChannel.LJFF` builds the clipboard string from `UGT`’s `LIZJ`/`LIZLLL` fields (`apps/tiktok/36.5.4/decompiled-jadx/sources/com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.java:101-134`) and hands it to `C81999UDy.LIZLLL`, which writes `ClipData.newPlainText` to the system clipboard (`apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/C81999UDy.java:188-226`).
- **Share Intents:** `WrapDefaultWhatsappChannel.LJIJ` injects the same `AbstractC82063UGk.m11879LJ` output into `Intent.setData` / `Intent.putExtra` for WhatsApp (`WrapDefaultWhatsappChannel.java:39-58`), representative of other channels following the same utility method.

## Source of Truth
`p003X.UEU#LIZJ(int, String, String, String)` (`apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/UEU.java:62-89`) is the decisive formatter for the user-visible link. Its return value is stored in `UGU/UGT` and survives unchanged into clipboard text and intent extras, so patching this method alters every downstream channel.

## Open Questions / Gaps
- `p003X.C54243JOk.LIZ(...)` (`apps/tiktok/36.5.4/decompiled-jadx/sources/p003X/C54243JOk.java`) failed to decompile, so the precise origin of `builder.LJFF`—likely `Aweme.getShareUrl()` or similar—could not be revalidated here.
- Earlier mapping to `com.p124ss.ugc.aweme.creation.base.ShareModel` appears incorrect; the class lacks any share URL state, suggesting the table entry needs revision or a different class name.

## Phase 1 Deep Verification: JADX vs Smali Cross-Reference

### Goal
Verify that the decompilation artifacts match at method-level precision by comparing JVM descriptors, class sharding, share plumbing, lambda handling, and resource strings between the JADX Java sources and Smali bytecode.

### Enhanced Verification Strategy

**Step 1: Confirm Exact JVM Descriptors**
- Objective: ensure method signatures are byte-for-byte identical.
- Actions:
  - Extract signatures from `decompiled-jadx/sources/p003X/UEU.java` using `rg "LIZJ\(.*String.*String.*\).*String" ... -A2`.
  - Inspect Smali descriptor via `rg "\.method.*LIZJ\(" decompiled-smali-full/smali_classes15/X/UEU.smali -A1`.
- Expected match: `.method public static LIZJ(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;` with four parameters (int + three strings) and a string return type.
- Checks: Static modifier present, descriptor matches `LX/UEU;->LIZJ(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;`.

**Step 2: Verify Smali Shard Path Mapping**
- Objective: confirm package-to-shard consistency.
- Actions:
  - Map `p003X/UEU.java` → `smali_classes15/X/UEU.smali`.
  - Map `p003X/AbstractC82063UGk.java` → `smali_classes15/X/UGk.smali`.
  - Map `com/p124ss/android/ugc/aweme/channel/share/channel/wrap/WrapDefaultWhatsappChannel.java` → `smali_classes15/com/ss/android/ugc/aweme/channel/share/channel/wrap/WrapDefaultWhatsappChannel.smali`.
- Checks: `p003X` packages land under `X/`, `com.p124ss` collapses to `com/ss/`, and share classes reside in `smali_classes15`.

**Step 3: Check Share Plumbing Only**
- Objective: restrict verification to Android share flows.
- Searches:
  - ACTION_SEND intents: grep both trees and compare (`verification/jadx-action-send.txt`, `verification/smali-action-send.txt`).
  - EXTRA_TEXT payloads: mirror search for `android.intent.extra.TEXT`.
  - ClipboardManager usage: capture `ClipData.newPlainText` and equivalent Smali calls.
- Checks: matching file counts, `Intent.putExtra("android.intent.extra.TEXT", ...)` present in both, and clipboard write paths align.

**Step 4: Invoke-Custom / Lambda Mapping**
- Objective: account for desugared lambdas.
- Actions:
  - Locate `invoke-custom` entries in `smali_classes15/X/UEU.smali`.
  - Enumerate generated lambda classes (`*$*$*.smali`).
  - Compare with JADX lambda rewrites (`InterfaceC...` anonymous classes) and ensure counts align.
- Checks: number of `invoke-custom` entries equals corresponding lambda replacements; confirm callback at the `UEU.LIZJ` invoke site.

**Step 5: Resource Strings Side-Channel**
- Objective: correlate share-related resources with code usage.
- Actions:
  - Search `res/values*` for share/copy/link strings and tracking tokens (`utm_`, `tt_chain`, `enter_from`).
  - Inspect assets for hardcoded URL patterns (`vm.tiktok`, `www.tiktok.com`, `share_url`).
  - Cross-reference string IDs by grepping `R.string.*` usages in both Java and Smali.
- Checks: resource IDs align between outputs; assets contain expected URL builder configuration hints.

**Output: Comprehensive Verification Report**
- Produce `verification/VERIFICATION-REPORT.md` summarizing:
  1. JVM descriptor verification (per-method ✅/❌).
  2. Smali shard mapping status.
  3. Share plumbing coverage counts (ACTION_SEND, EXTRA_TEXT, ClipboardManager).
  4. Lambda handling counts and mapping confidence.
  5. Resource side-channel findings.
- Conclusion should state PASS/FAIL readiness for Phase 2.

**Success Criteria**
- ✅ JVM descriptors match exactly.
- ✅ Smali shard paths reflect JADX packages.
- ✅ Share plumbing verified in both representations.
- ✅ Lambda/invoke-custom mapping understood.
- ✅ Resource strings cross-referenced with code.
- PASS gate indicates readiness for Phase 2 Smali patch testing.
