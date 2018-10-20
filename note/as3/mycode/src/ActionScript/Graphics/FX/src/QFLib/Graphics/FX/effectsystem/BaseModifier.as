/**
 * Created by David on 2016/9/10.
 */
package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Rectangle;

    public class BaseModifier implements IEffect
    {
        protected var _effectURL : String = null;

        protected var _onModifierLoadFinished : Function = null;

        protected var _delay : Number = 0.0;
        protected var _life : Number = 1.0;

        protected var _time : Number = 0.0;
        protected var _theTarget : IFXModify = null;

        protected  var _assetsSize : int = 0;
        protected var _loop : Boolean = false;
        protected var _delaying : Boolean = true;
        protected var _enable : Boolean = false;

        protected static function checkObject ( node : Object, name : String ) : Boolean
        {
            if ( node.hasOwnProperty ( name ) )
                return true;
            else
                throw new ModifierJsonDataError ( name );
        }

        public function BaseModifier ()
        {
        }

        public function dispose () : void
        {
            _onModifierLoadFinished = null;
            _theTarget = null;
        }

        // try getting all used resources - implement by the derived classes
        public virtual function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            return 0;
        }

        public function loadFromObject ( url : String, jsonData : Object, iLoadingPriority : int = ELoadingPriority.NORMAL, onEffectLoadedFunc : Function = null ) : void
        {
            reset ();

            _effectURL = url;
            _onModifierLoadFinished = onEffectLoadedFunc;

            if ( checkObject ( jsonData, "delay" ) )
                this.delay = jsonData.delay;

            if ( checkObject ( jsonData, "loop" ) )
                this._loop = jsonData.loop;

            if ( checkObject ( jsonData, "life" ) )
                this._life = jsonData.life;

            _loadFromObject ( url, jsonData );

            _enable = true;
            if ( _onModifierLoadFinished != null ) { _onModifierLoadFinished (); }
        }

        public function attachToTarget ( target : IFXModify ) : void
        {
            _theTarget = target;
        }
        public function detachFromTarget () : void
        {
            reset ();
            _theTarget = null;
        }

        [Inline] public final function get assetsSize () : int { return _assetsSize; }
        [Inline] public function get isModifier () : Boolean { return true; }
        [Inline] public function get isDead () : Boolean { return false; }
        [Inline] public function set loop ( value : Boolean ) : void { _loop = value; }
        [Inline] public function get enable () : Boolean { return _enable; }

        [Inline] public function get delay () : Number { return _delay; }
        [Inline] public function set delay ( value : Number ) : void { _delay = value; }

        [Inline] public function getBounds ( targetSpace : DisplayObject, resultRect : Rectangle = null ) : Rectangle { return null; }
        [Inline] public function getWorldBound ( resultRect : Rectangle = null ) : Rectangle { return null; }
        [Inline] public function setScreenVisible ( value : Boolean ) : void {}

        public function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void {}
        public function resetColor () : void {}

        public function reset () : void
        {
            _time = 0.0;
            _delaying = true;
            _reset ();
        }

        public function update ( deltaTime : Number ) : void
        {
            if ( _theTarget == null ) return;

            _time += deltaTime;
            if ( _time > delay )
            {
                if ( _delaying )
                {
                    _delaying = false;
                    _update ( _time - delay );
                }
                else
                {
                    _update ( deltaTime );
                }
            }
        }

        protected virtual function _reset () : void {}
        protected virtual function _update ( deltaTime : Number ) : void {}
        protected virtual function _loadFromObject ( url : String, data : Object ) : void { }

    }
}

class ModifierJsonDataError extends ArgumentError
{
    public function ModifierJsonDataError ( nodeName : String, id : * = 0 )
    {
        super ( "modifier: there is no [" + nodeName + "] node.", id );
    }
}
