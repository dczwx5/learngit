/**
 * Created by Cliff on 2017/5/8.
 */
package QFLib.Graphics.FX.effectsystem {
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.display.Image;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.display.BlendMode;

    public class UVAnimationInstance extends BaseEffectInstance {

    private var _image:Image;

    private var _currentRotation:Number = 0.0;

    private var _rotateVelocity:Number = 0.0;
    private var _initalRotation:Number = 0.0;
    private var _velocityX:Number = 0.0;
    private var _velocityY:Number = 0.0;
    private var _marginX:Number = 0.0;
    private var _marginY:Number = 0.0;

    private var _tilingX:int = 1;
    private var _tilingY:int = 1;
    private var _offsetX:Number = 0.0;
    private var _offsetY:Number = 0.0;

    private var _hasVelocityX:Boolean;
    private var _hasVelocityY:Boolean;

    public function UVAnimationInstance() {
        super();

        _image = new Image(null);
        _image.uvAnimationEnable = true;
        addChild(_image);
    }

    public override function get isDead () : Boolean
    {
        if ( _loop && _currentLife > life )
        {
            _reset ();
        }

        return _currentLife > life;
    }

    public function get normalLife () : Number
    {
        var l : Number = _currentLife / life;
        return l - Math.floor ( l );
    }

    override public function loadFromObject ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL, onEffectLoadFinished : Function = null ) : void
    {
        super.loadFromObject ( url, data, iLoadingPriority, onEffectLoadFinished );

        var theTintColor:Object = data.material.tintColor;
        _image.setColor(theTintColor.r, theTintColor.g, theTintColor.b, theTintColor.a);
        if ( _material.shader == "QFX/Additive" )
        {
            _image.blendMode = BlendMode.ADD;
        }
        else
        {
            _image.blendMode = BlendMode.NORMAL;
        }
    }

    protected override function _loadFromObject ( data : Object ) : void
    {
        //unity和flash旋转正向不同
        if ( checkObject ( data, "rotateVelocity" ) )
            _rotateVelocity = -data.rotateVelocity;
        if ( checkObject ( data, "initialRotation" ) )
            _initalRotation = -data.initialRotation;
        _currentRotation = _initalRotation;

        if( checkObject( data, "velocityX") )
        {
            _velocityX = data.velocityX;
            _hasVelocityX = _velocityX!=0.0;
        }
        if( checkObject( data, "velocityY") )
        {
            _velocityY = data.velocityY;
            _hasVelocityY = _velocityY!=0.0;
        }

        if ( checkObject ( data, "tilingX" ) )
            _tilingX = data.tilingX;
        if ( checkObject ( data, "tilingY" ) )
            _tilingY = data.tilingY;
        if ( checkObject ( data, "offsetX" ) )
            _offsetX = data.offsetX;
        if ( checkObject ( data, "offsetY" ) )
            _offsetY = data.offsetY;
        _image.updateTiling(_tilingX, _tilingY, _offsetX, _offsetY);

        if( checkObject( data, "marginX") )
            _marginX = data.marginX;
        if( checkObject( data, "marginY") )
            _marginY = data.marginY;
        _image.updateMargin(_marginX, _marginY);
    }

    protected override function _render ( support : RenderSupport, alpha : Number ) : void
    {
        if ( _image == null ) return;

        var pTex : Texture = _image.texture;
        if ( pTex == null || !pTex.uploaded || pTex.base == null )
            return;

        _updateMesh ();
        _image.render ( support, alpha );
    }

    protected override function _update ( deltaTime : Number ) : void
    {
        super._update( deltaTime );
        _currentLife += deltaTime;
        _currentRotation += deltaTime * _rotateVelocity;

        if(_image.texture == null && _material.texture!=null)
        {
            _image.texture = _material.texture;
            _image.texture.repeat = true;
        }

        var offsetU:Number = _hasVelocityX? _tilingX/_velocityX*_currentLife:0.0;
        var offsetV:Number = _hasVelocityY? _tilingY/_velocityY*_currentLife:0.0;
        offsetU = (offsetU+_offsetX) % _tilingX;
        offsetV = (offsetV+_offsetY) % _tilingY;
        _image.updateOffsetUV(offsetU, offsetV);
    }

    protected override function _updateMesh () : void
    {
        var size : CVector2 = _keyFrame.getSize ( normalLife );
        var cosR : Number = Math.cos ( _currentRotation );
        var sinR : Number = Math.sin ( _currentRotation );

        var axisR : CVector2 = sVector2DHelper0;
        var axisQ : CVector2 = sVector2DHelper1;

        axisR.x = cosR;
        axisR.y = sinR;
        axisQ.x = -sinR;
        axisQ.y = cosR;

        var axisRXmulSizeX : Number = axisR.x * size.x;
        var axisQXmulSizeY : Number = axisQ.x * size.y;

        var axisRYmulSizeX : Number = axisR.y * size.x;
        var axisQYmulSizeY : Number = axisQ.y * size.y;

        //update vertex position
        var xPos : Number = -axisRXmulSizeX - axisQXmulSizeY;
        var yPos : Number = -axisRYmulSizeX - axisQYmulSizeY;
        _image.setVertexPositionTo(0, xPos, yPos);

        xPos = axisRXmulSizeX - axisQXmulSizeY;
        yPos = axisRYmulSizeX - axisQYmulSizeY;
        _image.setVertexPositionTo(1, xPos, yPos);

        xPos = -axisRXmulSizeX + axisQXmulSizeY;
        yPos = -axisRYmulSizeX + axisQYmulSizeY;
        _image.setVertexPositionTo(2, xPos, yPos);

        xPos = axisRXmulSizeX + axisQXmulSizeY;
        yPos = axisRYmulSizeX + axisQYmulSizeY;
        _image.setVertexPositionTo(3, xPos, yPos);

        //update vertex color
        var color : uint = _keyFrame.getColor ( normalLife );
        var alpha : Number = ( color & 0xff ) / 255.0;
        color = ( color >> 8 ) & 0x00FFFFFF;
        _image.verticesColor = color;
        _image.setVertexAlpha(0, alpha);
        _image.setVertexAlpha(1, alpha);
        _image.setVertexAlpha(2, alpha);
        _image.setVertexAlpha(3, alpha);

        var offset : int = _material.getUVOffsetByNormalLife ( normalLife );
        var uvList : Vector.<Number> = _material.uvList;
        _image.setTexCoordsTo ( 0, uvList[ offset ]*_tilingX, uvList[ offset + 1]*_tilingY );
        _image.setTexCoordsTo ( 1, uvList[ offset + 2 ]*_tilingX, uvList[ offset + 3 ]*_tilingY );
        _image.setTexCoordsTo ( 3, uvList[ offset + 4 ]*_tilingX, uvList[ offset + 5 ]*_tilingY );
        _image.setTexCoordsTo ( 2, uvList[ offset + 6 ]*_tilingX, uvList[ offset + 7 ]*_tilingY );
    }

    protected override function _reset () : void
    {
        super._reset ();
        _currentLife = 0.0;
        _currentRotation = _initalRotation;
    }
}
}
