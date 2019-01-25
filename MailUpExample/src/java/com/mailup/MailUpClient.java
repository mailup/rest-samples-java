/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mailup;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Date;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.KeyManager;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.codec.binary.Base64;
import org.json.JSONObject;

/**
 *
 * @author sergeiinyushkin
 */
public class MailUpClient {

    private String logonEndpoint = "https://services.mailup.com/Authorization/OAuth/LogOn";
    private String authorizationEndpoint = "https://services.mailup.com/Authorization/OAuth/Authorization";
    private String tokenEndpoint = "https://services.mailup.com/Authorization/OAuth/Token";
    private String consoleEndpoint = "https://services.mailup.com/API/v1.1/Rest/ConsoleService.svc";
    private String mailstatisticsEndpoint = "https://services.mailup.com/API/v1.1/Rest/MailStatisticsService.svc";

    private String clientId;
    private String clientSecret;
    private String callbackUri;
    private String accessToken;
    private String refreshToken;
    private int expiresIn;

    /**
     * @return the logonEndpoint
     */
    public String getLogonEndpoint() {
        return logonEndpoint;
    }

    /**
     * @param logonEndpoint the logonEndpoint to set
     */
    public void setLogonEndpoint(String logonEndpoint) {
        this.logonEndpoint = logonEndpoint;
    }

    /**
     * @return the authorizationEndpoint
     */
    public String getAuthorizationEndpoint() {
        return authorizationEndpoint;
    }

    /**
     * @param authorizationEndpoint the authorizationEndpoint to set
     */
    public void setAuthorizationEndpoint(String authorizationEndpoint) {
        this.authorizationEndpoint = authorizationEndpoint;
    }

    /**
     * @return the tokenEndpoint
     */
    public String getTokenEndpoint() {
        return tokenEndpoint;
    }

    /**
     * @param tokenEndpoint the tokenEndpoint to set
     */
    public void setTokenEndpoint(String tokenEndpoint) {
        this.tokenEndpoint = tokenEndpoint;
    }

    /**
     * @return the consoleEndpoint
     */
    public String getConsoleEndpoint() {
        return consoleEndpoint;
    }

    /**
     * @param consoleEndpoint the consoleEndpoint to set
     */
    public void setConsoleEndpoint(String consoleEndpoint) {
        this.consoleEndpoint = consoleEndpoint;
    }

    /**
     * @return the mailstatisticsEndpoint
     */
    public String getMailstatisticsEndpoint() {
        return mailstatisticsEndpoint;
    }

    /**
     * @param mailstatisticsEndpoint the mailstatisticsEndpoint to set
     */
    public void setMailstatisticsEndpoint(String mailstatisticsEndpoint) {
        this.mailstatisticsEndpoint = mailstatisticsEndpoint;
    }

    /**
     * @return the clientId
     */
    public String getClientId() {
        return clientId;
    }

    /**
     * @param clientId the clientId to set
     */
    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    /**
     * @return the clientSecret
     */
    public String getClientSecret() {
        return clientSecret;
    }

    /**
     * @param clientSecret the clientSecret to set
     */
    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }

    /**
     * @return the callbackUri
     */
    public String getCallbackUri() {
        return callbackUri;
    }

    /**
     * @param callbackUri the callbackUri to set
     */
    public void setCallbackUri(String callbackUri) {
        this.callbackUri = callbackUri;
    }

    /**
     * @return the accessToken
     */
    public String getAccessToken() {
        return accessToken;
    }

    /**
     * @param accessToken the accessToken to set
     */
    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    /**
     * @return the refreshToken
     */
    public String getRefreshToken() {
        return refreshToken;
    }

    /**
     * @param refreshToken the refreshToken to set
     */
    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    /**
     * @return the expiresIn
     */
    public int getExpiresIn() {
        return expiresIn;
    }

    /**
     * @param expiresIn the expiresIn to set
     */
    public void setExpiresIn(int expiresIn) {
        this.expiresIn = expiresIn;
    }

    public MailUpClient(String clientId, String clientSecret, String callbackUri, HttpServletRequest request) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.callbackUri = callbackUri;

        loadToken(request);
    }

    public String getLogOnUri() {
        String url = getLogonEndpoint() + "?client_id=" + getClientId() + "&client_secret=" + getClientSecret() + "&response_type=code&redirect_uri=" + getCallbackUri();
        return url;
    }

    public void logOn(HttpServletResponse response) throws IOException {
        String url = getLogOnUri();
        response.sendRedirect(url);
    }

    public void logOnWithUsernamePassword(String username, String password, HttpServletResponse response) throws MailUpException {
        int statusCode = 0;
        try {
            this.retreiveAccessToken(username, password, response);
        } catch (Exception ex) {
            throw new MailUpException(statusCode, ex.getMessage());
        }
    }

    //------ JAVA 1.7.0 SSL Fix
    private void InitializeSSL() throws NoSuchAlgorithmException, KeyManagementException {
        SSLContext ctx = SSLContext.getInstance("TLS");
        ctx.init(new KeyManager[0], new TrustManager[]{new DefaultTrustManager()}, new SecureRandom());
        SSLContext.setDefault(ctx);

        HttpsURLConnection.setDefaultSSLSocketFactory(ctx.getSocketFactory());

        // Create all-trusting host name verifier
        HostnameVerifier allHostsValid = new HostnameVerifier() {
            @Override
            public boolean verify(String hostname, SSLSession session) {
                return true;
            }
        };

        // Install the all-trusting host verifier
        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
    }

    private static class DefaultTrustManager implements X509TrustManager {

        @Override
        public void checkClientTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {
        }

        @Override
        public void checkServerTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {
        }

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            return null;
        }

    }

    //------ JAVA 1.7.0 SSL Fix
    public String retreiveAccessToken(String code, HttpServletResponse response) throws MailUpException {
        int statusCode = 0;
        try {

            InitializeSSL();

            HttpsURLConnection con = (HttpsURLConnection) new URL(tokenEndpoint + "?code=" + code + "&grant_type=authorization_code").openConnection();
            con.setRequestMethod("GET");

            statusCode = con.getResponseCode();
            extractAndSaveTokenInfo(con, response);
        } catch (Exception ex) {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return accessToken;
    }

    public String retreiveAccessToken(String login, String password, HttpServletResponse response) throws MailUpException {
        int statusCode = 0;
        try {
            InitializeSSL();

            String body = "client_id=" + clientId + "&client_secret=" + clientSecret + "&grant_type=password" + "&username=" + login + "&password=" + password;
            HttpsURLConnection con = (HttpsURLConnection) new URL(tokenEndpoint).openConnection();
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            con.setRequestProperty("Content-Length", "" + body.length());

            byte[] auth = String.format("%s:%s", this.clientId, this.clientSecret).getBytes();
            con.setRequestProperty("Authorization", "Basic " + Base64.encodeBase64String(auth));

            con.setDoOutput(true);
            DataOutputStream wr = new DataOutputStream(con.getOutputStream());
            wr.writeBytes(body);
            wr.flush();
            wr.close();

            statusCode = con.getResponseCode();
            extractAndSaveTokenInfo(con, response);
        } catch (Exception ex) {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return accessToken;
    }

    public String refreshAccessToken(HttpServletResponse response) throws MailUpException {
        int statusCode = 0;
        try {
            InitializeSSL();

            HttpsURLConnection con = (HttpsURLConnection) new URL(tokenEndpoint).openConnection();
            con.setRequestMethod("POST");

            String body = "client_id=" + clientId + "&client_secret=" + clientSecret + "&refresh_token=" + refreshToken + "&grant_type=refresh_token";
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            con.setRequestProperty("Content-Length", "" + body.length());

            con.setDoOutput(true);
            DataOutputStream wr = new DataOutputStream(con.getOutputStream());
            wr.writeBytes(body);
            wr.flush();
            wr.close();

            statusCode = con.getResponseCode();
            extractAndSaveTokenInfo(con, response);
        } catch (Exception ex) {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return accessToken;
    }

    public String callMethod(String url, String verb, String body, String contentType, HttpServletResponse response) throws MailUpException {
        return callMethod(url, verb, body, contentType, true, response);
    }

    private String callMethod(String url, String verb, String body, String contentType, boolean refresh, HttpServletResponse response) throws MailUpException {
        String resultStr = "";
        HttpsURLConnection con = null;
        int statusCode = 0;
        try {
            InitializeSSL();

            con = (HttpsURLConnection) new URL(url).openConnection();
            con.setRequestMethod(verb);
            con.setRequestProperty("Content-Type", contentType);
            con.setRequestProperty("Accept", contentType);
            con.setRequestProperty("Authorization", "Bearer " + accessToken);

            if (body != null && !"".equals(body)) {
                con.setDoOutput(true);
                DataOutputStream wr = new DataOutputStream(con.getOutputStream());
                wr.writeBytes(body);
                wr.flush();
                wr.close();
            } else if ("POST".equals(verb) || "PUT".equals(verb)) {
                con.setDoOutput(true);
                DataOutputStream wr = new DataOutputStream(con.getOutputStream());
                wr.flush();
                wr.close();
            }

            statusCode = con.getResponseCode();

            if (statusCode == 401 && refresh) {
                refreshAccessToken(response);
                return callMethod(url, verb, body, contentType, false, response);
            }

            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer result = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                result.append(inputLine);
            }
            in.close();

            resultStr = result.toString();
        } catch (IOException iex) {
            try {
                statusCode = con.getResponseCode();
                if (statusCode == 401 && refresh) {
                    refreshAccessToken(response);
                    return callMethod(url, verb, body, contentType, false, response);
                } else {
                    throw new MailUpException(statusCode, iex.getMessage());
                }
            } catch (Exception ex) {
                throw new MailUpException(statusCode, ex.getMessage());
            }
        } catch (Exception ex) {
            throw new MailUpException(statusCode, ex.getMessage());
        }

        //TODO: updateExpiresIn();
        return resultStr;
    }

    private void extractAndSaveTokenInfo(HttpsURLConnection con, HttpServletResponse response) throws Exception {
        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuilder result = new StringBuilder();

        while ((inputLine = in.readLine()) != null) {
            result.append(inputLine);
        }
        in.close();

        JSONObject obj = new JSONObject(result.toString());

        accessToken = obj.getString("access_token");
        refreshToken = obj.getString("refresh_token");
        expiresIn = obj.getInt("expires_in");

        // set cookies
        Cookie cookieAccess = new Cookie("access_token", accessToken);
        cookieAccess.setMaxAge(expiresIn);
        response.addCookie(cookieAccess);

        Cookie cookieRefresh = new Cookie("refresh_token", refreshToken);
        cookieRefresh.setMaxAge(expiresIn);
        response.addCookie(cookieRefresh);

        Cookie cookieAccessExpire = new Cookie("access_token_expire", String.valueOf((new Date()).getTime() + expiresIn * 1000));
        cookieAccessExpire.setMaxAge(expiresIn);
        response.addCookie(cookieAccessExpire);
    }

    private void loadToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (int i = 0; i < cookies.length; i++) {
                Cookie cookie = cookies[i];
                if ("access_token".equals(cookie.getName())) {
                    accessToken = cookie.getValue();
                }
                if ("refresh_token".equals(cookie.getName())) {
                    refreshToken = cookie.getValue();
                }
            }
        }
    }
}
