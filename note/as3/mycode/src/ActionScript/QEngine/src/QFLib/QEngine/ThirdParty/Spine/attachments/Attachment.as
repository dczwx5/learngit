/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{

    public class Attachment
    {
        public function Attachment( name : String )
        {
            if( name == null )
                throw new ArgumentError( "name cannot be null." );
            _name = name;
        }

        internal var _name : String;

        public function get name() : String
        {
            return _name;
        }

        public function toString() : String
        {
            return name;
        }
    }

}
