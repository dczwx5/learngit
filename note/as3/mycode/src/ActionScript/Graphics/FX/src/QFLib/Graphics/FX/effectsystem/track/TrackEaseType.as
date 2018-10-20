//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/6/20.
 */
package QFLib.Graphics.FX.effectsystem.track {
    import QFLib.Math.CMath;

    public class TrackEaseType {

    public static const LINEAR : int = 0;//线性

    public static const EASE_IN : int = 1;//缓入

    public static const EASE_OUT : int = 2;//缓出

    public static const EASE_INOUT : int = 3;//缓入缓出

    public static function caculateEaseTimeByType( time:Number , easeType : int = TrackEaseType.LINEAR ) : Number
    {
        switch(easeType)
        {
            case TrackEaseType.EASE_IN:
                time = 1 - Math.cos(time * CMath.PIOver2);
                break;
            case TrackEaseType.EASE_OUT:
                time = Math.sin(time * CMath.PIOver2);
                break;
            case TrackEaseType.EASE_INOUT:
                time = Math.PI * time;
                time = -0.5 * (Math.cos(time) - 1.0);
                break;
            case TrackEaseType.LINEAR:
            default:
                break;
        }
        return time;
    }
}
}
