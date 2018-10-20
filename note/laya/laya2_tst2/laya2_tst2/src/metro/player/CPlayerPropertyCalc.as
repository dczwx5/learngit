package metro.player
{
	/**
	 * ...
	 * @author
	 */
	public class CPlayerPropertyCalc{
		public function CPlayerPropertyCalc(){
			
		}

		

		public static function valueToString(value:Number) : String {
			if (isNaN(value)) {
				return "0";
			}
	
			if (!_valueLimitMap) {
				_valueMap_div1000_and_div_by_1 = new Array(_convertMap.length); // [1, 0.001, 0.0000001]
				_valueLimitMap = new Array(_convertMap.length); 
				for (var i:int = 0; i < _convertMap.length; i++) {
					_valueLimitMap[i] = Math.pow(1000, (i+1));
					_valueMap_div1000_and_div_by_1[i] = (_valueLimitMap[i]*0.001);
				}
			}

			var ret:String;
			var time:int = 0;
			while (true) {
				if (value < _valueLimitMap[time]) {
					value = value / _valueMap_div1000_and_div_by_1[time];
					ret = value.toFixed(2) + _convertMap[time];
					break;
				}
				time++;
			}
		
			return ret;
		}

		private static var _valueLimitMap:Array; // [1000, 1000000, 1000000000...]
		private static var _valueMap_div1000_and_div_by_1:Array; // [1, 1000, 1000000] -> _valueMap对应元素/1000, 再被1除
	
		private static const _convertMap:Array = ["", "K", "M", "B", "T",
			"aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj", "ak", "al", "am", "an", 
			"ao", "ap", "aq", "ar", "as", "at", "au", "av", "aw", "ax", "ay", "az", 

			"ba", "bb", "bc", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bk", "bl", "bm", "bn", 
			"bo", "bp", "bq", "br", "bs", "bt", "bu", "bv", "bw", "bx", "by", "bz", 

			"ca", "cb", "cc", "cd", "ce", "cf", "cg", "ch", "ci", "cj", "ck", "cl", "cm", "cn", 
			"co", "cp", "cq", "cr", "cs", "ct", "cu", "cv", "cw", "cx", "cy", "cz",

			"da", "db", "dc", "dd", "de", "df", "dg", "dh", "di", "dj", "dk", "dl", "dm", "dn", 
			"do", "dp", "dq", "dr"];
	}

}