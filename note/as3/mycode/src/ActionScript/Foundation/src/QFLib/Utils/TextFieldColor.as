////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	/**
	 * 选择文本 设置选中背景色
	 * @author lyman
	 * 
	 */	
	public class TextFieldColor
	{
		private static const byteToPerc:Number = 1 / 0xff;
		
		private var _textField:TextField;
		
		private var _textColor:uint;
		
		private var _selectedColor:uint;
		
		private var _selectionColor:uint;
		
		private var _colorMatrixFilter:ColorMatrixFilter;
		
		public function TextFieldColor(textField:TextField, textColor:uint = 0x000000, selectionColor:uint = 0x000000, selectedColor: uint = 0x000000)
		{
			
			_textField = textField;
			
			_colorMatrixFilter = new ColorMatrixFilter();
			
			_textColor = textColor;
			
			_selectionColor = selectionColor;
			
			_selectedColor = selectedColor;
			
			updateFilter();
			
		}
		
		
		
		public function set textField(tf:TextField):void {
			
			_textField = tf;
			
		}
		
		public function get textField():TextField {
			
			return _textField;
			
		}
		
		public function set textColor(c:uint):void {
			
			_textColor = c;
			
			updateFilter();
			
		}
		
		public function get textColor():uint {
			
			return _textColor;
			
		}
		
		public function set selectionColor(c:uint):void {
			
			_selectionColor = c;
			
			updateFilter();
			
		}
		
		public function get selectionColor():uint {
			
			return _selectionColor;
			
		}
		
		public function set selectedColor(c:uint):void {
			
			_selectedColor = c;
			
			updateFilter();
			
		}
		
		public function get selectedColor():uint {
			
			return _selectedColor;
			
		}
		
		private function updateFilter():void {
			
			
			_textField.textColor = 0xff0000;
			
			
			var o:Array = splitRGB(_selectionColor);
			
			var r:Array = splitRGB(_textColor);
			
			var g:Array = splitRGB(_selectedColor);
			
			
			
			var ro:int = o[0];
			
			var go:int = o[1];
			
			var bo:int = o[2];
			
			
			
			var rr:Number = ((r[0] - 0xff) - o[0]) * byteToPerc + 1;
			
			var rg:Number = ((r[1] - 0xff) - o[1]) * byteToPerc + 1;
			
			var rb:Number = ((r[2] - 0xff) - o[2]) * byteToPerc + 1;
			
			
			
			var gr:Number = ((g[0] - 0xff) - o[0]) * byteToPerc + 1 - rr;
			
			var gg:Number = ((g[1] - 0xff) - o[1]) * byteToPerc + 1 - rg;
			
			var gb:Number = ((g[2] - 0xff) - o[2]) * byteToPerc + 1 - rb;
			
			
			
			_colorMatrixFilter.matrix = [rr, gr, 0, 0, ro, rg, gg, 0, 0, go, rb, gb, 0, 0, bo, 0, 0, 0, 1, 0];
			
			var filters:Array = [_colorMatrixFilter];
			if(_textField.filters && _textField.filters.length > 0)
			{
				filters = filters.concat(_textField.filters);
			}
			_textField.filters = filters;
		}
		
		
		
		private static function splitRGB(color:uint):Array
		{
			return [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff];
		}
	}
}