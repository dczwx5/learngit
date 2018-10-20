/**
 * Created by user on 2015/6/17.
 */
package QFLib.Graphics.FX.utils
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class MathUtils
    {
        [Inline]
        public static function lerp ( a : Number, b : Number, f : Number ) : Number
        {
            return a * (1 - f) + b * f;
        }

        [Inline]
        public static function tranBound ( bound : Rectangle, transform : Matrix, resultBound : Rectangle ) : Rectangle
        {
            if ( bound == null )return resultBound;
            if ( resultBound == null )resultBound = new Rectangle ();
            var minX : Number = Number.MAX_VALUE, maxX : Number = -Number.MAX_VALUE;
            var minY : Number = Number.MAX_VALUE, maxY : Number = -Number.MAX_VALUE;
            var point : Point = new Point ();

            caculateMinMax ( bound.x, bound.y );
            caculateMinMax ( bound.right, bound.y );
            caculateMinMax ( bound.right, bound.bottom );
            caculateMinMax ( bound.x, bound.bottom );

            function caculateMinMax ( x : Number, y : Number ) : void
            {
                point.x = x;
                point.y = y;
                point = transform.transformPoint ( point );
                minX = minX < point.x ? minX : point.x;
                maxX = maxX > point.x ? maxX : point.x;
                minY = minY < point.y ? minY : point.y;
                maxY = maxY > point.y ? maxY : point.y;
            }

            resultBound.setTo ( minX, minY, maxX - minX, maxY - minY );
            return resultBound;
        }
    }
}
