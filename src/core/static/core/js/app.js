/* ============================================================
   Focus Guardian AI - Shared Frontend Utilities
   Handles JWT auth, automatic token refresh, API calls,
   and toast notifications. Used across all pages.
   ============================================================ */

(function (window) {
    "use strict";

    const API_BASE = "/api/v1";
    const ACCESS_KEY = "fg_access_token";
    const REFRESH_KEY = "fg_refresh_token";

    /* ---------------- Token storage ---------------- */
    const Auth = {
        getAccess() { return localStorage.getItem(ACCESS_KEY); },
        getRefresh() { return localStorage.getItem(REFRESH_KEY); },
        setTokens(access, refresh) {
            if (access) localStorage.setItem(ACCESS_KEY, access);
            if (refresh) localStorage.setItem(REFRESH_KEY, refresh);
        },
        clear() {
            localStorage.removeItem(ACCESS_KEY);
            localStorage.removeItem(REFRESH_KEY);
        },
        isAuthenticated() { return !!localStorage.getItem(ACCESS_KEY); },
        /** Redirect to login if not authenticated. Returns true if OK. */
        requireAuth() {
            if (!this.isAuthenticated()) {
                window.location.replace("/");
                return false;
            }
            return true;
        },
        logout() {
            const refresh = this.getRefresh();
            const access = this.getAccess();
            // Best-effort server-side blacklist; don't block on it.
            if (refresh) {
                fetch(`${API_BASE}/auth/logout/`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        ...(access ? { Authorization: `Bearer ${access}` } : {}),
                    },
                    body: JSON.stringify({ refresh }),
                }).catch(() => {});
            }
            this.clear();
            window.location.replace("/");
        },
    };

    /* ---------------- Token refresh ---------------- */
    let refreshPromise = null;

    async function refreshAccessToken() {
        // De-duplicate concurrent refreshes.
        if (refreshPromise) return refreshPromise;

        const refresh = Auth.getRefresh();
        if (!refresh) return null;

        refreshPromise = (async () => {
            try {
                const res = await fetch(`${API_BASE}/auth/token/refresh/`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ refresh }),
                });
                if (!res.ok) return null;
                const data = await res.json();
                if (data.access) {
                    Auth.setTokens(data.access, data.refresh || null);
                    return data.access;
                }
                return null;
            } catch (_) {
                return null;
            } finally {
                refreshPromise = null;
            }
        })();

        return refreshPromise;
    }

    /* ---------------- API wrapper ---------------- */
    /**
     * Perform an authenticated API request.
     * Automatically refreshes the access token once on 401 and retries.
     * @returns {Promise<{ok: boolean, status: number, data: any}>}
     */
    async function apiFetch(path, options = {}, _retry = false) {
        const url = path.startsWith("http") ? path : `${API_BASE}${path}`;
        const headers = Object.assign({ "Content-Type": "application/json" }, options.headers || {});
        const access = Auth.getAccess();
        if (access) headers["Authorization"] = `Bearer ${access}`;

        let res;
        try {
            res = await fetch(url, { ...options, headers });
        } catch (networkErr) {
            return { ok: false, status: 0, data: { error: { message: "Network error. Check your connection." } } };
        }

        // Auto-refresh on expired token (once).
        if (res.status === 401 && !_retry && Auth.getRefresh()) {
            const newAccess = await refreshAccessToken();
            if (newAccess) {
                return apiFetch(path, options, true);
            }
            // Refresh failed -> session expired.
            Auth.clear();
            window.location.replace("/");
            return { ok: false, status: 401, data: { error: { message: "Session expired." } } };
        }

        let data = null;
        const text = await res.text();
        if (text) {
            try { data = JSON.parse(text); } catch (_) { data = { raw: text }; }
        }
        return { ok: res.ok, status: res.status, data };
    }

    /* ---------------- Toast notifications ---------------- */
    function ensureToastContainer() {
        let c = document.querySelector(".toast-container");
        if (!c) {
            c = document.createElement("div");
            c.className = "toast-container";
            document.body.appendChild(c);
        }
        return c;
    }

    function toast(message, type = "info", duration = 3500) {
        const container = ensureToastContainer();
        const el = document.createElement("div");
        el.className = `toast ${type}`;
        const icon = type === "success" ? "\u2713" : type === "error" ? "\u26A0" : "\u2139";
        el.innerHTML = `<span>${icon}</span><span></span>`;
        el.lastChild.textContent = message;
        container.appendChild(el);
        setTimeout(() => {
            el.style.transition = "opacity 220ms, transform 220ms";
            el.style.opacity = "0";
            el.style.transform = "translateX(20px)";
            setTimeout(() => el.remove(), 240);
        }, duration);
    }

    /* ---------------- Helpers ---------------- */
    function escapeHtml(str) {
        const div = document.createElement("div");
        div.textContent = str == null ? "" : String(str);
        return div.innerHTML;
    }

    function extractError(data, fallback = "Something went wrong.") {
        if (!data) return fallback;
        if (data.error) {
            if (typeof data.error === "string") return data.error;
            if (data.error.message) {
                let msg = data.error.message;
                if (data.error.details) {
                    const details = data.error.details;
                    const parts = [];
                    for (const k in details) {
                        const v = details[k];
                        parts.push(Array.isArray(v) ? v.join(" ") : v);
                    }
                    if (parts.length) msg = parts.join(" ");
                }
                return msg;
            }
        }
        if (data.detail) return data.detail;
        return fallback;
    }

    // Expose globally
    window.FG = { API_BASE, Auth, apiFetch, toast, escapeHtml, extractError };
})(window);
