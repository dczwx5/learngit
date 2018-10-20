package QFLib.Graphics.RenderCore.starling.display
{
	import flash.geom.Rectangle;
	
	import QFLib.Graphics.RenderCore.starling.utils.DisplayUtil;
	
	import QFLib.Graphics.RenderCore.starling.textures.SubTexture;
	import QFLib.Graphics.RenderCore.starling.textures.Texture;

	/**
	 * starling 九宫格
	 *
	 * <listing><font size='2'>
	 * e.g.
	 * var scale9:Scale9Grid = new Scale9Grid(new Texture(XXX), new Rectangle(left, top, width, height));
	 * scale9.setSize(w, h);
	 * addChild(scale9);
	 * </font></listing>
	 * 
	 * @author Jave.Lin
	 * @date 2014-11-20
	 */	
	public class Scale9Grid extends Sprite
	{
		private var _image_11:Image;
		private var _image_12:Image;
		private var _image_13:Image;
		private var _image_21:Image;
		private var _image_22:Image;
		private var _image_23:Image;
		private var _image_31:Image;
		private var _image_32:Image;
		private var _image_33:Image;

		private var _originalWidth:Number;
		private var _originalHeight:Number;
		
		private var _rect:Rectangle;

		public function Scale9Grid(texture:Texture, rect:Rectangle)
		{
			super();
			_originalWidth = texture.width;
			_originalHeight = texture.height;
			_rect = rect;
			var st_11:SubTexture = new SubTexture(texture, new Rectangle(0, 0, _rect.x, _rect.y));
			var st_12:SubTexture = new SubTexture(texture, new Rectangle(_rect.x, 0, _rect.width, _rect.y));
			var st_13:SubTexture = new SubTexture(texture, new Rectangle(_rect.right, 0, _originalWidth - _rect.right, _rect.y));

			var st_21:SubTexture = new SubTexture(texture, new Rectangle(0, _rect.y, _rect.x, _rect.height));
			var st_22:SubTexture = new SubTexture(texture, new Rectangle(_rect.x, _rect.y, _rect.width, _rect.height));
			var st_23:SubTexture = new SubTexture(texture, new Rectangle(_rect.right, _rect.y, _originalWidth - _rect.right, _rect.height));

			var st_31:SubTexture = new SubTexture(texture, new Rectangle(0, _rect.bottom, _rect.x, _originalHeight - _rect.bottom));
			var st_32:SubTexture = new SubTexture(texture, new Rectangle(_rect.x, _rect.bottom, _rect.width, _originalHeight - _rect.bottom));
			var st_33:SubTexture = new SubTexture(texture, new Rectangle(_rect.right, _rect.bottom, _originalWidth - _rect.right, _originalHeight - _rect.bottom));

			_image_11 = new Image(st_11);
			_image_11.x = 0;
			_image_11.y = 0;
			addChild(_image_11);

			_image_12 = new Image(st_12);
			_image_12.x = _rect.x;
			_image_12.y = 0;
			addChild(_image_12);

			_image_13 = new Image(st_13);
			_image_13.x = _rect.right;
			_image_13.y = 0;
			addChild(_image_13);

			_image_21 = new Image(st_21);
			_image_21.x = 0;
			_image_21.y = _rect.y;
			addChild(_image_21);

			_image_22 = new Image(st_22);
			_image_22.x = _rect.x;
			_image_22.y = _rect.y;
			addChild(_image_22);

			_image_23 = new Image(st_23);
			_image_23.x = _rect.right;
			_image_23.y = _rect.y;
			addChild(_image_23);

			_image_31 = new Image(st_31);
			_image_31.x = 0;
			_image_31.y = _rect.bottom;
			addChild(_image_31);

			_image_32 = new Image(st_32);
			_image_32.x = _rect.x;
			_image_32.y = _rect.bottom;
			addChild(_image_32);

			_image_33 = new Image(st_33);
			_image_33.x = _rect.right;
			_image_33.y = _rect.bottom;
			addChild(_image_33);
			flatten();
		}

		override public function dispose():void{
			DisplayUtil.dispose3DImage(_image_11);
			_image_11 = null;
			DisplayUtil.dispose3DImage(_image_12);
			_image_12 = null;
			DisplayUtil.dispose3DImage(_image_13);
			_image_13 = null;
			DisplayUtil.dispose3DImage(_image_21);
			_image_21 = null;
			DisplayUtil.dispose3DImage(_image_22);
			_image_22 = null;
			DisplayUtil.dispose3DImage(_image_23);
			_image_23 = null;
			DisplayUtil.dispose3DImage(_image_31);
			_image_31 = null;
			DisplayUtil.dispose3DImage(_image_32);
			_image_32 = null;
			DisplayUtil.dispose3DImage(_image_33);
			_image_33 = null;
			super.dispose();
		}
		
		/**
		 * width
		 * @param value
		 *
		 */
		override public function set width(value:Number):void
		{
			if (isFlattened)
				unflatten();
			value = clampW(value);
			_image_32.width = _image_22.width = _image_12.width = value - (_rect.x + (_originalWidth - _rect.right));
			_image_33.x = _image_23.x = _image_13.x = _image_22.x + _image_22.width;
			flatten();
		}

		/**
		 * height
		 * @param value
		 *
		 */
		override public function set height(value:Number):void
		{
			if (isFlattened)
				unflatten();
			value = clampH(value);
			_image_23.height = _image_22.height = _image_21.height = value - (_rect.y + (_originalHeight - _rect.bottom));
			_image_33.y = _image_32.y = _image_31.y = _image_21.y + _image_21.height;
			flatten();
		}
		
		private function clampW(value:Number):Number
		{
			return Math.max(_rect.x + (_originalWidth - _rect.right), value);
		}
		
		private function clampH(value:Number):Number
		{
			return Math.max(_rect.y + (_originalHeight - _rect.bottom), value);
		}
		
		public function setSize(w:Number, h:Number):void
		{
			if (isFlattened)
				unflatten();
			
			w = clampW(w);
			h = clampH(h);
			
			_image_32.width = _image_22.width = _image_12.width = w - (_rect.x + (_originalWidth - _rect.right));
			_image_33.x = _image_23.x = _image_13.x = _image_22.x + _image_22.width;
			
			_image_23.height = _image_22.height = _image_21.height = h - (_rect.y + (_originalHeight - _rect.bottom));
			_image_33.y = _image_32.y = _image_31.y = _image_21.y + _image_21.height;
			
			flatten();
		}
	}
}
