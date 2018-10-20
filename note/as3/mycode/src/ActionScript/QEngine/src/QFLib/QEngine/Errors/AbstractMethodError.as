/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Errors
{
    /** An AbstractMethodError is thrown when you attempt to call an abstract method. */
    public class AbstractMethodError extends Error
    {
        /** Creates a new AbstractMethodError object. */
        public function AbstractMethodError( message : * = "Method needs to be implemented in subclass", id : * = 0 )
        {
            super( message, id );
        }
    }
}