/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Errors
{
    /** A MissingContextError is thrown when a Context3D object is required but not (yet)
     *  available. */
    public class MissingContextError extends Error
    {
        /** Creates a new MissingContextError object. */
        public function MissingContextError( message : * = "Starling context is missing", id : * = 0 )
        {
            super( message, id );
        }
    }
}