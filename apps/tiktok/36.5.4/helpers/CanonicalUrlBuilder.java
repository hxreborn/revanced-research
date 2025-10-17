package app.revanced.tiktok.share;

import android.net.Uri;
import androidx.annotation.Nullable;

/**
 * Builds canonical TikTok share URLs without tracking parameters.
 * Extracts video ID and author handle from Aweme or falls back to parsing
 * the existing share URL.
 */
public final class CanonicalUrlBuilder {

    /**
     * Strip query parameters from URL (everything after '?')
     */
    private static String stripQuery(String url) {
        if (url == null) {
            return "";
        }
        int idx = url.indexOf('?');
        return idx >= 0 ? url.substring(0, idx) : url;
    }

    /**
     * Build a canonical URL from Aweme object or fallback to parsing originalUrl.
     *
     * @param aweme The Aweme object (nullable)
     * @param originalUrl The original share URL with tracking params (nullable)
     * @return Canonical URL in format https://www.tiktok.com/@handle/video/aid
     *         or https://www.tiktok.com/video/aid if handle unavailable,
     *         or originalUrl as final fallback
     */
    public static String buildFromAweme(@Nullable Object aweme, @Nullable String originalUrl) {
        try {
            String aid = null;
            String handle = null;

            // Try to extract from Aweme object
            if (aweme != null) {
                try {
                    // Get video ID via reflection (Aweme.getAid())
                    java.lang.reflect.Method getAidMethod = aweme.getClass().getMethod("getAid");
                    Object aidObj = getAidMethod.invoke(aweme);
                    if (aidObj != null) {
                        aid = aidObj.toString();
                    }

                    // Get author via reflection (Aweme.getAuthor())
                    java.lang.reflect.Method getAuthorMethod = aweme.getClass().getMethod("getAuthor");
                    Object author = getAuthorMethod.invoke(aweme);

                    if (author != null) {
                        // Get unique ID from author via reflection (Author.getUniqueId())
                        java.lang.reflect.Method getUniqueIdMethod = author.getClass().getMethod("getUniqueId");
                        Object handleObj = getUniqueIdMethod.invoke(author);
                        if (handleObj != null) {
                            String handleStr = handleObj.toString();
                            if (handleStr != null && !handleStr.isEmpty()) {
                                handle = handleStr;
                            }
                        }
                    }
                } catch (Exception e) {
                    // Reflection failed, will try URL parsing
                }
            }

            // Fallback: parse original URL for video ID
            if (aid == null && originalUrl != null && !originalUrl.isEmpty()) {
                try {
                    Uri uri = Uri.parse(originalUrl);
                    String path = uri.getPath(); // e.g., /@jupiqueen/video/7547495989037239582
                    if (path != null) {
                        // Extract video ID from path: /video/12345
                        if (path.contains("/video/")) {
                            String[] parts = path.split("/video/");
                            if (parts.length > 1) {
                                aid = parts[1].split("[?&]")[0]; // Remove query params if present
                            }
                        }

                        // Extract handle if not already found
                        if (handle == null && path.startsWith("/@")) {
                            int endHandle = path.indexOf("/", 2);
                            if (endHandle > 2) {
                                handle = path.substring(2, endHandle);
                            }
                        }
                    }
                    // Fall through to return stripped originalUrl if we couldn't extract components
                    if (aid == null) {
                        return stripQuery(originalUrl); // Strip query params from fallback URL
                    }
                } catch (Exception e) {
                    // URL parsing failed - return stripped URL as fallback
                    if (originalUrl != null && !originalUrl.isEmpty()) {
                        return stripQuery(originalUrl);
                    }
                }
            }

            // Build canonical URL
            if (aid != null && !aid.isEmpty()) {
                if (handle != null && !handle.isEmpty()) {
                    return stripQuery("https://www.tiktok.com/@" + handle + "/video/" + aid);
                } else {
                    return stripQuery("https://www.tiktok.com/video/" + aid);
                }
            }

            // Safety fallback: return original URL if we couldn't determine aid
            if (originalUrl != null && !originalUrl.isEmpty()) {
                return originalUrl;
            }

            return "";

        } catch (Exception e) {
            // Catch-all: return original URL to keep flow functional
            return (originalUrl != null && !originalUrl.isEmpty()) ? originalUrl : "";
        }
    }
}
