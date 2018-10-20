//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/6/6.
 */
package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.starling.filters.BlurEffect;
    import QFLib.Graphics.RenderCore.starling.filters.FilterEffect;
    import QFLib.Graphics.RenderCore.starling.filters.ObjectFilter;
    import QFLib.Graphics.RenderCore.starling.filters.OutlineEffect;
    import QFLib.Interface.IDisposable;

    public class OutlineModifier extends BaseModifier implements IDisposable
    {
        public function OutlineModifier ()
        {
            super ();
        }

        override public function dispose () : void
        {
            super.dispose ();

            _color.length = 0;
            _color = null;
        }

        override protected virtual function _loadFromObject ( url : String, data : Object ) : void
        {
            if ( checkObject ( data, "outline") )
            {
                var node : Object = data[ "outline" ];
                if ( checkObject ( node, "color" ) )
                    parseColorFromVector ( _color, node.color );

                if ( checkObject ( node, "size" ) )
                    _size = node.size;

                if ( node.hasOwnProperty ( "outlineType") )
                    _outlineType = node.outlineType;
                else
                    _outlineType = 0;//solid outline

                if ( _effects != null )
                    setColorAndSize ();
            }
        }

        override public function attachToTarget ( target : IFXModify ) : void
        {
            super.attachToTarget ( target );
            setOutline ();
        }

        override public function get isDead () : Boolean
        {
            if ( _loop && _currentLife > _life )
            {
                _reset ();
            }

            return _currentLife > _life;
        }

        override protected virtual function _reset () : void
        {
            _currentLife = 0.0;
            if ( _effects != null )
                setOutline ( false );
            _effects = null;
        }

        override public function update ( deltaTime : Number ) : void
        {
            _currentLife += deltaTime;
            if ( _effects == null )
                setOutline ( true );
        }

        private function setOutline ( bEnable : Boolean = true ) : void
        {
            if ( _theTarget != null && _theTarget.theObject != null )
            {
                var outlineType : String = _outlineType == 0 ? ObjectFilter.SolidOutline : ObjectFilter.RimLightOutline;
                _effects = _theTarget.theObject.setFilter ( _theTarget.renderableObject, outlineType, bEnable );
                if ( _effects == null ) return;
                setColorAndSize ( );
            }
        }

        private function parseColorFromVector ( vec : Vector.<Number>, data : Object ) : void
        {
            vec[ 0 ] = data.r;
            vec[ 1 ] = data.g;
            vec[ 2 ] = data.b;
            vec[ 3 ] = data.a;
        }

        private function setColorAndSize () : void
        {
            if ( _outlineType == 0 )            //solid outline
            {
                var outlineEffect : OutlineEffect = _effects[ 0 ] as OutlineEffect;
                if ( outlineEffect.enable )
                {
                    outlineEffect.setOutlineColor ( _color );
                    outlineEffect.setOutlineSize ( _size );
                }
            }
            else                                //rim light outline
            {
                var blurEffect : BlurEffect = _effects[ 0 ] as BlurEffect;
                if ( blurEffect.enable )
                {
                    blurEffect.setGlowColor ( _color[ 0 ], _color[ 1 ], _color[ 2 ] );
                    blurEffect.setGlowSize ( _size );
                }

                blurEffect = _effects[ 1 ] as BlurEffect;
                if ( blurEffect.enable )
                {
                    blurEffect.setGlowColor ( _color[ 0 ], _color[ 1 ], _color[ 2 ] );
                    blurEffect.setGlowSize ( _size );
                }
            }
        }

        private var _effects : Vector.<FilterEffect> = null;

        private var _color : Vector.<Number> = Vector.<Number> ( [ 1.0, 1.0, 1.0, 1.0 ] );
        private var _size : Number = 1.0;
        private var _outlineType : int = 0;  //0--solidOutline 1--rimLightOutline
        private var _currentLife : Number = 0.0;
    }
}
