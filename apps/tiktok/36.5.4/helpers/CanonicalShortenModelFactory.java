package app.revanced.tiktok.share;

import androidx.annotation.NonNull;

/**
 * Factory for creating a mock ShortenModel that represents a canonical URL.
 * Returns a structure compatible with the TikTok share pipeline, wrapping
 * the canonical URL as if it came from the shortening API.
 */
public final class CanonicalShortenModelFactory {

    /**
     * Create a ShortenModel representing a canonical (non-shortened) URL.
     * Mimics the response structure of IShortenUrlApi.getShareLinkShortenUel()
     * so downstream code sees no difference.
     *
     * @param canonicalUrl The canonical URL to wrap
     * @return A ShortenModel-compatible object with status=200, msg="Success", shortUrl=canonicalUrl
     */
    @NonNull
    public static Object create(@NonNull String canonicalUrl) {
        try {
            // Try to instantiate ShortenModel class
            // Full class name: com.ss.android.ugc.aweme.share.model.ShortenModel
            Class<?> shortenModelClass = Class.forName(
                "com.ss.android.ugc.aweme.share.model.ShortenModel"
            );
            Object model = shortenModelClass.newInstance();

            // Set status code = 200
            try {
                java.lang.reflect.Field statusCodeField = shortenModelClass.getDeclaredField("statusCode");
                statusCodeField.setAccessible(true);
                statusCodeField.setInt(model, 200);
            } catch (Exception e) {
                // Field might have different name, try alternate
                try {
                    java.lang.reflect.Field statusField = shortenModelClass.getDeclaredField("status");
                    statusField.setAccessible(true);
                    statusField.setInt(model, 200);
                } catch (Exception e2) {
                    // ignore
                }
            }

            // Set status message = "Success"
            try {
                java.lang.reflect.Field statusMsgField = shortenModelClass.getDeclaredField("statusMsg");
                statusMsgField.setAccessible(true);
                statusMsgField.set(model, "Success");
            } catch (Exception e) {
                // Field might not exist, ignore
            }

            // Set short URL to canonical URL
            try {
                java.lang.reflect.Field shortUrlField = shortenModelClass.getDeclaredField("shortUrl");
                shortUrlField.setAccessible(true);
                shortUrlField.set(model, canonicalUrl);
            } catch (Exception e) {
                try {
                    java.lang.reflect.Field urlField = shortenModelClass.getDeclaredField("url");
                    urlField.setAccessible(true);
                    urlField.set(model, canonicalUrl);
                } catch (Exception e2) {
                    // ignore
                }
            }

            // Set original URL to canonical URL (optional field)
            try {
                java.lang.reflect.Field originalUrlField = shortenModelClass.getDeclaredField("originalUrl");
                originalUrlField.setAccessible(true);
                originalUrlField.set(model, canonicalUrl);
            } catch (Exception e) {
                // Field might not exist, ignore
            }

            return model;

        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException e) {
            // Fallback: return the canonical URL string itself
            // Downstream code may wrap it or handle it directly
            return canonicalUrl;
        }
    }
}
