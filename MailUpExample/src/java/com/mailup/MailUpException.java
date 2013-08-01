/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mailup;

/**
 *
 * @author sergeiinyushkin
 */
public class MailUpException extends Exception {
    private int statusCode;

    /**
     * @return the statusCode
     */
    public int getStatusCode() {
        return statusCode;
    }

    /**
     * @param statusCode the statusCode to set
     */
    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }
    

    public MailUpException(int statusCode, String message)
    {
        super(message);
        setStatusCode(statusCode);
    }
}
