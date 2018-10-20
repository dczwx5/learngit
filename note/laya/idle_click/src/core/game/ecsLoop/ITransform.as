package core.game.ecsLoop
{
    import laya.d3.math.Vector3;
    import laya.d3.math.Vector4;

    public interface ITransform extends IGameComponent {
        function get x() : Number;
        function set x(v:Number) : void;

        function get y() : Number;
        function set y(v:Number) : void;

        function get z() : Number;
        function set z(v:Number) : void;

        // function get position() : Vector3;
        function set position(v:Vector3) : void;
        function setPosition(x:Number, y:Number, z:Number) : void ;

        function get rotationX() : Number;
        function set rotationX(v:Number) : void;

        function get rotationY() : Number;
        function set rotationY(v:Number) : void;

        function get rotationZ() : Number;
        function set rotationZ(v:Number) : void;

        function get rotationW() : Number;
        function set rotationW(v:Number) : void;

        function get rotation() : Vector4;
        function set rotation(v:Vector4) : void;

        function get scale() : Vector3;
        function set scale(v:Vector3) : void;

        function get scaleX() : Number;
        function set scaleX(v:Number) : void;
        
        function get scaleY() : Number;
        function set scaleY(v:Number) : void;

        function get scaleZ() : Number;
        function set scaleZ(v:Number) : void;
    }   
}