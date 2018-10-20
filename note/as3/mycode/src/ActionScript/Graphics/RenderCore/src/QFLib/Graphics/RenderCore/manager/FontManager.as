package QFLib.Graphics.RenderCore.manager
{
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class FontManager
	{
		public static var GAME_FONT_NUM:String;
		
		public function FontManager()
		{
		}
		
		public static function setup():void
		{
			Font.registerFont(gameFontNum);
			
			var f:Font = new gameFontNum();
			GAME_FONT_NUM = f.fontName;
			f = null;
		}
		
		/**应用游戏设定的嵌入字体*/
		public static function applyGameFont(tf:TextField , fontName:String = null):void
		{
			if(fontName == null) fontName = GAME_FONT_NUM
			tf.embedFonts = true;
			var textFormat:TextFormat = tf.defaultTextFormat;
			textFormat.font = fontName;
			tf.defaultTextFormat = textFormat;
			tf.setTextFormat(textFormat);
		}
	}
}