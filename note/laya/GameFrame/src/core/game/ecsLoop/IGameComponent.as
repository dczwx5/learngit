package core.game.ecsLoop
{
    import laya.resource.IDispose;
    import core.framework.IDataHolder;

    public interface IGameComponent extends IDispose, IDataHolder {

        function get name() : String;

        function set name(v:String) : void ;

        function get owner() : CGameObject;

        function get enable() : Boolean;
        function set enable(v:Boolean) : void;
 
        function getComponent(clazz:Class, cache:Boolean = true) : IGameComponent;
    }   
}