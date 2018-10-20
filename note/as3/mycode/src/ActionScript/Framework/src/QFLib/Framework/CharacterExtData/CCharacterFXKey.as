//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/7/4.
 */
package QFLib.Framework.CharacterExtData
{
    import QFLib.Foundation;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector3;

    public class CCharacterFXKey
    {
        public static const ONETIME_T_LOOP:int = 0;
        public static const FOLLOW_T:int = 1;
        public static const FOLLOW_TRS:int = 2;              //all attached(position, rotation, scale etc.)
        public static const ONETIME_T:int = 3;
        public static const FOLLOW_T_ANIMATIONLOOP:int = 4; // (跟随)动作循环时在第N个循环上插入特效,可插入多个，例如雅典娜大招
        public static const ONETIME_T_ANIMATIONLOOP:int = 5; // (不跟随)动作循环时在第N个循环上插入特效,可插入多个，例如雅典娜大招

        public static const NORMAL_FX : String = "normal";
        public static const COMBINE_FX : String = "combine";
        public static const BUFF_FX : String = "buff";

        public var localPosition:CVector3 = new CVector3();
        public var localScale:CVector3 = new CVector3( 1.0, 1.0, 1.0 );
        public var localRotation:CVector3 = new CVector3();

        public var fxURL:String = null;
        public var boneName:String = null;
        public var keyTime:Number = 0.0;
        public var loopTimes:int = 0;
        public var playTime:Number = -1.0;
        public var boneIndex:int = -1;
        public var fadeWithAnimation:Boolean = false;

        public var playOneTime : Boolean = false;               //just play one time when it created
        public var playNewPerAnimationLoop : Boolean = false;      //when animation is looping, create fx and play in per looping cycle of animation
        public var playFollowAnimationLoop : Boolean = false;   //whether fx should play follow the animation looping
        public var playFollowTRS : Boolean = false;             //follow the animation's position/scale/rotation
        public var playInAnimationOneLoopTimes : Boolean = false;  //when the animation's looptimes is N, then play the fx

        public var fxType : String = NORMAL_FX;
        public var buffName : String = null;                     //for combine or buff effect

        public function CCharacterFXKey ()
        { }

        public function dispose():void
        {
            localPosition = null;
            localRotation = null;
            localScale = null;
            boneName = null;
            fxType = null;
            buffName = null;
            fxURL = null;
        }

        public function loadFromData(data:Object):void
        {
            if(checkObject(data, "attachtype"))
            {
                var type : int = data.attachtype;

                switch ( type )
                {
                    case ONETIME_T_LOOP:
                        playOneTime = true;
                        playNewPerAnimationLoop = true;
                        playFollowAnimationLoop = false;
                        playFollowTRS = false;
                        playInAnimationOneLoopTimes = false;
                        break;
                    case FOLLOW_T:
                    case FOLLOW_TRS:
                        playOneTime = false;
                        playNewPerAnimationLoop = false;
                        playFollowAnimationLoop = true;
                        playFollowTRS = true;
                        playInAnimationOneLoopTimes = false;
                        break;
                    case ONETIME_T:
                        playOneTime = true;
                        playNewPerAnimationLoop = false;
                        playFollowAnimationLoop = false;
                        playFollowTRS = false;
                        playInAnimationOneLoopTimes = false;
                        break;
                    case FOLLOW_T_ANIMATIONLOOP:
                        playOneTime = true;//只播一次，跟随位置
                        playNewPerAnimationLoop = false;
                        playFollowAnimationLoop = false;
                        playFollowTRS = true;
                        playInAnimationOneLoopTimes = true;
                        break;
                    case ONETIME_T_ANIMATIONLOOP:
                        playOneTime = true;//只播一次，不跟随位置
                        playNewPerAnimationLoop = false;
                        playFollowAnimationLoop = false;
                        playFollowTRS = false;
                        playInAnimationOneLoopTimes = true;
                        break;
                    default:
                        Foundation.Log.logErrorMsg( "There were not attch type " + data.attachType + "!" );
                        break;
                }
            }

            if(checkObject(data, "localPosition"))
            {
                localPosition.x = data.localPosition.x;
                localPosition.y = data.localPosition.y;
                localPosition.z = data.localPosition.z;

                if( localPosition.z > 500 )
                    localPosition.z = -500;
                else if( localPosition.z < -500 )
                    localPosition.z = 500;
                else
                {
                    if ( localPosition.z > 0 && localPosition.z < 10 ) localPosition.z = -10;
                    else if ( localPosition.z <= 0 && localPosition.z > -10 ) localPosition.z = 10;
                    else localPosition.z *= -1;
                }
            }

            if(checkObject(data, "localScale"))
            {
                localScale.x = data.localScale.x;
                localScale.y = data.localScale.y;
                localScale.z = data.localScale.z;
            }

            if(checkObject(data, "localRotation"))
            {
                var deg2Rad:Number = Math.PI / 180.0;
                localRotation.x = data.localRotation.x * deg2Rad;
                localRotation.y = data.localRotation.y * deg2Rad;
                localRotation.z = data.localRotation.z * deg2Rad;
            }
        }

        private static function checkObject(node:Object, name:String):Boolean
        {
            if (node.hasOwnProperty(name))
            {
                return true;
            }
            else
            {
                throw new CCharacterFXKeyError(name);
            }
        }
    }
}

class CCharacterFXKeyError extends ArgumentError
{
    public function CCharacterFXKeyError(nodeName:String, id:* = 0)
    {
        super("there is no [" + nodeName + "] node.", id);
    }
}
