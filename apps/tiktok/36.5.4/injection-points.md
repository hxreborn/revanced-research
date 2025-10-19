# Verified Injection Points - TikTok 36.5.4

## Test Results - 2025-10-19

### ❌ FAILED: AwemeSharePackage.LJIJJ() Injection
- **File**: `smali-classes15/com/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.smali`
- **Method**: `LJIJJ(Ljava/util/List;LX/UIg;Ljava/lang/String;ILkotlin/jvm/functions/Function2;)V` at line 21638
- **Attempted Patch**: Hardcoded test URL after line 21729
  - `const-string v4, "https://www.tiktok.com/@PATCHTEST/video/9999999999999999999"`
- **Result**: ❌ **URL still came out shortened** (vm.tiktok.com)
- **Finding**: The shortened URL is already present in the List at line 21682 BEFORE it reaches LJIJJ
- **Conclusion**: Shortening happens earlier in the pipeline - need to trace back to where URL is selected/shortened

### Key Observation
```smali
# Line 21682: URL comes from List<String>
invoke-static {p1, p4}...ListProtector;->get(Ljava/util/List;I)Ljava/lang/Object;
move-result-object v2
check-cast v2, Ljava/lang/String;

# Line 21724: URL passed to UEU.LIZ() (adds query params, but doesn't create shortened link)
invoke-static {v1, v2}, LX/UEU;->LIZ(Landroid/os/Bundle;Ljava/lang/String;)Ljava/lang/String;
```

**The shortened URL was created BEFORE being added to the List** - so LJIJJ is too late in the pipeline.

## Next Investigation
- Need to find where the Aweme object or SharePackage creates/selects the shortened URL
- Trace back: Aweme → gateway → builder → List[shortened_url]
- Search for where shortened URL is generated (likely API call or URL builder)
