package QFLib.Graphics.RenderCore.render
{

    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public interface IMaterial
    {
        function addPass ( name : String, className : Class, enable : Boolean = true, disableOthers : Boolean = false, ...args ) : IPass
        function get passes () : Vector.<IPass>;
        function reset () : void;
        function update () : void;

        //XXX:残影需要，需改进
        function set mainTexture ( value : Texture ) : void;
        function get mainTexture () : Texture;


        //临时的
        function get useTexcoord () : Boolean;
        function get useColor () : Boolean;
        function get useNormal () : Boolean;

        function equal ( other : IMaterial ) : Boolean;
    }
}