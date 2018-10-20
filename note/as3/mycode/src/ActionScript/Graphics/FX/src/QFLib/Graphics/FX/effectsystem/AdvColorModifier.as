//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by David on 2016/10/12.
 */
package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.render.pass.PAdvColorModify;

    public class AdvColorModifier extends BaseModifier
    {
        private var _passAdvColorModify : PAdvColorModify = null;

        private var _fadeStartColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _fadeMidColor1 : Vector.<Number> = new Vector.<Number>( 4 );
        private var _fadeMidColor2 : Vector.<Number> = new Vector.<Number>( 4 );
        private var _fadeEndColor : Vector.<Number> = new Vector.<Number>( 4 );

        private var _thresoldFadeSum : Vector.<Number> = new Vector.<Number>( 4 );

        private var _fadeVelocity : Number = 1.0;
        private var _currentLife : Number = 0.0;

        private var _isPassAdded : Boolean = false;

        public function AdvColorModifier()
        {
        }

        public override function dispose() : void
        {
            _passAdvColorModify = null;

            _fadeStartColor.length = 0;
            _fadeMidColor1.length = 0;
            _fadeMidColor2.length = 0;
            _fadeEndColor.length = 0;

            _thresoldFadeSum.length = 0;

            _fadeEndColor = null;
            _fadeMidColor1 = null;
            _fadeMidColor2 = null;
            _fadeStartColor = null;

            _thresoldFadeSum = null;

            super.dispose();
        }

        public override function attachToTarget( target : IFXModify ) : void
        {
            super.attachToTarget( target );
            if ( target != null && !_isPassAdded )
            {
                addPass();
            }
        }

        public override function get isDead() : Boolean
        {
            if ( _loop && _currentLife > _life )
            {
                _reset();
            }

            return _currentLife > _life;
        }

        protected override function _reset() : void
        {
            _currentLife = 0.0;
            _isPassAdded = false;
            _passAdvColorModify = null;
            if ( _theTarget != null && _theTarget.material != null )
            {
                _theTarget.material.reset ();
            }
        }

        protected override function _update( delta : Number ) : void
        {
            _currentLife += delta;

            if ( _theTarget == null ) return;
            addPass();
            _thresoldFadeSum[ 3 ] += _fadeVelocity;

            if ( _passAdvColorModify != null )
            {
                if ( !_passAdvColorModify.enable ) _passAdvColorModify.enable = true;
                (_passAdvColorModify as PAdvColorModify).setThresold( _thresoldFadeSum );
            }
        }

        protected override function _loadFromObject( url : String, data : Object ) : void
        {
            if ( checkObject( data, "advColorTransform" ) )
            {
                var node : Object = data[ "advColorTransform" ];

                //set color
                if ( checkObject( node, "fadeStartColor" ) )
                    parseColorFromData( _fadeStartColor, node.fadeStartColor );

                if ( checkObject( node, "fadeMidColor1" ) )
                    parseColorFromData( _fadeMidColor1, node.fadeMidColor1 );

                if ( checkObject( node, "fadeMidColor2" ) )
                    parseColorFromData( _fadeMidColor2, node.fadeMidColor2 );

                if ( checkObject( node, "fadeEndColor" ) )
                    parseColorFromData( _fadeEndColor, node.fadeEndColor );

                //set thresold
                if ( checkObject( node, "thresoldStart" ) )
                    _thresoldFadeSum[ 0 ] = node.thresoldStart;

                if ( checkObject( node, "thresoldMid" ) )
                    _thresoldFadeSum[ 1 ] = node.thresoldMid;

                if ( checkObject( node, "thresoldEnd" ) )
                    _thresoldFadeSum[ 2 ] = node.thresoldEnd;

                //set velocity
                if ( checkObject( node, "fadeVelocity" ) )
                    _fadeVelocity = node.fadeVelocity;
            }
        }

        private function parseColorFromData( color : Vector.<Number>, data : Object ) : void
        {
            color[ 0 ] = data.r;
            color[ 1 ] = data.g;
            color[ 2 ] = data.b;
            color[ 3 ] = data.a;
        }

        private function addPass() : void
        {
            if ( !_isPassAdded && _theTarget.material != null )
            {
                _passAdvColorModify = _theTarget.material.addPass( PAdvColorModify.sName, PAdvColorModify, true, true )
                        as PAdvColorModify;
                _passAdvColorModify.setFadeStartColor( _fadeStartColor );
                _passAdvColorModify.setFadeMidColor1( _fadeMidColor1 );
                _passAdvColorModify.setFadeMidColor2( _fadeMidColor2 );
                _passAdvColorModify.setFadeEndColor( _fadeEndColor );
                _passAdvColorModify.setThresold( _thresoldFadeSum );

                _isPassAdded = true;
            }
        }
    }
}
