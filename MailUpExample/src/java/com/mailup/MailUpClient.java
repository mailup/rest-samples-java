/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mailup;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author sergeiinyushkin
 */
public class MailUpClient {
    
    private String logonEndpoint = "https://services.mailup.com/Authorization/OAuth/LogOn";
    private String authorizationEndpoint = "https://services.mailup.com/Authorization/Authorization";
    private String tokenEndpoint = "https://services.mailup.com/Authorization/OAuth/Token";
    private String consoleEndpoint = "https://services.mailup.com/API/v1/Rest/ConsoleService.svc";
    private String mailstatisticsEndpoint = "https://services.mailup.com/API/v1/Rest/MailStatisticsService.svc";
    
    private String clientId;
    private String clientSecret;
    private String callbackUri;
    private String accessToken;
    private String refreshToken;

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

    public void logOn(HttpServletResponse response) throws IOException
    {
        String url = getLogOnUri();
        response.sendRedirect(url);
    }

    public String retreiveAccessToken(String code, HttpServletResponse response) throws MailUpException
    {
        int statusCode = 0;
        try {
            HttpURLConnection con = (HttpURLConnection)new URL(tokenEndpoint + "?code=" + code + "&grant_type=authorization_code").openConnection();
            con.setRequestMethod("GET");
            statusCode = con.getResponseCode();
	
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer result = new StringBuffer();
 
            while ((inputLine = in.readLine()) != null) {
		result.append(inputLine);
            }
            in.close();
 
            String resultStr = result.toString();
            accessToken = extractJsonValue(resultStr, "access_token");
            refreshToken = extractJsonValue(resultStr, "refresh_token");
            
            saveToken(response);
        }
        catch (Exception ex)
        {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return accessToken;
    }

    public String retreiveAccessToken(String login, String password, HttpServletResponse response) throws MailUpException
    {
        int statusCode = 0;
        try
        {
            HttpURLConnection con = (HttpURLConnection)new URL(authorizationEndpoint + "?client_id=" + clientId + "&client_secret=" + clientSecret + "&response_type=code" +
                "&username=" + login + "&password=" + password).openConnection();
            con.setRequestMethod("GET");
            statusCode = con.getResponseCode();
	
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer result = new StringBuffer();
 
            while ((inputLine = in.readLine()) != null) {
		result.append(inputLine);
            }
            in.close();
 
            String resultStr = result.toString();

            String code = extractJsonValue(resultStr, "code");

            retreiveAccessToken(code, response);
        }
        catch (Exception ex)
        {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return accessToken;
    }

    public String refreshAccessToken(HttpServletResponse response) throws MailUpException
    {
        int statusCode = 0;
        try
        {
            HttpURLConnection con = (HttpURLConnection)new URL(tokenEndpoint).openConnection();
            con.setRequestMethod("POST");

            String body = "client_id=" + clientId + "&client_secret=" + clientSecret +
                "&refresh_token=" + refreshToken + "&grant_type=refresh_token";
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            con.setRequestProperty("Content-Length", ""+body.length());
            
            con.setDoOutput(true);
            DataOutputStream wr = new DataOutputStream(con.getOutputStream());
            wr.writeBytes(body);
            wr.flush();
            wr.close();
            
            statusCode = con.getResponseCode();
            
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer result = new StringBuffer();
 
            while ((inputLine = in.readLine()) != null) {
		result.append(inputLine);
            }
            in.close();
 
            String resultStr = result.toString();
            accessToken = extractJsonValue(resultStr, "access_token");
            refreshToken = extractJsonValue(resultStr, "refresh_token");
            
            saveToken(response);
        }
        catch (Exception ex)
        {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return accessToken;
    }

    public String callMethod(String url, String verb, String body, String contentType, HttpServletResponse response) throws MailUpException
    {
        return callMethod(url, verb, body, contentType, true, response);
    }

    private String callMethod(String url, String verb, String body, String contentType, boolean refresh, HttpServletResponse response) throws MailUpException
    {
        String resultStr = "";
        HttpURLConnection con = null;
        int statusCode = 0;
        try
        {
            con = (HttpURLConnection)new URL(url).openConnection();
            con.setRequestMethod(verb);
            con.setRequestProperty("Content-Type", contentType);
            //con.setRequestProperty("Content-Length", "0");
            con.setRequestProperty("Accept", contentType);
            con.setRequestProperty("Authorization", "Bearer " + accessToken);
            
            if (body != null && !"".equals(body)) {
                //con.setRequestProperty("Content-Length", ""+body.length());
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
        }
        catch (IOException iex)
        {
            try
            {
                statusCode = con.getResponseCode();
                if (statusCode == 401 && refresh) {
                    refreshAccessToken(response);
                    return callMethod(url, verb, body, contentType, false, response);
                } else throw new MailUpException(statusCode, iex.getMessage());
            }
            catch (Exception ex)
            {
                throw new MailUpException(statusCode, ex.getMessage());
            } 
        }
        catch (Exception ex)
        {
            throw new MailUpException(statusCode, ex.getMessage());
        }
        return resultStr;
    }

    private String extractJsonValue(String json, String name)
    {
        String delim = "\"" + name + "\":\"";
        int start = json.indexOf(delim) + delim.length();
        int end = json.indexOf("\"", start + 1);
        if (end > start && start > -1 && end > -1) return json.substring(start, end);
        else return "";
    }

    public void loadToken(HttpServletRequest request)
    {
        Cookie[] cookies = request.getCookies();
        if(cookies != null) {
            for (int i = 0; i < cookies.length; i++){
                Cookie cookie = cookies[i];
                if ("access_token".equals(cookie.getName())) accessToken = cookie.getValue();
                if ("refresh_token".equals(cookie.getName())) refreshToken = cookie.getValue();
            }
        }
    }

    public void saveToken(HttpServletResponse response)
    {
        Cookie cookieAccess = new Cookie("access_token", accessToken);
        Cookie cookieRefresh = new Cookie("refresh_token", refreshToken);

        cookieAccess.setMaxAge(60*60*24); 
        cookieRefresh.setMaxAge(60*60*24); 

        response.addCookie(cookieAccess);
        response.addCookie(cookieRefresh);
    }
}
