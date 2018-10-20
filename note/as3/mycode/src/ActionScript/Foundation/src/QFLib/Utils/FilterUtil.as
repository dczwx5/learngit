////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;

	/**
	 * 滤镜工具 
	 * @author lyman
	 * 
	 */	
	public class FilterUtil
	{
		  
		private static const RED:Number = 0.3086;
		private static const GREEN:Number = 0.6094;
		private static const BLUE:Number = 0.0820;
		
		
		public function FilterUtil()
		{
		}
		
		public static const EMPTY_ARRAY:Array = [];
		
		public static const BlackGlowFilter:GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 12); 
		public static const WhiteGlowFilter:GlowFilter = new GlowFilter(0xffffff, 1, 2, 2, 12); 
		public static const GreenGlowFilter:GlowFilter = new GlowFilter(0xff0000, 1, 2, 2, 12); 
		public static const YellowGlowFilter:GlowFilter = new GlowFilter(0xffff00, 1, 2, 2, 12); 
		
		public static const FILTER_BLACK:Array = [BlackGlowFilter];
		
		public static const FILTER_WHITE:Array = [WhiteGlowFilter];
		
		public static const FILTER_GREEN:Array = [GreenGlowFilter];

		private static var _ALL_WHITE:Array;
		public static function get ALL_WHITE_FILTER() : Array {
			if (_ALL_WHITE == null) {
				var mat:Array = new Array();
				mat = mat.concat([1,1,1,1,1]);
				mat = mat.concat([1,1,1,1,1]);
				mat = mat.concat([1,1,1,1,1]);
				mat = mat.concat([0,0,0,1,0]);
				var colorFilter:ColorMatrixFilter = new ColorMatrixFilter(mat);
				_ALL_WHITE = [colorFilter];
			}
			return _ALL_WHITE;
		}
		private static var _ALL_BLACK:Array;
		public static function get ALL_BLACK_FILTER() : Array {
			if (_ALL_BLACK == null) {
				var mat:Array = new Array();
				mat = mat.concat([0,0,0,0,0]);
				mat = mat.concat([0,0,0,0,0]);
				mat = mat.concat([0,0,0,0,0]);
				mat = mat.concat([0,0,0,1,0]);
				var colorFilter:ColorMatrixFilter = new ColorMatrixFilter(mat);
				_ALL_BLACK = [colorFilter];
			}
			return _ALL_BLACK;
		}
		/**
		 * 黑白滤镜 
		 * @return 
		 * 
		 */
		
		public static const bAndWfilter:Array = [FilterUtil.bAndwFilter];
		
		private static var _bAndwFilter:ColorMatrixFilter;
		public static function get bAndwFilter():ColorMatrixFilter
		{
			if(!_bAndwFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([0.3086,0.6094,0.0820,0,0]);
				colorMatrix = colorMatrix.concat([0.3086,0.6094,0.0820,0,0]);
				colorMatrix = colorMatrix.concat([0.3086,0.6094,0.0820,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_bAndwFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _bAndwFilter;
		}
		
		/**
		 * 颜色反向滤镜
		 * @return 
		 * 
		 */
		private static var _colorReverseFilter:ColorMatrixFilter
		public static function get colorReverse():ColorMatrixFilter
		{
			if(!_colorReverseFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([-1,0,0,0,255]);
				colorMatrix = colorMatrix.concat([0,-1,0,0,255]);
				colorMatrix = colorMatrix.concat([0,0,-1,0,255]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_colorReverseFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _colorReverseFilter;
		}
		
		/**
		 * 亮度调节 滤镜
		 * @param value (-255 - 255之间)
		 * @return 
		 * 
		 */	
		private static var _brightnessControl:ColorMatrixFilter;
		public static function brightnessControl(value:int):ColorMatrixFilter
		{
			if(!_brightnessControl)
			{
				if(value < -255)
				{
					value = -255;
				}
				if(value > 255)
				{
					value = 255;
				}
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([1,0,0,0,value]);
				colorMatrix = colorMatrix.concat([0,1,0,0,value]);
				colorMatrix = colorMatrix.concat([0,0,1,0,value]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_brightnessControl = new ColorMatrixFilter(colorMatrix);
			}
			return _brightnessControl;
		}
		
		private static var _lightControl:ColorMatrixFilter;
		public static function lightControl(value:Number):ColorMatrixFilter
		{
			if(!_lightControl)
			{
				if(value < 0)
				{
					value = 0;
				}
				if(value > 1)
				{
					value = 1;
				}
				var colorMatrix:Array = [];
//				colorMatrix = colorMatrix.concat([value,0,0,0,255 * (value - 1)]);
//				colorMatrix = colorMatrix.concat([0,value,0,0,255 * (value - 1)]);
//				colorMatrix = colorMatrix.concat([0,0,value,0,255 * (value - 1)]);
				// [a,0,0,0,b]
				// channelColor = srcPixelChannelColor * a + b
				colorMatrix = colorMatrix.concat([value,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,value,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,value,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_lightControl = new ColorMatrixFilter(colorMatrix);
			}
			return _lightControl;
		}
		
		/**
		 * 调整饱和度 
		 * @param value(建议在0-2之间)
		 * @return 
		 * 
		 */
		private static var _colorSaturationFilter:ColorMatrixFilter;
		public static function colorSaturationFilter(value:uint):ColorMatrixFilter
		{
			if(!_colorSaturationFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([0.3086*(1-value) + value, 0.6094*(1-value), 0.0820*(1-value), 0, 0]);
				colorMatrix = colorMatrix.concat([0.3086*(1-value), 0.6094*(1-value) + value, 0.0820*(1-value), 0, 0])
				colorMatrix = colorMatrix.concat([0.3086*(1-value), 0.6094*(1-value), 0.0820*(1-value) + value, 0, 0]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_colorSaturationFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _colorSaturationFilter;
		}
		
		/**
		 * 对比度 
		 * @param value(0-10之间)
		 * @return 
		 * 
		 */
		private static var _colorContrastFilter:ColorMatrixFilter;
		public static function colorContrastFilter(value:int):ColorMatrixFilter
		{
			if(!_colorContrastFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([value,0,0,0,128*(1-value)]);
				colorMatrix = colorMatrix.concat([0,value,0,0,128*(1-value)]);
				colorMatrix = colorMatrix.concat([0,0,value,0,128*(1-value)]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_colorContrastFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _colorContrastFilter;
		}
		
		/**
		 * 调整阀值 
		 * @param value(0-255之间)
		 * @return 
		 * 
		 */
		private static var _colorThresholdFilter:ColorMatrixFilter;
		public static function colorThresholdFilter(value:int):ColorMatrixFilter
		{
			if(_colorThresholdFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([0.3086*256,0.6094*256,0.0820*256,0,-256*value]);
				colorMatrix = colorMatrix.concat([0.3086*256,0.6094*256,0.0820*256,0,-256*value]);
				colorMatrix = colorMatrix.concat([0.3086*256,0.6094*256,0.0820*256,0,-256*value]);
				colorMatrix = colorMatrix.concat([0, 0, 0, 1, 0]);
				_colorThresholdFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _colorThresholdFilter;
		}
		
		/**
		 * 只显示红色 
		 * @return 
		 * 
		 */
		private static var _soleRedFilter:ColorMatrixFilter;
		public static function get soleRedFilter():ColorMatrixFilter
		{
			if(!_soleRedFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([1,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_soleRedFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _soleRedFilter;
		}
			
		/**
		 * 只显示绿色 
		 * @return 
		 * 
		 */
		private static var _soleGreenFilter:ColorMatrixFilter;
		public static function get soleGreenFilter():ColorMatrixFilter
		{
			if(!_soleGreenFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([0,0,0,0,0]);
				colorMatrix = colorMatrix.concat([1,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_soleGreenFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _soleGreenFilter;
		}
		
		/**
		 * 只显示蓝色 
		 * @return 
		 * 
		 */
		private static var _soleBlueFilter:ColorMatrixFilter;
		public static function get soleBlueFilter():ColorMatrixFilter
		{
			if(!_soleBlueFilter)
			{
				var colorMatrix:Array = [];
				colorMatrix = colorMatrix.concat([0,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,0,0]);
				colorMatrix = colorMatrix.concat([1,0,0,0,0]);
				colorMatrix = colorMatrix.concat([0,0,0,1,0]);
				_soleBlueFilter = new ColorMatrixFilter(colorMatrix);
			}
			return _soleBlueFilter;
		}
		
		/**
		 * 色相偏移
		 * @return 
		 * 
		 */
		public static function createHueFilter(n:Number):ColorMatrixFilter
		{
			const p1:Number = Math.cos(n * Math.PI / 180);
			const p2:Number = Math.sin(n * Math.PI / 180);
			const p4:Number = 0.213;
			const p5:Number = 0.715;
			const p6:Number = 0.072;
			return new ColorMatrixFilter([p4 + p1 * (1 - p4) + p2 * (0 - p4), p5 + p1 * (0 - p5) + p2 * (0 - p5), p6 + p1 * (0 - p6) + p2 * (1 - p6), 0, 0, p4 + p1 * (0 - p4) + p2 * 0.143, p5 + p1 * (1 - p5) + p2 * 0.14, p6 + p1 * (0 - p6) + p2 * -0.283, 0, 0, p4 + p1 * (0 - p4) + p2 * (0 - (1 - p4)), p5 + p1 * (0 - p5) + p2 * p5, p6 + p1 * (1 - p6) + p2 * p6, 0, 0, 0, 0, 0, 1, 0]);
		}
		
		/**
		 * 染色
		 * @return 
		 * 
		 */
		public static function tint(color:uint, percent:Number = 0.5):ColorMatrixFilter{
			var r:uint = color >> 16 & 0xFF;
			var g:uint = color >> 8 & 0xFF;
			var b:uint = color & 0xFF;
			var matrix:Array = [
				r/255, percent, 0.11, 0, 0,
				g/255, percent, 0.11, 0, 0,
				b/255, percent, 0.11, 0, 0,
				0,     0,    0,    1, 0
			];
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			return filter;
		}
		
		/**
		 * 实现TextField选择文本后选中的背景颜色及选择后的文本颜色 
		 */		
		private static const byteToPerc:Number = 1 / 0xff;
		public static function setTextFieldSelectionColor(textField:TextField,textColor:uint,textSelectedBackGroundColor:uint,textSelectedColor:uint):void
		{
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			
			textField.textColor = 0xff0000;
			
			var o:Array = splitRGB(textSelectedBackGroundColor);
			
			var r:Array = splitRGB(textColor);
			
			var g:Array = splitRGB(textSelectedColor);
			
			
			var ro:int = o[0];
			
			var go:int = o[1];
			
			var bo:int = o[2];
			
			
			var rr:Number = ((r[0] - 0xff) - o[0]) * byteToPerc + 1;
			
			var rg:Number = ((r[1] - 0xff) - o[1]) * byteToPerc + 1;
			
			var rb:Number = ((r[2] - 0xff) - o[2]) * byteToPerc + 1;
			
			
			var gr:Number = ((g[0] - 0xff) - o[0]) * byteToPerc + 1 - rr;
			
			var gg:Number = ((g[1] - 0xff) - o[1]) * byteToPerc + 1 - rg;
			
			var gb:Number = ((g[2] - 0xff) - o[2]) * byteToPerc + 1 - rb;
			
			
			colorMatrixFilter.matrix = [rr, gr, 0, 0, ro, rg, gg, 0, 0, go, rb, gb, 0, 0, bo, 0, 0, 0, 1, 0];
			
			var filters:Array = [colorMatrixFilter];
			if(textField.filters && textField.filters.length > 0)
			{
				filters = filters.concat(textField.filters);
			}
			textField.filters = filters;
		}
		
		private static function splitRGB(color:uint):Array
		{
			return [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff];
		}
	}
}