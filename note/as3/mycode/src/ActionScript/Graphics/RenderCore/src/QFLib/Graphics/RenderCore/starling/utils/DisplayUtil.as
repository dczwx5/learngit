////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Graphics.RenderCore.starling.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import QFLib.Graphics.RenderCore.starling.core.Starling;
	import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
	import QFLib.Graphics.RenderCore.starling.display.DisplayObjectContainer;
	import QFLib.Graphics.RenderCore.starling.display.Image;
	import QFLib.Graphics.RenderCore.starling.display.Sprite;

	/**
	 * 显示对象功能
	 * @author lyman
	 *
	 */
	public class DisplayUtil
	{
		private static const _interactivedObjOnMouseOverCallbackDic:Dictionary = new Dictionary();
		private static const _interactivedObjOnMouseOutCallbackDic:Dictionary = new Dictionary();
		
		public static function installOverOut(interactived:InteractiveObject, onOver:Function, onOverArgs:Array = null, onOut:Function = null, onOutArgs:Array = null):void
		{
			var overCallback:Callback = _interactivedObjOnMouseOverCallbackDic[interactived];
			if (overCallback)
				overCallback.dispose();
			else
				_interactivedObjOnMouseOverCallbackDic[interactived] = overCallback = new Callback();
			overCallback.resurgence();
			overCallback.callback = onOver;
			overCallback.args = onOverArgs;
			
			var outCallback:Callback = _interactivedObjOnMouseOutCallbackDic[interactived];
			if (outCallback)
				outCallback.dispose();
			else
				_interactivedObjOnMouseOutCallbackDic[interactived] = outCallback = new Callback();
			outCallback.resurgence();
			outCallback.callback = onOut;
			outCallback.args = onOutArgs;
			
			interactived.addEventListener(MouseEvent.ROLL_OVER, onOverHandler, false, 0, true);
			interactived.addEventListener(MouseEvent.ROLL_OUT, onOutHandler, false, 0, true);
		}
		
		public static function uninstallOverOut(interactived:InteractiveObject):void
		{
			var callback:Callback = _interactivedObjOnMouseOverCallbackDic[interactived];
			if (callback)
				callback.dispose();
				delete _interactivedObjOnMouseOverCallbackDic[interactived];
			interactived.removeEventListener(MouseEvent.ROLL_OVER, onOverHandler);
			interactived.removeEventListener(MouseEvent.ROLL_OUT, onOutHandler);
		}
		
		private static function onOutHandler(e:MouseEvent):void
		{
			var interactived:InteractiveObject = e.target as InteractiveObject;
			var callback:Callback = _interactivedObjOnMouseOutCallbackDic[interactived];
			if (callback)
				callback.excute();
			//			hideTips(interactived as ITips);
//			hideAllTip();
		}
		
		private static function onOverHandler(e:MouseEvent):void
		{
			var interactived:InteractiveObject = e.target as InteractiveObject;
			var callback:Callback = _interactivedObjOnMouseOverCallbackDic[interactived];
			if (callback)
			{
				callback.excute();
			}
		}
		
		public static function get3DRoot():QFLib.Graphics.RenderCore.starling.display.Sprite
		{
			return Starling.current.root as QFLib.Graphics.RenderCore.starling.display.Sprite;
		}

//		public static function isInteractedInContainer(eventType:String, container:InteractiveObject):Boolean
//		{
//			var result
//			return 
//		}

		public static function copySrcToTargetTextFieldFormat(sourceTf:TextField, targetTf:TextField):void
		{
			targetTf.antiAliasType = sourceTf.antiAliasType;
			targetTf.autoSize = sourceTf.autoSize;
			targetTf.background = sourceTf.background;
			targetTf.backgroundColor = sourceTf.backgroundColor;
			targetTf.border = sourceTf.border;
			targetTf.borderColor = sourceTf.borderColor;
			targetTf.displayAsPassword = sourceTf.displayAsPassword;
			targetTf.height = sourceTf.height;
			targetTf.width = sourceTf.width;
			targetTf.textColor = sourceTf.textColor;
			targetTf.thickness = sourceTf.thickness;
			targetTf.type = sourceTf.type;
			targetTf.wordWrap = sourceTf.wordWrap;
			targetTf.multiline = sourceTf.multiline;
			targetTf.embedFonts = sourceTf.embedFonts;

			targetTf.defaultTextFormat = sourceTf.defaultTextFormat;
			targetTf.setTextFormat(sourceTf.defaultTextFormat);
		}

		public static function disposeBmp(bmp:Bitmap):void
		{
			if (!bmp)
				return;
			removeFromParent(bmp);
			bmp.bitmapData = null;
		}

		public static function dispose3DImage(img:Image):void
		{
			if(img){
				if(img.texture){
					img.texture.dispose();
					img.texture = null;
				}
				img.removeFromParent(true);
			}
		}
		
		public static function setEnabled(dsp:InteractiveObject, value:Boolean):void
		{
			dsp.mouseEnabled = value;
			var con:flash.display.DisplayObjectContainer = dsp as flash.display.DisplayObjectContainer;
			if (con)
				con.mouseChildren = value;
		}

		public static function replaceDsp(srcDsp:flash.display.DisplayObject, targetDsp:flash.display.DisplayObject):void
		{
			srcDsp.parent.addChildAt(targetDsp, srcDsp.parent.getChildIndex(srcDsp));
			removeFromParent(srcDsp);
			targetDsp.x = srcDsp.x;
			targetDsp.y = srcDsp.y;
		}
		
		public static function setRelativePos(targetDisp:flash.display.DisplayObject, relativeDisp:flash.display.DisplayObject):void
		{
			targetDisp.x = relativeDisp.x + (relativeDisp.width - targetDisp.width) * 0.5;
			targetDisp.y = relativeDisp.y + (relativeDisp.height - targetDisp.height) * 0.5;
		}

		public static function addToParent(parent:QFLib.Graphics.RenderCore.starling.display.DisplayObjectContainer, child:QFLib.Graphics.RenderCore.starling.display.DisplayObject):void
		{
			if (parent && child)
			{
				parent.addChild(child);
			}
		}

		public static function removeToParent(child:QFLib.Graphics.RenderCore.starling.display.DisplayObject, dispose:Boolean = false):void
		{
			if (child && child.parent)
			{
				child.parent.removeChild(child, dispose);
			}
		}

		public static function removeFromParent(child:flash.display.DisplayObject):void
		{
			if (child && child.parent)
			{
				if (child.parent is Loader)
				{
//					if (Capabilities.isDebugger)
//						trace("还在加载阶段的Loader里，Loader没有removeChild方法，调用会报错");
				}
				else
				{
					child.parent.removeChild(child);
				}
			}
		}

		public static function removeAllChild(obj:flash.display.DisplayObjectContainer):void
		{
			if (obj && obj.numChildren > 0)
			{
				while (obj.numChildren)
				{
					obj.removeChildAt(0);
				}
			}
		}

		/**
		 * 将显示对象用bitmapdata draw成一张位图，返回的位图坐标与原先的display对象内部元素的X，Y坐标相同
		 * @return
		 *
		 */
		public static function copyDisplayAsBmp(dis:flash.display.DisplayObject, smoothing:Boolean = true):Bitmap
		{
			if (dis == null)
			{
				return new Bitmap();
			}
			if (dis.width == 0 || dis.height == 0)
			{
				return new Bitmap();
			}
			var oldX:Number;
			var oldY:Number;

			oldY = dis.scaleY;
			oldX = dis.scaleX;

			var bmpdata:BitmapData = new BitmapData(dis.width, dis.height, true, 0);
			var rect:Rectangle = dis.getRect(dis);
			var matrix:Matrix = new Matrix();
			//matrix.translate(-rect.x,-rect.y);
			if (oldX < 0)
				dis.scaleX = -dis.scaleX;
			if (oldY < 0)
				dis.scaleY = -dis.scaleY;
			matrix.createBox(dis.scaleX, dis.scaleY, 0, -rect.x * dis.scaleX, -rect.y * dis.scaleY);
			bmpdata.draw(dis, matrix);

			dis.scaleX = oldX;
			dis.scaleY = oldY;

			var bmp:Bitmap = new Bitmap(bmpdata, PixelSnapping.AUTO, smoothing);
			if (oldX < 0)
				bmp.scaleX = -1;
			if (oldY < 0)
				bmp.scaleY = -1;
			bmp.x = rect.x * dis.scaleX;
			bmp.y = rect.y * dis.scaleY;
			return bmp;
		}

		public static function copyPixelArea(resBd:BitmapData, keyColor:uint = 0):BitmapData
		{
			var bitmapData:BitmapData = resBd;
			var left:uint = bitmapData.width;
			var right:uint = 0;
			var top:uint = bitmapData.height;
			var bottom:uint = 0;
			var color:uint;
			for (var j:int = 0; j < bitmapData.height; ++j)
			{
				for (var i:int = 0; i < bitmapData.width; ++i)
				{
					color = bitmapData.getPixel32(i, j);
					if (color != keyColor)
					{
						if (i < left)
						{
							left = i;
						}
						if (i > right)
						{
							right = i;
						}
						if (j < top)
						{
							top = j;
						}
						if (j > bottom)
						{
							bottom = j;
						}
					}
				}
			}
			//已经获得四个边，切割它
			//trace("left:"+left+", top:"+top+", right:"+right+", bottom:"+bottom);
			var width:Number = right - left;
			var height:Number = bottom - top;
			if (width <= 0)
			{
				width = 1;
			}
			if (height <= 0)
			{
				height = 1;
			}
			var bd:BitmapData = new BitmapData(width, height, true, 0x00000000);
			var rect:Rectangle = new Rectangle(left, top, width, height);
			var pt:Point = new Point();
			try
			{
				bd.copyPixels(bitmapData, rect, pt);
			}
			catch (e:Error)
			{

			}
			return bd;
		}

		/**

		/**

		 *绘制一个矩形(sprite容器)
		 * @param w
		 * @param h
		 * @param borderColor
		 * @param fillColor
		 * @param alpha
		 * @return
		 *
		 */
		public static function makeRectangle(w:Number, h:Number, borderColor:uint = 0x000000, fillColor:uint = 0x000000, alpha:Number = 1):flash.display.Sprite
		{
			var sp:flash.display.Sprite = new flash.display.Sprite();
			sp.graphics.lineStyle(1, borderColor, alpha);
			sp.graphics.beginFill(fillColor, alpha);
			sp.graphics.drawRect(0, 0, w, h);
			sp.graphics.endFill();
			return sp;
		}
		/**
		 * 绘制一个矩形(shape)
		 * @param w
		 * @param h
		 * @param borderColor
		 * @param fillColor
		 * @param alpha
		 * @return
		 *
		 */
		public static function makeRectShape(w:Number, h:Number, borderColor:uint = 0x000000, fillColor:uint = 0x000000, alpha:Number = 1):Shape
		{
			var vShape:Shape = new Shape();
			vShape.graphics.lineStyle(1, borderColor, alpha);
			vShape.graphics.beginFill(fillColor, alpha);
			vShape.graphics.drawRect(0, 0, w, h);
			vShape.graphics.endFill();
			return vShape;
		}

		/**
		 * 绘制一个园形
		 * @param w
		 * @param h
		 * @param borderColor
		 * @param fillColor
		 * @param alpha
		 * @return
		 *
		 */
		public static function makeCircle(x:Number, y:Number, radius:Number, borderColor:uint = 0x000000, fillColor:uint = 0x000000, alpha:Number = 1):Shape
		{
			var sp:Shape = new Shape();
			sp.graphics.lineStyle(1, borderColor);
			sp.graphics.beginFill(fillColor);
			sp.graphics.drawCircle(x, y, radius);
			sp.graphics.endFill();
			sp.alpha = alpha;
			return sp;
		}

		/**
		 * 自由分块切割图片
		 * @param xLen
		 * @param yLen
		 * @param sourceBmd
		 * @return
		 *
		 */
		public static function cutBitmap(xLen:uint, yLen:uint, sourceBmd:BitmapData):Vector.<Bitmap>
		{
			var w:uint = Math.ceil(sourceBmd.width / xLen);
			var h:uint = Math.ceil(sourceBmd.height / yLen);

			var all:Vector.<Bitmap> = new Vector.<Bitmap>();
			for (var i1:int = 0; i1 < xLen; i1++)
			{

				for (var j1:int = 0; j1 < yLen; j1++)
				{
					var bd:BitmapData = new BitmapData(w, h);
					bd.copyPixels(sourceBmd, new Rectangle(i1 * w, j1 * h, w, h), new Point());
					var bm:Bitmap = new Bitmap(bd);
					bm.x = i1 * w;
					bm.y = j1 * h;
					all.push(bm);
				}
			}
			return all;
		}

		/**
		 * 获取贝塞尔曲线
		 * @param startPos
		 * @param endPos
		 * @param curPos
		 * @param timer
		 * @return
		 *
		 */
		public static function getBezier(startPos:Point, endPos:Point, curPos:Point, timer:uint):Array
		{
			var t:Number = 0;
			var temp:Number = 1 / timer;
			var varT:Number = 0;
			var a:Array = new Array();
			for (var i1:Number = 0; i1 < 1; i1 += temp)
			{
				varT = 1 - t;
				var x:Number = varT * varT * startPos.x + 2 * t * varT * curPos.x + t * t * endPos.x;
				var y:Number = varT * varT * startPos.y + 2 * t * varT * curPos.y + t * t * endPos.y;
				t = i1;
				a.push(new Point(uint(x), uint(y)));
			}
			a.push(new Point(uint(endPos.x), uint(endPos.y)));
			return a;
		}





		public static function getLine(startPos:Point, endPos:Point, timer:uint):Vector.<Point>
		{

			var pathA:Vector.<Point> = new Vector.<Point>;
			var errandX:uint = Math.abs(startPos.x - endPos.x);
			var errandY:uint = Math.abs(startPos.y - endPos.y);

			var isAddX:Boolean;
			var isAddY:Boolean;
			if (startPos.x < endPos.x)
			{
				isAddX = true;
			}
			if (startPos.y < endPos.y)
			{
				isAddY = true;
			}
			for (var i1:int = 0; i1 < timer; i1++)
			{
				var x:Number;
				var y:Number;
				if (isAddX)
				{
					x = startPos.x + (i1 / timer) * errandX;
				}
				else
				{
					x = startPos.x - (i1 / timer) * errandX;
				}
				if (isAddY)
				{
					y = startPos.y + (i1 / timer) * errandY;
				}
				else
				{
					y = startPos.y - (i1 / timer) * errandY;
				}
				pathA.push(new Point(uint(x), uint(y)));
			}
			pathA.push(new Point(uint(endPos.x), uint(endPos.y)));
			return pathA;
		}


		public static function getPoint(startPos:Point, endPos:Point, range:Number):Point
		{
			var errandX:uint = Math.abs(startPos.x - endPos.x);
			var errandY:uint = Math.abs(startPos.y - endPos.y);
			var isAddX:Boolean;
			var isAddY:Boolean;
			if (startPos.x < endPos.x)
			{
				isAddX = true;
			}
			if (startPos.y < endPos.y)
			{
				isAddY = true;
			}
			var timer:uint = uint(errandX / 2);
			var mPos:Point = new Point();
			for (var i1:int = 0; i1 < timer; i1++)
			{

				if (isAddX)
				{
					mPos.x = startPos.x + (i1 / timer) * errandX;
				}
				else
				{
					mPos.x = startPos.x - (i1 / timer) * errandX;
				}
				if (isAddY)
				{
					mPos.y = startPos.y + (i1 / timer) * errandY;
				}
				else
				{
					mPos.y = startPos.y - (i1 / timer) * errandY;
				}
				if (Point.distance(mPos, endPos) <= range)
				{
					return mPos;
				}
			}
			return null;
		}
		
		public static function getChildByName(parent:flash.display.DisplayObjectContainer, childName:String):flash.display.DisplayObject
		{
			if (parent == null)
				return null;
			var dsp:flash.display.DisplayObject;
			for (var i:int = 0; i < parent.numChildren; i++) 
			{
				dsp = parent.getChildAt(i);
				if (dsp.name == childName)
					return dsp;
			}
			return null;
		}
		
		public static function getDspByPath(rootDsp:flash.display.DisplayObjectContainer, pathStr:String, separator:String = "."):flash.display.DisplayObject
		{
			var path:Array = pathStr.split(separator);
			var parentContainer:flash.display.DisplayObjectContainer = rootDsp;
			var targetDsp:flash.display.DisplayObject;
			for (var i:int = 0; i < path.length; i++) 
			{
				targetDsp = DisplayUtil.getChildByName(parentContainer, path[i]);
				parentContainer = targetDsp as flash.display.DisplayObjectContainer;
				if (parentContainer == null)
					break;
			}
			return targetDsp;
		}
	}
}

class Callback
{
	private var _isDisposed:Boolean = false;
	
	public var callback:Function;
	public var args:Array;
	
	public function excute():void
	{
		if (callback != null)
		{
			callback.apply(null, args);
		}
	}
	
	public function resurgence():void
	{
		_isDisposed = false;
	}
	
	public function dispose():void
	{
		if (_isDisposed)
			return;
		_isDisposed = true;
		
		callback = null;
		args = null;
	}
	
	public function get isDisposed():Boolean
	{
		return _isDisposed;
	}
}