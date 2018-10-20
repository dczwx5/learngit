/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/10/19.
 */
package QFLib.Graphics.FX.effectsystem.keyFrame
{
    import QFLib.Math.CVector2;

    public class Vector2DKey
    {
        public static const originalVector2D : CVector2 = CVector2.one();

        public var time : Number = 0.0;
        public var vector2D : CVector2 = new CVector2 ( 1.0, 1.0 );

        public static function addVector2DKey ( vecs : Vector.<Vector2DKey>, time : Number, vec : CVector2 ) : void
        {
            var i : int = 0;
            var n : int = vecs.length;
            for ( ; i < n; ++i )
            {
                if ( vecs[ i ].time > time )
                    break;
            }

            var key : Vector2DKey = new Vector2DKey ();
            key.time = time;
            key.vector2D.set ( vec );

            vecs.fixed = false;
            if ( i == n )
                vecs[ n ] = key;
            else
                vecs.splice ( i, 0, key );
            vecs.fixed = true;
        }

        public static function getVector2D ( vecs : Vector.<Vector2DKey>, time : Number ) : CVector2
        {
            //var tempVec = _tempHelper;
            if ( vecs.length == 0 )
                return Vector2DKey.originalVector2D;

            for ( var i : int = 0, n : int = vecs.length; i < n; ++i )
            {
                if ( vecs[ i ].time > time )
                {
                    break;
                }
            }

            if ( i == 0 )
                return vecs[ 0 ].vector2D;
            else if ( i == n )
                return vecs[ n - 1 ].vector2D;
            else
            {
                var f : Number = (time - vecs[ i - 1 ].time) / (vecs[ i ].time - vecs[ i - 1 ].time);
                return CVector2.lerp ( vecs[ i - 1 ].vector2D, vecs[ i ].vector2D, f );
            }
        }

        public static function keysLoadFromJson(datas:Array, resultVecKeys:Vector.<Vector2DKey>):Vector.<Vector2DKey>
        {
            if(resultVecKeys == null)resultVecKeys = new Vector.<Vector2DKey>();
            var key : Vector2DKey;
            resultVecKeys.fixed = false;
            resultVecKeys.length = 0;
            for ( var i : int = 0, n : int = datas.length; i < n; ++i )
            {
                key = new Vector2DKey ();
                key.time = datas[ i ].time;
                key.vector2D.x = datas[ i ].vector.x;
                key.vector2D.y = datas[ i ].vector.y;
                resultVecKeys[ resultVecKeys.length ] = key;
            }
            resultVecKeys.fixed = true;
            return resultVecKeys;
        }
    }
}
