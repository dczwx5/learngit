////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	import flash.text.StyleSheet;

	/**
	 *  
	 * @author lyman
	 * 
	 */	
	public class HtmlUtil
	{
		public function HtmlUtil()
		{
		}
		
		public static function link(msg:String, linkData:String = null):String
		{
			linkData = StringUtil.isNullOrEmpty(linkData) ? "#" : linkData;
			return "<a href='event:" + linkData + "'>" + msg + "</a>";
		}
		
		public static function format(msg:String, color:Number = NaN, size:Number = NaN, font:String = null, isBold:Boolean = false, br:Boolean = false, underLine:Boolean = false):String
		{
			var result:String = "";
			if (!isNaN(color)) result += " color=\"#" + color.toString(16) + "\"";
			if (!isNaN(size)) result += " size=\"" + color.toString(16) + "\"";
			if (!StringUtil.isNullOrEmpty(font)) result += " font=\"" + font + "\"";
			result = "<font" + result + ">" + msg + "</font>";
			if (isBold) result = "<b>" + result + "</b>"
			if (br) result = result + "<br>";
			if (underLine) result = "<u>" + result + "</u>";
			return result;
		}
		
		public static function getHtmlText(str:String,color:String = "#000000",size:uint = 12,face:String = "SimSun",isBold:Boolean = false , br:Boolean = false,underLine:Boolean = false):String
		{
			str = "<font color='" + color + "' size='" + size + "' face='" + face + "'>" + str + "</font>";
			if(isBold)
			{
				str = "<b>" + str + "</b>";
			}
			if(underLine)
			{
				str = "<u>" + str + "</u>";
			}
			if(br)
			{
				str += "<br>";
			}
			
			return str;
		}
		
		public static function getEventTxt(str:String,href:String,color:String = "#FF0000",size:uint = 12,face:String = "SimSun",isBold:Boolean = false , br:Boolean = false,underLine:Boolean = false):String
		{
			return "<a href='event:"+href+"'>" + getHtmlText(str,color,size,face,isBold,br,underLine) + "</a>";
		}
		
		
		public static function color(content:String, theColor:String,isLine:Boolean = false):String
		{
			var str:String = "<font color='" + theColor + "'>" + content + "</font>"
			if(isLine)
			{ 
				return str+"\n";
			}
			return str;
		}
		
		public static function sizeColor(str:String,color:String=null,size:int=0):String
		{
			var result:String="<font ";
			if(size!=0){
				result+="size='"+size+"' ";
			}
			if(color!=null){
				result+="color='"+color+"' ";
			}
			result+=">"+str+"</font>"
			return result;
		}
		
		public static function customColor(content:String, theColor:String):String
		{
			return "&" + theColor + "&" + content;
		}
		
		public static function bold(content:String):String
		{
			return "<b>" + content + "</b>";
		}
		
		public static function br(content:String):String
		{
			return content + "\n";
		}
		
		public static function autoBr(content:String, length:int=15):String
		{
			return content;
		}
		
		public static function removeHtml(content:String , isRemoveSpacing:Boolean = true):String
		{
			var result:String = content.replace(/\<\/?[^\<\>]+\>/gmi, "");
			if( isRemoveSpacing )
			{
				result = result.replace(/[\r\n ]+/g, ""); 
			}
			else
			{
				result = result.replace(/[\r\n]+/g, ""); 
			}
			return result;
		}
		
		/**
		 * 超链接
		 * @param content 内容
		 * @param data 事件传送数据
		 * @param theColor 链接颜色
		 */
		public static function href(content:String,data:String,theColor:String='#FF0000'):String
		{
			var result:String="<font color='"+theColor+"'><a href=\"event:"+data+"\">"+content+"</a></font>";
			return result;
		}
		
		/**
		 * 带下划线的超链接
		 */
		public static function hrefAndU(content:String,data:String,theColor:String='#FF0000'):String
		{
			return "<u>"+href(content,data,theColor)+"</u>";
		}
		
		/**HTML垂直间隔**/
		public static function MakeLeading(content:String,leading:int=5):String
		{
			return "<textformat leading='"+leading+"'>"+content+"</textformat>";
		}
		
		private static var _hrefSheet:StyleSheet;
		/**
		 * 获取超链接Sheet，当鼠标移到该TextFiled时会变成红色
		 * @return 
		 */
		public static function get hrefSheet():StyleSheet
		{
			if(!_hrefSheet){
				_hrefSheet = new StyleSheet();
				_hrefSheet.setStyle("a:hover",{ "color":"#fc3636"});
			}
			return _hrefSheet;
		}
		
		/**
		 * 获取名字是不合规则的提示
		 * @param name  传入的名字
		 * @param tips  提示中用到的术语。。eg.“角色名”、“宠物名”...
		 * @param colorStr
		 * @param minChar 最小字符
		 * @param maxChar 最大字符
		 * @return htmlStr;
		 * 
		 */
		public static function nameTip(name:String,tips:String,colorStr:String,minChar:int = 2,maxChar:int = 12):String
		{
			/*if (name == "")
				return "";
			else if (FilterText.getInstance().validate(name) == true)
			{
				return color(tips + "不能含非法字符",colorStr);
			}
			else
			{
				var pattern:RegExp = /^([\u4e00-\u9fa5]|[A-Za-z0-9])+$/g;				
				if (name.indexOf(" ") != -1 || name.indexOf("　") != -1)
				{
					return color(tips + "不能包含空格字符",colorStr);
				}
				if (!pattern.test(name) == true)
				{
					return color(tips + "只能输入中文,字母,数字",colorStr);
				}
				if (nameLen(name) > maxChar || nameLen(name) < minChar)
				{
					return color(tips + "长度应为" + minChar + "-" + maxChar + "个字符",colorStr);					
				}
				else
				{
					return "";			
				}
			}*/
			return name;
		}
		
		private static function nameLen(str:String):int
		{
			var len:int = 0; 
			for (var i:int = 0; i < str.length; i++)
			{
				if (str.charCodeAt(i) > 255)
					len = len + 2; 
				else
					len = len + 1;
			}
			return len;
		}
		
		/**
		 * 截取指定长度的字符 
		 * @param str  需要截取的字符
		 * @param maxChar 最大的字符数
		 * @return 
		 * 
		 */			
		public static function nameSub(str:String,maxChar:int = 12):String
		{
			str = str.substr(0,maxChar);
			if (nameLen(str) > maxChar)
			{				
				for (var i:int = 0; i < maxChar/2 + 1; i++)
				{
					if (nameLen(str.substr(0,str.length - i)) <= maxChar)
					{
						str = str.substr(0,str.length - i);
						return str;
					}
				}				
			}
			return str;
		}
		
	}
}