package QFLib.Graphics.RenderCore.starling.utils
{
	import flash.geom.Point;

	public class Util {
		
		[Inline]
		public static function nextPowerOfTwo(number:int):int {
			number--;
			number |= number >> 1;
			number |= number >> 2;
			number |= number >> 4;
			number |= number >> 8;		
			// max texture size is 4096, skip one step
			// number |= number >> 16;
			
			return ++number;
		}
		
		[Inline]
		public static function isPot2(value:int):Boolean
		{
			return (value > 0) && (value & (value - 1)) == 0;
		}
		
		[Inline]
		public static function isPot(width:int, height:int):Boolean {
			return width == nextPowerOfTwo(width) && height == nextPowerOfTwo(height);
		}
		
		[Inline]
		public static function rad2deg(rad:Number):Number {
			return 180.0 * rad / Math.PI;
		}
		
		[Inline]
		public static function deg2rad(deg:Number):Number {
			return Math.PI * deg / 180.0;
		}
		
		[Inline]
		public static function random(base:Number, variance:Number, random:Random):Number {
			if (random)
				return base + variance * (random.next() * 2.0 - 1.0);
			return base + variance * (Math.random() * 2.0 - 1.0);
		}
		
		[Inline]
		public static function random2(base:Number, variance:Number, random:Random):Number {
			return base + variance * (random.next() * 2.0 - 1.0); // unnecessary judge random is null, raise performance, special using for ps system
		}
		
		[Inline]
		public static function randomRange(base:Number, variance:Number, random:Random):Number {
			if (random)
				return base + variance * (random.next() - 1.0);
			return base + variance * (Math.random() - 1.0);
		}
		
		[Inline]
		public static function lerp(x:Number, y:Number, t:Number):Number {
			return x + (y - x) * t;
		}
		
		[Inline]
		public static function lerpi(x:int, y:int, t:Number):int {
			return x + int((y - x) * t);
		}
		
		/**
		 * Forces a numeric value into a specified range.
		 * 
		 * @param value		The value to force into the range.
		 * @param minimum	The minimum bound of the range.
		 * @param maximum	The maximum bound of the range.
		 * @return			A value within the specified range.
		 */
		[Inline]
		public static function clamp(value:Number, minimum:Number, maximum:Number):Number {
//			return Math.min(maximum, Math.max(minimum, value));
			return value < minimum ? minimum : (value > maximum ? maximum : value);
		}
		
		[Inline]
		public static function randomBetween(x:Number, y:Number, random:Random):Number {
			if (random)
				return x + (y - x) * random.next();
			return x + (y - x) * Math.random();
		}
		
		[Inline]
		public static function randomBetween2(x:Number, y:Number, random:Random):Number {
			return x + (y - x) * random.next(); // unnecessary judge random is null, raise performance, special using for ps system
		}
		
		[Inline]
		public static function randomBetweeni(x:int, y:int):int {
			return x + int((y - x) * Math.random());
		}
		
		/**
		 * Rounds a number to a certain level of precision. Useful for limiting the number of
		 * decimal places on a fractional number.
		 * 
		 * @param		number		the input number to round.
		 * @param		precision	the number of decimal digits to keep
		 * @return		the rounded number, or the original input if no rounding is needed
		 * 
		 * @see Math#round
		 */
		[Inline]
		public static function roundToPrecision(number:Number, precision:int = 0):Number {
			var decimalPlaces:Number = Math.pow(10, precision);
			return Math.round(decimalPlaces * number) / decimalPlaces;
		}
		
		/**
		 * Rounds a Number to the nearest multiple of an input. For example, by rounding
		 * 16 to the nearest 10, you will receive 20. Similar to the built-in function Math.round().
		 * 
		 * @param	numberToRound		the number to round
		 * @param	nearest				the number whose mutiple must be found
		 * @return	the rounded number
		 * 
		 * @see Math#round
		 */
		[Inline]
		public static function roundToNearest(number:Number, nearest:Number = 1):Number {
			if (nearest == 0) return number;
			
			var roundedNumber:Number = Math.round(roundToPrecision(number / nearest, 10)) * nearest;
			return roundToPrecision(roundedNumber, 10);
		}
		
		/**
		 * Rounds a Number <em>down</em> to the nearest multiple of an input. For example, by rounding
		 * 16 down to the nearest 10, you will receive 10. Similar to the built-in function Math.floor().
		 * 
		 * @param	numberToRound		the number to round down
		 * @param	nearest				the number whose mutiple must be found
		 * @return	the rounded number
		 * 
		 * @see Math#floor
		 */
		[Inline]
		public static function roundDownToNearest(number:Number, nearest:Number = 1):Number {
			if (nearest == 0) return number;
			return Math.floor(roundToPrecision(number / nearest, 10)) * nearest;
		}
		
		[Inline]
		public static function pointGetPerp(src:Point, result:Point):Point
		{
			if(!result) result = new Point();
			result.setTo(-src.y, src.x);
			return result;
		}
		
		[Inline]
		public static function pointDot(p1:Point, p2:Point):Number
		{
			return p1.x*p2.x + p1.y*p2.y;
		}
		
		[Inline]
		public static function pointMidPoint(p1:Point, p2:Point, result:Point):Point
		{
			if(!result) result = new Point();
			result.setTo((p1.x+p2.x)*0.5, (p1.y+p2.y)*0.5);
			return result;
		}
		
		[Inline]
		public static function pointGetSqLength(p1:Point, p2:Point, buf:Point):Number
		{
			pointSubtract(p1, p2, buf);
			return pointDot(buf, buf);
		}
		
		[Inline]
		public static function pointSubtract(p1:Point, p2:Point, buf:Point):Point
		{
			buf.setTo(p1.x-p2.x, p1.y-p2.y);
			return buf;
		}
		
		public static function comapreNumberList(a:Vector.<Number>, b:Vector.<Number>):Boolean
		{
			if (a.length != b.length)
			{
				return false;
			}
			
			var len:int = a.length;
			for (var index:int = 0; index < len; ++index)
			{
				if (a[index] != b[index])
				{
					return false;
				}
			}
			
			return true;
		}
	}
}