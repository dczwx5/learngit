//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/12/20.
 */
package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.render.pass.PTritoneColorModify;

    public class TritoneColorTransform extends BaseModifier
    {
        private var _highLightColor : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _middleColor : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _lowKeyColor : Vector.<Number> = new Vector.<Number> ( 4 );

        private var _passTritone : PTritoneColorModify = null;

        private var _currentLife : Number = 0.0;
        private var _isPassAdded : Boolean = false;

        public function TritoneColorTransform ()
        {
        }

        public override function dispose () : void
        {
            _passTritone = null;

            if ( _highLightColor != null )
            {
                _highLightColor.fixed = false;
                _highLightColor.length = 0;
                _highLightColor = null;
            }
            if ( _middleColor != null )
            {
                _middleColor.fixed = false;
                _middleColor.length = 0;
                _middleColor = null;
            }
            if ( _lowKeyColor != null )
            {
                _lowKeyColor.fixed = false;
                _lowKeyColor.length = 0;
                _lowKeyColor = null;
            }

            super.dispose ();
        }

        public override function attachToTarget ( target : IFXModify ) : void
        {
            super.attachToTarget ( target );
            if ( target != null && !_isPassAdded )
            {
                addPass ();
            }
        }

        public override function get isDead () : Boolean
        {
            if ( _loop && _currentLife > _life )
            {
                _reset ();
            }

            return _currentLife > _life;
        }

        protected override function _reset () : void
        {
            _currentLife = 0.0;
            _isPassAdded = false;
            _passTritone = null;
            if ( _theTarget != null && _theTarget.material != null )
            {
                _theTarget.material.reset();
            }
        }

        protected override function _update ( delta : Number ) : void
        {
            _currentLife += delta;

            if ( _theTarget == null ) return;
            if ( !_isPassAdded ) addPass ();

            if ( _passTritone != null && !_passTritone.enable )
            {
                _passTritone.enable = true;
            }
        }

        protected override function _loadFromObject ( url : String, data : Object ) : void
        {
            if ( checkObject ( data, "tritoneColorTrasform" ) )
            {
                var node : Object = data[ "tritoneColorTrasform" ];

                //set color
                if ( checkObject ( node, "highLightColor" ) )
                    parseColorFromData ( _highLightColor, node.highLightColor );

                if ( checkObject ( node, "middleColor" ) )
                    parseColorFromData ( _middleColor, node.middleColor );

                if ( checkObject ( node, "lowKeyColor" ) )
                    parseColorFromData ( _lowKeyColor, node.lowKeyColor );
            }
        }

        private function parseColorFromData ( color : Vector.<Number>, data : Object ) : void
        {
            color[ 0 ] = data.r;
            color[ 1 ] = data.g;
            color[ 2 ] = data.b;
            color[ 3 ] = data.a;
        }

        private function addPass () : void
        {
            if ( !_isPassAdded && _theTarget.material != null )
            {
                _passTritone = _theTarget.material.addPass( PTritoneColorModify.sName, PTritoneColorModify, true, true )
                        as PTritoneColorModify;

                //set pass val
                _passTritone.highLightColor = _highLightColor;
                _passTritone.middleColor = _middleColor;
                _passTritone.lowKeyColor = _lowKeyColor;

                _isPassAdded = true;
            }
        }
    }
}
