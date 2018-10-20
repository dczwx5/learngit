package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.FX.effectsystem.keyFrame.TrackFrame;
    import QFLib.Graphics.RenderCore.render.ICuller;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObjectContainer;
    import QFLib.Graphics.RenderCore.starling.display.ISceneNode;
    import QFLib.Graphics.RenderCore.starling.display.RenderQueueGroup;
    import QFLib.Graphics.RenderCore.starling.utils.MatrixUtil;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;

    public class BaseEffect extends DisplayObjectContainer implements IEffect
    {
        private static var _matrixDataHelper : Vector.<Number>;

        protected var _onEffectLoadFunc : Function = null;
        protected var _delay : Number = 0.0;
        protected var _loop : Boolean = false;

        protected var _effectURL : String = null;
        protected var _bound : Rectangle = null;

        protected var _life : Number = 1.0;
        protected var _time : Number = 0.0;
        protected var _currentLife : Number = 0.0;
        protected var _delaying : Boolean = true;
        protected var _isRootEffect : Boolean = true;

        protected var _needTrack : Boolean = false;
        protected var _trackFrame : TrackFrame = null;
        protected var _trackTransform : Matrix;
        protected var _trackTransformDirty : Boolean = false;

        protected var _bScreenVisible : Boolean = true;

        protected var _assetsSize : int = 0;

        protected static function readMatrix ( data : Object, matrix : Matrix3D ) : void
        {
            if ( _matrixDataHelper == null )
            {
                _matrixDataHelper = new Vector.<Number> ( 16 );
            }
            for ( var i : int = 0; i < 16; ++i )
            {
                _matrixDataHelper[ i ] = data[ i ];
            }
            matrix.copyRawDataFrom ( _matrixDataHelper );
        }

        protected static function checkObject ( node : Object, name : String ) : Boolean
        {
            if ( node.hasOwnProperty ( name ) )
                return true;
            else
                throw new EffectJsonDataError ( name );
        }

        public function BaseEffect ()
        {
            super ();
        }

        override public function dispose () : void
        {
            _onEffectLoadFunc = null;

            if ( _trackFrame != null )
            {
                _trackFrame.dispose ();
                _trackFrame = null;
            }

            removeFromParent ( false );
            super.dispose ();
        }

        override public function get localTransform () : Matrix
        {
            if ( _trackTransformDirty )
            {
                var tempMatrix : Matrix = super.localTransform.clone ();
                MatrixUtil.prependMatrix ( tempMatrix, _trackTransform );
                return tempMatrix;
            }
            else
            {
                return super.localTransform;
            }
        }

        public function get assetsSize() : int { return _assetsSize; }
        [Inline] final public function get isModifier () : Boolean { return false; }
        [Inline] final public function get life () : Number { return _life; }
        [Inline] final public function set loop ( value : Boolean ) : void { _loop = value; }
        [Inline] final public function set needTrack ( value : Boolean ) : void { _needTrack = value; }
        public virtual function get isDead () : Boolean { return false; }
        public virtual function get enable () : Boolean { return false; }
        [Inline] final public function get delay () : Number { return _delay; }
        [Inline] final public function set delay ( value : Number ) : void { _delay = Number.max ( 0, value ); }
        [Inline] final public function get isRootEffect () : Boolean { return _isRootEffect; }
        [Inline] final public function set isRootEffect ( value : Boolean ) : void { _isRootEffect = value; }
        [Inline] final public function setScreenVisible ( value : Boolean ) : void { _bScreenVisible = value; }

        public function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void {}
        public function resetColor () : void {}
        public virtual function attachToTarget ( target : IFXModify ) : void {}
        public virtual function detachFromTarget () : void {}

        public virtual function loadFromObject ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL, onEffectLoadedFunc : Function = null ) : void
        {
            reset ();

            _effectURL = url;
            _onEffectLoadFunc = onEffectLoadedFunc;

            if ( data.hasOwnProperty ( "needTrack" ) )
                this._needTrack = data.needTrack;
            if ( _needTrack && checkObject ( data, "trackFrame" ) )
            {
                _trackFrame = new TrackFrame ();
                _trackFrame.loadFromObject ( data.trackFrame );
                _trackTransform = new Matrix ();
            }

            if ( checkObject ( data, "delay" ) )
                this.delay = data.delay;

            if ( checkObject ( data, "loop" ) )
                this._loop = data.loop;

            if ( data.hasOwnProperty ( "bound" ) )
            {
                var boundData : Object = data.bound;
                var width : Number = boundData.maxX - boundData.minX;
                var height : Number = boundData.maxY - boundData.minY;
                _bound = new Rectangle ( boundData.minX, -boundData.maxY, width, height );
            }
            else
            {
                //当前默认，没有bound数据也暂时渲染，待美术所有特效处理过后再改过.
                _bound = new Rectangle ( 0, 0, 100, 100 );
            }
        }

        public function reset () : void
        {
            _time = 0.0;
            _delaying = true;
            _bScreenVisible = true;
            _reset ();
        }

        public function update ( deltaTime : Number ) : void
        {
            _time += deltaTime;
            if ( _time > delay )
            {
                if ( _delaying )
                {
                    _delaying = false;
                    _preUpdate ();
                    _update ( _time - delay );
                    _postUpdate ();
                }
                else
                {
                    _preUpdate ();
                    _update ( deltaTime );
                    _postUpdate ();
                }
            }
        }

        public override function addToRenderQueue ( culler : ICuller, groups : RenderQueueGroup ) : void
        {
            if ( !enable || isDead || !hasVisibleArea || !_bScreenVisible ) return;

            // Check if camera's cullMask cover this.layer
            if ( !culler.checkCullingMask ( this ) )
                return;

            if ( !isDrawSelf () && _isRootEffect )
            //if ( _bound != null ) //当前默认，没有bound，照样渲染
                this.isInRender = culler.isVisibleNode ( this );

            if ( this.isInRender )
            {
                var numChildren : int = childCount;
                var child : ISceneNode = null;
                for ( var i : int = 0; i < numChildren; ++i )
                {
                    child = getChild ( i );
                    child.isInRender = true;

                    child.addToRenderQueue ( culler, groups );
                }
            }
        }

        public override function getBounds ( targetSpace : DisplayObject,
                                             resultRect : Rectangle = null ) : Rectangle
        {
            if ( _bound == null ) return null;

            if ( resultRect == null ) resultRect = new Rectangle ();

            if ( targetSpace == this )
            {
                resultRect.x = _bound.x;
                resultRect.y = _bound.y;
                resultRect.width = _bound.width;
                resultRect.height = _bound.height;
            }

            return resultRect;
        }

        // try getting all used resources - implement by the derived classes
        public virtual function retrieveAllResources ( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            return 0;
        }

        protected virtual function _render ( support : RenderSupport, alpha : Number ) : void
        {
        }

        protected function _preUpdate () : void
        {
        }

        protected function _postUpdate () : void
        {
        }

        protected virtual function _update ( deltaTime : Number ) : void
        {
            if ( _needTrack )
            {
                var theTime : Number = _currentLife / life;
                theTime = theTime - Math.floor ( theTime );
                var position : CVector2 = _trackFrame.getPosition ( theTime );
                _trackTransform.identity ();
                _trackTransform.translate ( position.x, position.y );
                _trackTransformDirty = true;
                worldMatrixDirty = true;
            }
        }

        protected virtual function _reset () : void
        {
            if ( _needTrack )
            {
                _trackTransform.identity ();
                _trackTransformDirty = false;
            }
        }
    }
}

class EffectJsonDataError extends ArgumentError
{
    public function EffectJsonDataError ( nodeName : String, id : * = 0 )
    {
        super ( "effect: there is no [" + nodeName + "] node.", id );
    }
}