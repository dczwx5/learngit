//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/6/18
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Utils
{
    import flash.system.Capabilities;

    public class CFlashVersion
    {
        public static function getVersionNumber() : Vector.<int>
        {
            if( s_vVersionNumber == null )
            {
                var sVersionInfo : String = Capabilities.version;
                var sVersionNum : String = sVersionInfo.split( " " )[ 1 ];
                var aVersionNum : Array = sVersionNum.split( "," );

                s_vVersionNumber = new Vector.<int>();
                for each( var v : Object in aVersionNum )
                {
                    s_vVersionNumber.push( int( v ) );
                }
            }

            return s_vVersionNumber;
        }

        public static function getPlayerVersion() : String
        {
            if( s_sFlashPlayerVersion == null )
            {
                var vVersion : Vector.<int> = getVersionNumber();
                s_sFlashPlayerVersion = vVersion[ 0 ] + "." + vVersion[ 1 ] + ( isDebugPlayer() ? "-debug" : "-release" );
            }

            return s_sFlashPlayerVersion;
        }

        public static function isPlayerVersionPriorTo( iMajorVersion : int, iMinorVersion : int ):Boolean
        {
            var vVersion : Vector.<int> = getVersionNumber();

            if( vVersion[ 0 ] < iMajorVersion ) return true;
            else if( vVersion[ 0 ] > iMajorVersion ) return false;
            else
            {
                if( vVersion[ 1 ] < iMinorVersion ) return true;
                else if( vVersion[ 1 ] > iMinorVersion ) return false;
                else return false;
            }
        }

        public static function isPlayerVersionPriorOrEqualTo( iMajorVersion : int, iMinorVersion : int ):Boolean
        {
            var vVersion : Vector.<int> = getVersionNumber();

            if( vVersion[ 0 ] < iMajorVersion ) return true;
            else if( vVersion[ 0 ] > iMajorVersion ) return false;
            else
            {
                if( vVersion[ 1 ] < iMinorVersion ) return true;
                else if( vVersion[ 1 ] > iMinorVersion ) return false;
                else return true;
            }
        }

        public static function isDebugPlayer() : Boolean
        {
            return Capabilities.isDebugger;
        }

        public static function isDebugBuild() : Boolean
        {
            if( s_bDebugBuildChecked == false )
            {
                var sStackTrace : String = new Error().getStackTrace();
                s_bDebugBuild = ( sStackTrace && sStackTrace.search( /:[0-9]+]$/m) > -1 );

                s_bDebugBuildChecked = true;
            }

            return s_bDebugBuild;
        }

        public static function isSandboxPlayer() : Boolean {
            return !isDesktop() && !isStandAlone();
        }

        public static function isDesktop() : Boolean {
            return Capabilities.playerType == 'Desktop';
        }

        public static function isStandAlone() : Boolean {
            return Capabilities.playerType == 'StandAlone';
        }

        //
        //
        private static var s_vVersionNumber : Vector.<int> = null;
        private static var s_sFlashPlayerVersion : String = null;

        private static var s_bDebugBuildChecked : Boolean = false;
        private static var s_bDebugBuild : Boolean = false;

    }
}
