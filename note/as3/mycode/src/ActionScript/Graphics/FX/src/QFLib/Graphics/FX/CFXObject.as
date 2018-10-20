/**
 * Created by david on 2016/5/9.
 */
package QFLib.Graphics.FX
{

    import QFLib.Foundation;
    import QFLib.Graphics.FX.effectsystem.EffectSystem;
    import QFLib.Graphics.FX.effectsystem.IEffect;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.CRenderer;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Rectangle;

    public class CFXObject extends CBaseObject
    {
        private static var sRectHelper : Rectangle = new Rectangle ();

        private var _localBound : CAABBox2 = null;
        private var _resource : CResource = null;
        private var _effect : IEffect = null;
        private var _fileURL : String = null;
        private var _iLoadingPriority : int = ELoadingPriority.NORMAL;
        private var _theTarget : IFXModify = null;
        private var _assetsSize : int  = 0;
        private var _onLoadFinishedFunc : Function = null;
        private var _enable : Boolean = false;
        private var _isLoader : Boolean = false;

        private var _arrTexResource : Array = new Array();

        public function CFXObject ( theRenderer : CRenderer )
        {
            super ( theRenderer );
            m_theDisplayNode.touchable = false;
        }

        override public function dispose () : void
        {
            _fileURL = null;
            _theTarget = null;
            _isLoader = false;

            if ( _effect != null )
            {
                _effect.dispose ();
                _effect = null;
            }

            if ( null != _resource )
            {
                _resource.dispose ();
                _resource = null;
            }

            super.dispose ();
        }

        // try getting all used resources - implement by the derived classes
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            if ( _resource != null  )
            {
                if( vResources != null )
                {
                    vResources[ iBeginIndex + iCount ] = _resource;
                }
                iCount++;
            }

            if( _effect != null)
            {
                iCount += _effect.retrieveAllResources( vResources, iBeginIndex + iCount );
            }
            return iCount;
        }

        public function loadFile ( fileURL : String, iLoadingPriority : int = ELoadingPriority.NORMAL, onLoadFinshedFunc : Function = null ) : void
        {
            if ( _effect != null )
            {
                return;
            }

            _iLoadingPriority = iLoadingPriority;
            _onLoadFinishedFunc = onLoadFinshedFunc;
            _fileURL = fileURL;
            CResourceLoaders.instance ().startLoadFile ( fileURL, onLoadFinished, CJsonLoader.NAME, iLoadingPriority, true );
        }

        public override function set opaque ( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            if ( _effect != null )
            {
                var object : DisplayObject = _effect as DisplayObject;
                if ( object != null ) object.alpha = fOpaque;
            }
            else
            {
                m_theDisplayNode.alpha = fOpaque;
            }
        }

        [Inline] final public function get assetsSize () : int { return _assetsSize; }
        [Inline] final public function get isModifier () : Boolean { return _effect.isModifier; }
        [Inline] final public function get isLoader() : Boolean { return _isLoader; }
        [Inline] final public function get isDead () : Boolean { return _effect.isDead; }
        [Inline] final public function get enable () : Boolean { return _enable; }
        [Inline] final public function get effect () : IEffect { return _effect; }
        [Inline] final public function setScreenVisible ( value : Boolean ) : void { _effect.setScreenVisible ( value ); }

        override public function setColor (  r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false  ) : void
        {
            if ( _effect != null ) _effect.setColor ( r, g, b, alpha, masking );
        }
        override public function resetColor () : void { if ( _effect != null ) _effect.resetColor (); }

        override public function get currentBound () : CAABBox2
        {
            if ( _effect != null && _localBound == null )
            {
                var localBound : Rectangle = _effect.getBounds ( _effect as DisplayObject, sRectHelper );
                if ( localBound != null )
                {
                    if ( _localBound == null ) _localBound = new CAABBox2 ( CVector2.zero () );
                    _localBound.min.x = localBound.x;
                    _localBound.min.y = localBound.y;
                    _localBound.max.x = localBound.x + localBound.width;
                    _localBound.max.y = localBound.y + localBound.height;
                }
            }

            return _localBound;
        }

        public function getWorldBound ( resultRect : Rectangle = null ) : Rectangle
        {
            if ( _effect != null ) return _effect.getWorldBound ( resultRect );
            return null;
        }


        public function attachToTarget ( target : IFXModify ) : void
        {
            _theTarget = target;
            if ( _effect != null )
            { _effect.attachToTarget ( target ); }
        }

        public function detachFromTarget () : void
        {
            if ( _effect != null ) _effect.detachFromTarget ();
            _theTarget = null;
        }

        public override function update ( deltaTime : Number ) : void
        {
            if ( !_enable || null == _effect || isDead ) return;

            Foundation.Perf.sectionBegin ( "CFXObject_Update" );

            _effect.update ( deltaTime );
            super.update ( deltaTime );

            Foundation.Perf.sectionEnd ( "CFXObject_Update" );
        }

        public function reset () : void
        {
            if ( null != _effect ) _effect.reset ();
        }

        private function onLoadFinished ( loader : CJsonLoader, idErrorCode : int ) : void
        {
            if ( this.disposed ) return;

            if ( idErrorCode == 0 )
            {
                _resource = loader.createResource ();
                var data : Object = _resource.theObject;
                if ( null == data )
                {
                    Foundation.Log.logErrorMsg ( "effect load failure:" + _fileURL );
                    return;
                }

                _assetsSize = _resource.resourceSize;

                if ( null == _effect )
                    _effect = EffectSystem.createEffect ( data.type );

                _effect.loadFromObject ( _fileURL, data, _iLoadingPriority, onEffectLoadFinished );
            }
            else
            {
                Foundation.Log.logErrorMsg ( "FX load failed, please check the fx url: " + _fileURL );
            }
        }

        private function onEffectLoadFinished (loadSuccess:Boolean = true, params : * = null ) : void
        {
            if(!loadSuccess)
            {
                _assetsSize = 0;

                if ( _onLoadFinishedFunc != null )
                    _onLoadFinishedFunc (false);

                return;
            }

            if ( params != null && _arrTexResource.indexOf( params[0] ) == -1 )
            {
                _arrTexResource.push( params[ 0 ] );
                _assetsSize += params[ 1 ];
            }

            if ( _effect != null && _effect.enable )
            {
                _arrTexResource = null;
                _enable = true;

                if ( _theTarget != null )
                    _effect.attachToTarget ( _theTarget );

                var object : DisplayObject = _effect as DisplayObject;
                if ( object != null )
                {
                    object.alpha = m_fOpaque;
                    object.touchable = false;
                    _addChild ( object );
                }

                if ( _onLoadFinishedFunc != null )
                {
                    _onLoadFinishedFunc ();
                }
                _isLoader = true;
            }
        }
    }
}