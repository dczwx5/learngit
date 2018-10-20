//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	import flash.utils.ByteArray;
	
	/**
	 * 字符串功能
	 * @author lyman
	 * 
	 */	
	public class StringUtil
	{
		private static const HEX_Head:String = "0x";//十六进制数字表示头
	
		/**
		 * 在不够指定长度的字符串前补零
		 * @param str 需要在前面补零的字符串
		 * @param len 总长度
		 * @return
		 *
		 */
		public static function renewZero(str:String, len:int):String
		{
			var bul:String = "";
			var strLen:int = str.length;
			if (strLen < len)
			{
				for (var i:int = 0; i < len - strLen; i++)
				{
					bul += "0";
				}
				return bul + str;
			}
			else
			{
				return str;
			}
		}
		
		/**
		 * 格式数字秒表类型输出 00:00
		 * @param value
		 * @param length
		 * @return
		 *
		 */
		public static function stopwatchFormat(value:int):String
		{
			var minute:int = value / 60;
			var second:int = value % 60;
			var strM:String = (minute < 10) ? ("0" + minute.toString()) : minute.toString();
			var strS:String = (second < 10) ? ("0" + second.toString()) : second.toString();
			return strM + ":" + strS;
		}

		/**
		 * 日期格式
		 * @param value 时间
		 * @param sm    格式间隔符
		 * @return
		 *
		 */
		public static function timeFormat(value:Number, sm:String = "-",dataSm:String = ":"):String
		{
			var t:Date = new Date(value);
			var year:String = t.getFullYear().toString();
			var month:String = fill(2,(t.getMonth() + 1).toString());
			var day:String = fill(2,t.getDate().toString());
			var hours:String = fill(2,t.getHours().toString());
			var minutes:String = fill(2,t.getMinutes().toString());
			var seconds:String = fill(2,t.getSeconds().toString());
			var milliSeconds:Number = t.milliseconds;
			return year + sm + month + sm + day + " " + hours + dataSm + minutes + dataSm + seconds + "." + milliSeconds;
		}
		
		public static function timeFormat1(value:Number, sm:String = "-",dataSm:String = ":"):String
		{
			var t:Date = new Date(value);
			var year:String = t.getFullYear().toString();
			var month:String = fill(2,(t.getMonth() + 1).toString());
			var day:String = fill(2,t.getDate().toString());
			var hours:String = fill(2,t.getHours().toString());
			var minutes:String = fill(2,t.getMinutes().toString());
			return year + sm + month + sm + day + " " + hours + dataSm + minutes ;
		}

		public static function timeFormat2(value:Number,dataSm:String = ":"):String
		{
			var t:Date = new Date(value);
			var hours:String = fill(2,t.getHours().toString());
			var minutes:String = fill(2,t.getMinutes().toString());
			return hours + dataSm + minutes ;
		}

		/**
		 * 年月日 
		 * @param value
		 * @param sm
		 * @param dataSm
		 * @return 
		 * 
		 */		
		public static function dayFormat(value:Number, sm:String = "-"):String
		{
			var t:Date = new Date(value);
			var year:String = t.getFullYear().toString();
			var month:String = fill(2,(t.getMonth() + 1).toString());
			var day:String = fill(2,t.getDate().toString());
			return year + sm + month + sm + day;
		}
		
		public static function timeFormatByTime(v:Number,separator:String = ":"):String
		{
			var t:Date = new Date(v);
			//var year:String = t.getFullYear().toString();
			//var month:String = fill(2,(t.getMonth() + 1).toString());
			//var day:String = fill(2,t.getDate().toString());
			
			var hours:String = t.getHours().toString();
			var minutes:String = t.getMinutes().toString();
			var seconds:String = t.getSeconds().toString();
			
			return  hours + separator + minutes + separator + seconds ;
		}
		
		public static function fill(max:uint,num:String,fillStr:String = "0"):String
		{
			var length:uint = num.length;
			
			if(length < max)
			{
				for(var i1:int = 0, len:int = max - length; i1 < len; ++i1)
				{
					num = fillStr + num;
				}
			}
			return num;
		}
		
		/**
		 * 十进制数字转为IP地址格式 127.0.0.1
		 * @param a
		 * @return 
		 * 
		 */		
		public static function uintToIp(v:uint):String
		{
			var str:String = v.toString(16);
			var ip1:String = uint(HEX_Head+str.slice(0,2)).toString();
			var ip2:String = uint(HEX_Head+str.slice(2,4)).toString();
			var ip3:String = uint(HEX_Head+str.slice(4,6)).toString();
			var ip4:String = uint(HEX_Head+str.slice(6)).toString();
			return ip1+"."+ip2+"."+ip3+"."+ip4;
		}
		
		/**
		 * 十六进制数字转为IP地址格式
		 * @param a
		 * @return 
		 * 
		 */		
		public static function hexToIp(a:uint):String
		{
			//return (a>>24).toString()+"."+((a>>16)%256).toString()+"."+((a>>8)%256).toString()+"."+(a%256).toString();
			var by:ByteArray = new ByteArray();
			by.writeUnsignedInt(a);
			by.position = 0;
			var str:String = "";
			for(var i:uint = 0;i<4;++i)
			{
				str +=  by.readUnsignedByte().toString()+".";
			}
			return str.substr(0,str.length-1);
		}
		
		/**
		 * IP地址格式转为十进制数字 
		 * @return i
		 * 
		 */		
		public static function ipToUint(i:String):uint
		{
			var arr:Array = i.split(".");
			var str:String = HEX_Head;
			arr.forEach(function(item:String,index:int,array:Array):void
			{
				str += uint(item).toString(16);
			});
			return uint(str);
		}
		
		/**
		 * 对比两个字符串 
		 * @param s1
		 * @param s2
		 * @param caseSensitive 是否区分大小写
		 * @return 
		 * 
		 */		
		public static function stringsAreEqual(s1:String, s2:String, caseSensitive:Boolean):Boolean
		{
			if (caseSensitive)
			{
				return (s1 == s2);
			}
			else
			{
				return (s1.toUpperCase() == s2.toUpperCase());
			}
		}
		
		public static function trimAll(str:String):String 
		{
			return str.replace(/([ 　]{1})/g,"");
		}
		
		/**
		 * 去掉两边空格 
		 * @param input
		 * @return 
		 * 
		 */		
		public static function trim(input:String):String
		{
			return StringUtil.leftTrim(StringUtil.rightTrim(input));
		}
		
		/**
		 * 去掉左边空格 
		 * @param input
		 * @return 
		 * 
		 */		
		public static function leftTrim(input:String):String
		{
			var size:Number = input.length;
			for (var i:Number = 0; i < size; ++i)
			{
				if (input.charCodeAt(i) > 32)
				{
					return input.substring(i);
				}
			}
			return "";
		}
		
		/**
		 * 去掉右边空格 
		 * @param input
		 * @return 
		 * 
		 */		
		public static function rightTrim(input:String):String
		{
			var size:Number = input.length;
			for (var i:Number = size; i > 0; --i)
			{
				if (input.charCodeAt(i - 1) > 32)
				{
					return input.substring(0, i);
				}
			}

			return "";
		}
		
		/**
		 * 一个字符串从开头起是否有指定的字符串 
		 * @param input
		 * @param prefix
		 * @return 
		 * 
		 */		
		public static function beginsWith(input:String, prefix:String):Boolean
		{
			return (prefix == input.substring(0, prefix.length));
		}
		
		/**
		 * 一个字符串从结尾起是否有指定的字符串 
		 * @param input
		 * @param suffix
		 * @return 
		 * 
		 */		
		public static function endsWith(input:String, suffix:String):Boolean
		{
			return (suffix == input.substring(input.length - suffix.length));
		}
		
		/**
		 * 移除字符串中指定的字符串 
		 * @param input
		 * @param remove
		 * @return 
		 * 
		 */		
		public static function remove(input:String, remove:String):String
		{
			return StringUtil.replace(input, remove, "");
		}
		
		public static function startWith(srcStr:String, widthStr:String):Boolean
		{
			if (isNullOrEmpty(srcStr) || isNullOrEmpty(widthStr)) return false;
			if (srcStr.length < widthStr.length) return false;
			return srcStr.substr(0, widthStr.length) == widthStr;
		}
		
		public static function format(str:String, ...args):String {
			for(var i:int = 0; i<args.length; ++i){
//				str = str.replace(new RegExp("\\{" + i + "\\}", "gm"), args[i]);
				str = str.replace("{" + i + "}", args[i]);
			}
			return str;
		}
		
		public static function formatName(str:String, obj:Object):String {  
			for (var name:String in obj){  
				str = str.replace(new RegExp("\\{" + name + "\\}", "gm"), obj[name]);
//				str = str.replace("{" + name + "}", obj[name]);
			}
			return str;  
		}
		
		[inline]
		public static function isNullOrEmpty(str:String):Boolean
		{
			return str == null || str == "";
		}
		
		public static function replace(input:String, replace:String, replaceWith:String):String
		{
			//change to StringBuilder
			var sb:String = new String();
			var found:Boolean = false;

			var sLen:Number = input.length;
			var rLen:Number = replace.length;

			for (var i:Number = 0; i < sLen; ++i)
			{
				if (input.charAt(i) == replace.charAt(0))
				{
					found = true;
					for (var j:Number = 0; j < rLen; ++j)
					{
						if (!(input.charAt(i + j) == replace.charAt(j)))
						{
							found = false;
							break;
						}
					}

					if (found)
					{
						sb += replaceWith;
						i = i + (rLen - 1);
						continue;
					}
				}
				sb += input.charAt(i);
			}
			return sb;
		}

		public static function stringHasValue(s:String):Boolean
		{
			return (s != null && s.length > 0);
		}
		
		/**
		 * 将字符串转化为字节数组 
		 * @param s
		 * @param length
		 * @return 
		 * 
		 */		
		public static function toByteArray(s:String,length:uint):ByteArray
		{
			var _byte:ByteArray = new ByteArray();
			_byte.writeUTFBytes(s);
			_byte.length = length;
			_byte.position = 0;
			return _byte;
		}
		
		/**
		 * 判断一个字符串中是否包含中文字符 
		 * @param str
		 * @return 
		 * 
		 */		
		public static function containsChinese(str:String):Boolean
		{
			var ex:RegExp =/[\u4e00-\u9fa5]/;
			return ex.test(str);
		}
		
		/**
		 * 将秒格式化显示为　时：分：秒
		 */		
		public static function formatTime(second:int):String
		{
			if(second <= 0)
			{
				second = 0;
			}
			var hour:int = Math.floor(second / 3600);
			second = second % 3600;
			var min:int = Math.floor(second / 60);
			second = second % 60;
			return renewZero(hour.toString() , 2) + ":" + renewZero(min.toString() , 2) + ":" + renewZero(second.toString() , 2);
		}
		
		/**
		 * 将秒格式化显示为　xx小时xx分钟xx秒
		 */		
		public static function formatTimeToString(second:int):String
		{
			if(second <= 0)
			{
				second = 0;
			}
			var hour:int = Math.floor(second / 3600);
			second = second % 3600;
			var min:int = Math.floor(second / 60);
			second = second % 60;
			return renewZero(hour.toString() , 2) + "小时" + renewZero(min.toString() , 2) + "分钟" + renewZero(second.toString() , 2)+"秒";
		}
		
		/**
		 * 将秒格式化显示为　x小时x分（如果分为0则不显示）
		 */		
		public static function formatTimeToString2(second:int ):String
		{
			if(second <= 0)
			{
				second = 0;
			}
			var hour:int = Math.floor(second / 3600);
			second = second % 3600;
			var min:int = Math.floor(second / 60);
			second = second % 60;
			if( min == 0 ) return hour+ "小时";
			return hour + "小时" + min + "分钟";
		}
		
		/**
		 * 将秒格式化显示为　xx分xx秒（如果分为0则不显示）
		 */		
		public static function formatTimeMs2(second:int ):String
		{
			if(second <= 0)
				second = 0;
			var min:int = Math.floor(second / 60);
			second = second % 60;
			if (min == 0) return second+ "秒";
			return min + "分" + second + "秒";
		}
		
		/**
		 * 如果second小于60，返回x秒
		 * 如果second是60的整数倍，返回x分
		 * 否则显示x分x秒
		 * */
		public static function formatTimeMs3(second:int):String
		{
			var timeStr:String;
			if(second < 60)
			{
				timeStr = second + "秒";
			}
			else
			{
				if (second%60 != 0)
					timeStr = int(second/60) + "分" + (second%60) + "秒"; 
				else
					timeStr = int(second/60) + "分钟";
				
			}
			return timeStr;
		}
		
		/**
		 * 将秒格式化显示为　分：秒
		 * Ms :Min Second
		 */	
		public static function formatTimeMs(second:int):String
		{
			if(second <= 0)
			{
				second = 0;
			}
			var sec:int = second % 60;
			var min:int = Math.floor(second / 60);
			return  renewZero(min.toString() , 2) + ":" + renewZero(sec.toString() , 2);
		}
		
		/**
		 * 将秒格式化显示为　分
		 * Ms :Min Second
		 */	
		public static function formatTimeM(second:int):String
		{
			if(second <= 0)
			{
				second = 0;
			}
			var sec:int = second % 60;
			var min:int = Math.round(second / 60 );
			if (int(second / 60) == 0)
			{
				return  renewZero(sec.toString() , 2);
			}
			else
			{
				return  renewZero(min.toString() , 2);
			}
			
		}
		
		/**
		 * 头尾倒置字符串
		 * @param str     要操作的字符串
		 * @return 
		 */
		public static function reverseStr(str:String):String
		{
			if(isNullOrEmpty(str))
				return str
			var end:uint=Math.floor(str.length/2);
			var front:String;
			var behind:String;
			for (var i:int = 0; i < end; ++i) 
			{
				front=str.charAt(i);
				behind=str.charAt(str.length-1-i);
				str=replaceStrOnIndex(str,behind,i);
				str=replaceStrOnIndex(str,front,str.length-1-i);
			}
			return str;
		}
		
		/**
		 * 替换字符串指定位置的字符
		 * @param str     要操作的字符串
		 * @param replace     要替换入的字符
		 * @param index        被替换的索引位置
		 * @return                  返回替换过的字符串
		 * @throws Error
		 */
		public static function replaceStrOnIndex(str:String, replace:String, index:uint):String
		{
			if(isNullOrEmpty(str)||isNullOrEmpty(str))
				return str;
			if(index>=str.length||index<0)
			{
				throw new Error("index参数超出允许范围！");
				return null;
			}
			var front:String=str.substring(0,index);
			var behind:String=str.substring(index+1);
			str=front+replace+behind;
			return str;
		}
		/**
		 *根据数组获取下划线字符串 
		 * @param arr
		 * @return 
		 * 
		 */		
		public static function getUnderLineStr(arr:Array):String
		{
			var str:String="";
			for(var i:int=0,len:int=arr.length;i<len;i++)
			{
				str=str.concat(arr[i].toString()+"_");
			}
			return str;
		}

		/**
		 * 缩写字符串方法。只显示value <= limit长度的字符串，超出X长度的字符用…来表示。
		 * @param value:String	要缩写的字符串。
		 * @param limit:int		依据limit的长度来判断字符串需不需要缩写（英文占1个字节，中文占2个字节）。
		 * @param omitStr:String 超出部分替换字符。
		 * @return:String		返回一个长度为你所设置的新字符串。
		 */
		public static function getOmitStrByLimit(value:String, limit:uint, omitStr:String="…"):String
		{
			var news:String = "";
			if (getCharCount(value) > limit)
			{
				for (var i:int = 0;i < value.length;i++)
				{
					var char:String = value.charAt(i);
					if (getCharCount(news + char) <= limit - 2) {
						news += char;
					} else {
						news += omitStr;
						break;
					}
				}
			}
			else news = value;
			return news;
		}

		/**
		 * 获得字符串总字符数，中文算两个字符
		 */
		public static function getCharCount(value:String):uint
		{
			return value.replace(/[^\x00-\xff]/g, "xx").length;
		}
	}
}