//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/5/20.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Scene
{
	import QFLib.Graphics.RenderCore.render.Camera;
	import QFLib.Graphics.RenderCore.starling.core.Starling;
	import QFLib.Graphics.RenderCore.starling.utils.MatrixUtil;
	import QFLib.Math.CAABBox2;
	import QFLib.Math.CVector2;

	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;

	public class CSceneLayerCamera extends Camera
	{
		public function CSceneLayerCamera()
		{
			super();

            _theCamBox.setCenterExtValue( _cameraCenterX, _cameraCenterY, _screenScaledW * 0.5, _screenScaledH * 0.5 );

			Starling.current.nativeStage.addEventListener( Event.RESIZE, onStageResizeHandler );
		}

		public function dispose():void
		{
			Starling.current.nativeStage.removeEventListener( Event.RESIZE, onStageResizeHandler );
		}

        [Inline]
        final public function get cameraBox() : CAABBox2
        {
            return _theCamBox;
        }

		public override function get scale() : Number
		{
			return _screenScaler;
		}

		public function set scale( value : Number ) : void
		{
			_screenScaler = value;
			_screenScaledW = _screenW / _screenScaler;
			_screenScaledH = _screenH / _screenScaler;
            _theCamBox.setExtValue( _screenScaledW * 0.5, _screenScaledH * 0.5 );

			_matrixProjDirty = true;
		}

		public override function get matrixProj() : Matrix3D
		{
			_buildMatrixProj();
			return _matrixProj3D;
		}

		public override function set matrixProj( matrix : Matrix3D ) : void
		{
			_matrixProjDirty = false;
			_matrixProj3D.copyFrom(matrix);
			MatrixUtil.convertTo2D(_matrixProj3D, _matrixProj2D);
		}

		public override function setPosition( xpos : Number, ypos : Number ) : void
		{
			_cameraCenterX = xpos * scrollSpeedX;
			_cameraCenterY = ypos * scrollSpeedY;
            _theCamBox.setCenterValue( _cameraCenterX, _cameraCenterY );

			_matrixProjDirty = true;
		}

		public override function setOrthoSize( width : Number, height : Number ) : void
		{
			var ratio : Number = width / height;

			_screenW = width;
			_screenH = _screenW / ratio;

			_screenScaledW = _screenW / _screenScaler;
			_screenScaledH = _screenH / _screenScaler;
            _theCamBox.setExtValue( _screenScaledW * 0.5, _screenScaledH * 0.5 );

			_matrixProjDirty = true;
		}

        public function backoff( fBackoffScale : Number ) : void
        {
            _backoffSScaler = fBackoffScale;
        }

		public override function screenToWorld( x : Number, y : Number, worldPos : CVector2 ) : void
		{
			worldPos.x = (x - _screenW * 0.5) / _screenScaler + _cameraCenterX;
            worldPos.y = (y - _screenH * 0.5) / _screenScaler + _cameraCenterY;
		}

        [Inline]
        final public function isCollided( theGlobalBound : CAABBox2 ) : Boolean
        {
            return _theCamBox.isCollided( theGlobalBound );
        }

        public function get cameraCenterX():Number { return _cameraCenterX; }
		public function get cameraCenterY():Number { return _cameraCenterY; }

		public override function get viewportX() : Number { return _cameraCenterX - 0.5 * _screenScaledW; }
		public override function get viewportY() : Number { return _cameraCenterY - 0.5 * _screenScaledH; }
		public override function get viewportWidth() : Number { return _screenScaledW; }
		public override function get viewportHeight() : Number { return _screenScaledH; }

		protected function onStageResizeHandler( event : Event ) : void
		{
            setOrthoSize( event.target.stageWidth, event.target.stageHeight );
        }

		private function _buildMatrixProj() : void
		{
			if (_matrixProjDirty)
			{
                if( _backoffSScaler == 1.0 )
                {
                    _matrixProj2D.setTo(
                            2.0 / _screenScaledW, 0,
                            0, -2.0 / _screenScaledH,
                            -(2 * _cameraCenterX) / _screenScaledW,
                            +(2 * _cameraCenterY) / _screenScaledH );
                    MatrixUtil.convertTo3D( _matrixProj2D, _matrixProj3D );
                }
                else
                {
                    _matrixProj2D.setTo(
                            2.0 / ( _screenScaledW * _backoffSScaler ), 0,
                            0, -2.0 / ( _screenScaledH * _backoffSScaler ),
                            -(2 * _cameraCenterX) / ( _screenScaledW * _backoffSScaler ),
                            +(2 * _cameraCenterY) / ( _screenScaledH * _backoffSScaler ) );
                    MatrixUtil.convertTo3D(_matrixProj2D, _matrixProj3D);
                }

				_matrixProjDirty = false;
			}
		}

		public var scrollSpeedX : Number = 1.0;
		public var scrollSpeedY : Number = 1.0;

		// 以下代码是构建projection矩阵用的,
		// 为了渲染卷轴不移动layer
		// 我们决定尝试用修改projection的方式去渲染卷轴
		private var _matrixProjDirty : Boolean = true;
		private var _matrixProj2D : Matrix = new Matrix();
		private var _matrixProj3D : Matrix3D = new Matrix3D();
		private var _screenW : Number = 1500;
		private var _screenH : Number = 900;
        private var _screenScaler : Number = 1.0;
        private var _backoffSScaler : Number = 1.0;
		private var _cameraCenterX : Number = 0.0;
		private var _cameraCenterY : Number = 0.0;
		private var _screenScaledW : Number = 1500;
		private var _screenScaledH : Number = 900;

        private var _theCamBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
	}
}
