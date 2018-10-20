package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Vector3D;

    public class EffectContainer extends BaseEffectContainer
    {
        private static var sVector3DHeper : Vector3D = new Vector3D();

        private var _effects : Vector.<EffectNode>;

        public function EffectContainer ()
        {
            _effects = new Vector.<EffectNode> ();
            _effects.fixed = true;
        }

        override public function dispose () : void
        {
            for ( var i : int = 0; i < _effects.length; i++ )
            {
                _effects[ i ].dispose ();
                _effects[ i ] = null;
            }

            super.dispose ();
        }

        override public function get assetsSize () : int
        {
            for ( var i : int = 0; i < _effects.length; i++ )
            {
                _assetsSize += _effects[ i ].effect.assetsSize;
            }

            return _assetsSize;
        }

        override public function attachToTarget ( target : IFXModify ) : void
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; ++i )
            {
                _effects[ i ].effect.attachToTarget ( target );
            }
        }

        override public function detachFromTarget () : void
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; ++i )
            {
                _effects[ i ].effect.detachFromTarget ();
            }
        }

        override public function get isDead () : Boolean
        {
            var dead : Boolean = true;
            for ( var i : int = 0, n : int = _effects.length; i < n; ++i )
            {
                if ( !_effects[ i ].effect.isDead )
                    dead = false;
            }

            if ( _loop && dead )
                _reset ();

            return dead;
        }

        override public function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; i++ )
            {
                if ( _effects[ i ] == null || !_effects[ i ].effect.enable ) continue;

                _effects[ i ].effect.setColor ( r, g, b, alpha, masking );
            }
        }

        override public function resetColor () : void
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; i++ )
            {
                if ( _effects[ i ] == null || !_effects[ i ].effect.enable ) continue;

                _effects[ i ].effect.resetColor ();
            }
        }

        override public function get enable () : Boolean
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; i++ )
            {
                if ( _effects[ i ] == null || !_effects[ i ].effect.enable )
                    return false;
            }

            return true;
        }

        override protected function _loadFromJson ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL ) : void
        {
            _effects.fixed = false;
            _effects.length = data.length;
            for ( var i : int = 0, n : int = data.length; i < n; ++i )
            {
                var child : Object = data[ i ];

                if ( _effects[ i ] == null )
                {
                    _effects[ i ] = new EffectNode ();
                }

                checkObject ( child, "effect" );
                var node : EffectNode = _effects[ i ];
                node.effect = EffectSystem.createEffect ( child.effect.type );
                node.effect.loadFromObject ( url, child.effect, iLoadingPriority, _onEffectLoadFunc );

                var baseEffect : BaseEffect = node.effect as BaseEffect;
                if ( baseEffect )
                    baseEffect.isRootEffect = false;

                var object : DisplayObject = node.effect as DisplayObject;
                if ( object != null )
                {
                    checkObject ( child, "localTransform" );
                    readMatrix ( child.localTransform, node.localTransform );

                    var vec : Vector3D = sVector3DHeper;
                    node.localTransform.copyColumnTo ( 0, vec );
                    var radian : Number = Math.acos ( vec.x / vec.length );
                    var rotationRadian : Number = vec.y > 0 ? -radian : radian;
                    var scaleX : Number = vec.length;
                    node.localTransform.copyColumnTo ( 1, vec );
                    var scaleY : Number = vec.length;

                    object.scaleX = scaleX;
                    object.scaleY = scaleY;

                    object.rotation = rotationRadian;

                    node.localTransform.copyColumnTo ( 3, vec );
                    object.x = vec.x;
                    object.y = vec.y;
                    _effects[ i ].depth = vec.z;
                }
            }
            _effects.fixed = true;

            _effects.sort ( function ( node1 : EffectNode, node2 : EffectNode ) : int
            {
                if ( node1.depth > node2.depth ) return -1;
                else if ( node1.depth < node2.depth ) return 1;

                return 0;
            } );

            for ( i = 0, n = _effects.length; i < n; i++ )
            {
                node = _effects[ i ];
                object = node.effect as DisplayObject;
                if ( object != null )
                {
                    object.visible = true;
                    this.addChild ( object );
                }
            }
        }

        override protected function _reset () : void
        {
            super._reset ();
            _currentLife = 0.0;
            for ( var i : int = 0, n : int = _effects.length; i < n; ++i )
            {
                _effects[ i ].effect.reset ();
            }
        }

        override protected function _update ( deltaTime : Number ) : void
        {
            super._update ( deltaTime );
            _currentLife += deltaTime;
            for ( var i : int = 0, n : int = _effects.length; i < n; ++i )
            {
                if ( !_effects[ i ].effect.isDead )
                {
                    _effects[ i ].effect.update ( deltaTime );
                }
            }
        }
    }
}

import QFLib.Graphics.FX.effectsystem.IEffect;

import flash.geom.Matrix3D;

class EffectNode
{
    public function EffectNode ()
    {
        localTransform = new Matrix3D ();
        localTransform.identity ();
    }

    public function dispose () : void
    {
        effect.dispose ();
        effect = null;

        localTransform = null;
    }

    public var effect : IEffect = null;
    public var localTransform : Matrix3D = null;
    public var depth : Number = 0.0;
}