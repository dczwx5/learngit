//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/8/29
//----------------------------------------------------------------------------------------------------------------------

/*
    this class can be used to arrange the tasks / functions for a host object
*/

package QFLib.Framework
{

    import QFLib.Foundation.CProcedureManager;
    import QFLib.Graphics.Sprite.CSprite;
    import QFLib.Graphics.Sprite.CSpriteText;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector3;

    //
    //
    //
    public class CTweener extends CProcedureManager
    {
        public function CTweener( theHost : Object, fnTaskFinished : Function = null )
        {
            super( 0.0 );

            m_theHost = theHost;
            m_fnTaskFinished = fnTaskFinished;
        }
        
        public override function dispose() : void
        {
            super.dispose();
            m_theHost = null;
            m_fnTaskFinished = null;
        }

        [Inline]
        final public function get host() : Object
        {
            return m_theHost;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            super.update( fDeltaTime );

            if( m_vectProcedureInfos.length == 0 )
            {
                if( m_fnTaskFinished != null ) m_fnTaskFinished( this );
            }
        }

        protected override function _procedureCall( fnProcedure : Function, theProcedureTags : Object ) : Object
        {
            return fnProcedure( m_theHost, theProcedureTags );
        }


        //
        // arguments: fBeginTime : Number, fEndTime : Number, fPosX : Number, fPosY : Number, fPosZ : Number
        //
        public static function moveToXYZ( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            if( theHost.hasOwnProperty( "position" ) == false || theHost.hasOwnProperty( "setPosition" ) == false || ( theHost.setPosition is Function == false ) )
            {
                return false;
            }

            var fCurrentTime : Number = 0.0;
            var fBeginTime : Number  = theProcedureTags.arguments[ 0 ];
            var fEndTime : Number  = theProcedureTags.arguments[ 1 ];
            var fPosX : Number = theProcedureTags.arguments[ 2 ];
            var fPosY : Number = theProcedureTags.arguments[ 3 ];
            var fPosZ : Number = theProcedureTags.arguments[ 4 ];

            var vCurrentPos : CVector3;
            var fDisX : Number;
            var fDisY : Number;
            var fDisZ : Number;

            var bStarted : Boolean = false;
            theProcedureTags.run = function( fDeltaTime : Number ) : Boolean
            {
                if( theHost.hasOwnProperty( "disposed" ) )
                {
                    if( theHost.disposed ) return true;
                }

                fCurrentTime += fDeltaTime;
                if( fCurrentTime < fBeginTime ) return false;
                else if( bStarted == false )
                {
                    vCurrentPos = theHost.position;
                    vCurrentPos = new CVector3( vCurrentPos.x, vCurrentPos.y, vCurrentPos.z );
                    fDisX = fPosX - vCurrentPos.x;
                    fDisY = fPosY - vCurrentPos.y;
                    fDisZ = fPosZ - vCurrentPos.z;
                    bStarted = true;
                }

                var fRatio : Number = ( fCurrentTime - fBeginTime ) / ( fEndTime - fBeginTime );
                if( fRatio < 0.0 ) fRatio = 0.0;
                else if( fRatio > 1.0 ) fRatio = 1.0;

                theHost.setPosition( vCurrentPos.x + fDisX * fRatio, vCurrentPos.y + fDisY * fRatio, vCurrentPos.z + fDisZ * fRatio );

                if( fCurrentTime >= fEndTime ) return true;
                else return false;
            };

            return true;
        }

        //
        // arguments: fBeginTime : Number, fEndTime : Number, fPosX : Number, fPosY : Number, fPosZ : Number, bApplySin : Boolean
        //
        public static function scaleToXYZ( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            if( theHost.hasOwnProperty( "scale" ) == false || theHost.hasOwnProperty( "setScale" ) == false || ( theHost.setScale is Function == false ) )
            {
                return false;
            }

            var fCurrentTime : Number = 0.0;
            var fBeginTime : Number  = theProcedureTags.arguments[ 0 ];
            var fEndTime : Number  = theProcedureTags.arguments[ 1 ];
            var fScaleX : Number = theProcedureTags.arguments[ 2 ];
            var fScaleY : Number = theProcedureTags.arguments[ 3 ];
            var fScaleZ : Number = theProcedureTags.arguments[ 4 ];
            var bApplySin : Boolean = theProcedureTags.arguments[ 5 ];

            var vCurrentScale : CVector3;
            var fDisX : Number;
            var fDisY : Number;
            var fDisZ : Number;

            var bStarted : Boolean = false;
            theProcedureTags.run = function( fDeltaTime : Number ) : Boolean
            {
                if( theHost.hasOwnProperty( "disposed" ) )
                {
                    if( theHost.disposed ) return true;
                }

                fCurrentTime += fDeltaTime;
                if( fCurrentTime < fBeginTime ) return false;
                else if( bStarted == false )
                {
                    vCurrentScale = theHost.scale;
                    vCurrentScale = new CVector3( vCurrentScale.x, vCurrentScale.y, vCurrentScale.z );
                    fDisX = fScaleX - vCurrentScale.x;
                    fDisY = fScaleY - vCurrentScale.y;
                    fDisZ = fScaleZ - vCurrentScale.z;
                    bStarted = true;
                }

                var fRatio : Number = ( fCurrentTime - fBeginTime ) / ( fEndTime - fBeginTime );
                if( bApplySin ) fRatio = CMath.sinDeg( fRatio * 90.0 );

                if( fRatio < 0.0 ) fRatio = 0.0;
                else if( fRatio > 1.0 ) fRatio = 1.0;

                theHost.setScale( vCurrentScale.x + fDisX * fRatio, vCurrentScale.y + fDisY * fRatio, vCurrentScale.z + fDisZ * fRatio );

                if( fCurrentTime >= fEndTime ) return true;
                else return false;
            };

            return true;
        }

        //
        // arguments: fBeginTime : Number, fEndTime : Number, fFinalOpaque : Number
        //
        public static function opaqueTo( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            if( theHost.hasOwnProperty( "opaque" ) == false )
            {
                return false;
            }

            var fCurrentTime : Number = 0.0;
            var fBeginTime : Number  = theProcedureTags.arguments[ 0 ];
            var fEndTime : Number  = theProcedureTags.arguments[ 1 ];
            var fFinalOpaque : Number = theProcedureTags.arguments[ 2 ];

            var fCurrentOpaque : Number;
            var fDisOpaque : Number;

            var bStarted : Boolean = false;
            theProcedureTags.run = function( fDeltaTime : Number ) : Boolean
            {
                if( theHost.hasOwnProperty( "disposed" ) )
                {
                    if( theHost.disposed ) return true;
                }

                fCurrentTime += fDeltaTime;
                if( fCurrentTime < fBeginTime ) return false;
                else if( bStarted == false )
                {
                    fCurrentOpaque = theHost.opaque;
                    fDisOpaque = fFinalOpaque - fCurrentOpaque;
                    bStarted = true;
                }

                var fRatio : Number = ( fCurrentTime - fBeginTime ) / ( fEndTime - fBeginTime );
                if( fRatio < 0.0 ) fRatio = 0.0;
                else if( fRatio > 1.0 ) fRatio = 1.0;

                theHost.opaque = fCurrentOpaque + fDisOpaque * fRatio;

                if( fCurrentTime >= fEndTime ) return true;
                else return false;
            };

            return true;
        }

        //
        // arguments: fBeginTime : Number, fEndTime : Number, fFinalOpaque : Number
        //
        public static function innerOpaqueTo( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            if( theHost.hasOwnProperty( "innerOpaque" ) == false )
            {
                return false;
            }

            var fCurrentTime : Number = 0.0;
            var fBeginTime : Number  = theProcedureTags.arguments[ 0 ];
            var fEndTime : Number  = theProcedureTags.arguments[ 1 ];
            var fFinalOpaque : Number = theProcedureTags.arguments[ 2 ];

            var fCurrentOpaque : Number;
            var fDisOpaque : Number;

            var bStarted : Boolean = false;
            theProcedureTags.run = function( fDeltaTime : Number ) : Boolean
            {
                if( theHost.hasOwnProperty( "disposed" ) )
                {
                    if( theHost.disposed ) return true;
                }

                fCurrentTime += fDeltaTime;
                if( fCurrentTime < fBeginTime ) return false;
                else if( bStarted == false )
                {
                    fCurrentOpaque = theHost.innerOpaque;
                    fDisOpaque = fFinalOpaque - fCurrentOpaque;
                    bStarted = true;
                }

                var fRatio : Number = ( fCurrentTime - fBeginTime ) / ( fEndTime - fBeginTime );
                if( fRatio < 0.0 ) fRatio = 0.0;
                else if( fRatio > 1.0 ) fRatio = 1.0;

                theHost.innerOpaque = fCurrentOpaque + fDisOpaque * fRatio;

                if( fCurrentTime >= fEndTime ) return true;
                else return false;
            };

            return true;
        }

        //
        // arguments: recycle pool name : String(if it is a sprite text)
        //
        public static function recycleObject( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            var bRecycled : Boolean = false;

            if( theHost is CSpriteText )
            {
                var sRecyclePoolName : String  = theProcedureTags.arguments[ 0 ];

                var spText : CSpriteText = theHost as CSpriteText;
                if( !spText.isRecycled())
                    spText.spriteSystemRef.recycleSpriteToPool( sRecyclePoolName, spText );
                bRecycled = true;
            }
            else if( theHost is CSprite )
            {
                var sp : CSprite = theHost as CSprite;
                if( sp.filename != null && sp.filename.length > 0 )
                {
                    sp.spriteSystemRef.recycleSpriteToPool( sp.filename, sp );
                    bRecycled = true;
                }
            }

            if( bRecycled == false )
            {
                if( theHost.hasOwnProperty( "dispose" ) && theHost.dispose is Function ) theHost.dispose();
            }
            return true;
        }

        //
        // arguments: none
        //
        public static function disposeObject( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            if( theHost.hasOwnProperty( "dispose" ) && theHost.dispose is Function ) theHost.dispose();
            return true;
        }

        //
        // arguments: fnOnCallback : Function( theHost : Object ) : void
        //
        public static function funCallObject( theHost : Object, theProcedureTags : Object ) : Boolean
        {
            var fnCallback : Function  = theProcedureTags.arguments[ 0 ];
            if( fnCallback != null ) fnCallback( theHost );

            return true;
        }

        //
        //
        private var m_theHost : Object;
        private var m_fnTaskFinished : Function = null;

    }

}

