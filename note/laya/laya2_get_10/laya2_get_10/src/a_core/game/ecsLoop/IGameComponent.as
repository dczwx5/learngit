package a_core.game.ecsLoop
{
    import laya.resource.IDispose;
    import a_core.framework.IDataHolder;

    public interface IGameComponent extends IDispose, IDataHolder {

        function get Name() : String;

        function set Name(v:String) : void ;

        function get owner() : CGameObject;

        function get enable() : Boolean;
        function set enable(v:Boolean) : void;
 
        function getComponent(clazz:Class, cache:Boolean = true) : IGameComponent;
    }   
}