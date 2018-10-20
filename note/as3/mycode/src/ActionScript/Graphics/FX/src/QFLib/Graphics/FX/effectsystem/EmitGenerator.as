package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Math.CVector2;
    import QFLib.Utils.Random;

    public class EmitGenerator
    {
        private static var funcGenerators : Vector.<Function>;
        private static var instance:EmitGenerator = new EmitGenerator();

        public static function genPosition ( type : int, range : CVector2, scaler : CVector2, result : CVector2 ) : CVector2
        {
            if ( type >= 0 && type < funcGenerators.length )
                return funcGenerators[ type ] ( range, scaler, result );
            else
                throw new RangeError ();

            result.setValueXY ( 0.0, 0.0 );
            return result;
        }

        private static function boxGenerator ( range : CVector2, scaler : CVector2, result : CVector2 ) : CVector2
        {
            result.setValueXY ( Random.seed11 * scaler.x, Random.seed11 * scaler.y );
            return result;
        }

        private static function circleGenerator ( range : CVector2, scaler : CVector2, result : CVector2 ) : CVector2
        {
            var radian : Number = Random.range ( range.x, range.y );
            result.x = Math.cos ( radian ) * Random.seed01 * scaler.x;
            result.y = Math.sin ( radian ) * Random.seed01 * scaler.y;
            return result;
        }

        private static function ringGenerator ( range : CVector2, scaler : CVector2, result : CVector2 ) : CVector2
        {
            var radian : Number = Random.range ( range.x, range.y );
            result.x = Math.cos ( radian ) * scaler.x;
            result.y = Math.sin ( radian ) * scaler.y;
            return result;
        }

        public function EmitGenerator ()
        {
            if ( funcGenerators == null )
            {
                funcGenerators = new Vector.<Function> ( EffectSystem.EMITTER_TYPE_COUNT );
                funcGenerators[ EffectSystem.BOX ] = boxGenerator;
                funcGenerators[ EffectSystem.CIRCLE ] = circleGenerator;
                funcGenerators[ EffectSystem.RING ] = ringGenerator;
            }
        }
    }
}