//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by David on 2016/9/18.
 */
package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.effectsystem.keyFrame.KeyFrame;
    import QFLib.Graphics.FX.utils.ColorArgb;

    public class ColorModifier extends BaseModifier
    {
        private var _keyFrame : KeyFrame;
        private var _currentLife : Number = 0.0;
        private var _isMasking : Boolean = false;

        public function ColorModifier ()
        {
            _keyFrame = new KeyFrame ();
        }

        override public function dispose () : void
        {
            _keyFrame.dispose ();
            super.dispose ();
        }

        override public function get isDead () : Boolean
        {
            if ( _loop && _currentLife > _life )
                _reset ();

            return _currentLife > _life;
        }

        override protected function _reset () : void
        {
            _currentLife = 0.0;
            if ( _theTarget != null )
                _theTarget.resetColor ();
        }

        override protected function _update ( delta : Number ) : void
        {
            if ( _theTarget != null )
            {
                _currentLife += delta;
                if ( _currentLife > _life ) return;

                //待优化，暂时性变色方案
                var normalizeLife : Number = _currentLife / _life;
                var color : uint = _keyFrame.getColor ( normalizeLife );
                var rgba : ColorArgb = ColorArgb.fromRgba ( color );

                _theTarget.setColor ( rgba.r / 255.0, rgba.g / 255.0, rgba.b / 255.0, rgba.a / 255, _isMasking );
            }
        }

        override protected function _loadFromObject ( url : String, data : Object ) : void
        {
            if ( checkObject ( data, "colorFrame" ) )
            {
                _keyFrame.clear ();
                _keyFrame.loadFromObject ( data.colorFrame );
            }

            if ( data.hasOwnProperty ( "isMasking" ) )
                _isMasking = data.isMasking;
            else
                _isMasking = false;
        }
    }
}
