package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Rectangle;

    public interface IEffect
    {
        function get isModifier () : Boolean;
        function get delay () : Number;
        function get isDead () : Boolean;
        function set loop ( value : Boolean ) : void;
        function get enable () : Boolean;
        function get assetsSize () : int;
        function setScreenVisible ( value : Boolean ) : void
        function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void;
        function resetColor () : void;
        function reset () : void;
        function update ( deltaTime : Number ) : void;
        function attachToTarget ( target : IFXModify ) : void;
        function detachFromTarget () : void;
        function getBounds ( targetSpace : DisplayObject, resultRect : Rectangle = null ) : Rectangle;
        function getWorldBound ( resultRect : Rectangle=null ) : Rectangle;
        function loadFromObject ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL, onEffectLoadFinished : Function = null ) : void;
        function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int;
        function dispose () : void;
    }
}