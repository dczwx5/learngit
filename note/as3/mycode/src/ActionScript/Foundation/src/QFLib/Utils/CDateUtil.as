//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * 日期工具类
 */
package QFLib.Utils
{

    import QFLib.Foundation.CTime;

    public class CDateUtil
	{
		public static const TimeZone:int = 8;// 时区(东八区)

		public function CDateUtil()
		{
		}
		
		/**
		 *获取经过的总天数。距离 1970 年 1 月 1 日 
		 * @param date
		 * @return 
		 * 
		 */		
		public static function getTotalDays(date:Date):int
		{
			if (date == null) 
			{
				return 0;
			}

			return int(( date.time + TimeZone * 60 * 60 * 1000 ) / (24 * 60 * 60 * 1000));
		}
		
		/**
		 * 是否同一天 
		 * @param date1
		 * @param date2
		 * 
		 */		
		public static function isSameDay(date1:Date,date2:Date):Boolean
		{
			return date1.fullYear == date2.fullYear 
				&& date1.month == date2.month
				&& date1.date == date2.date
		}
		
		/**
		 * 获取日期差 
		 * @param fromDate
		 * @param toDate
		 * 
		 */		
		public static function getDayDis(fromDate:Date,toDate:Date):int
		{
			var fromDay:int = getTotalDays(fromDate);
			var toDay:int = getTotalDays(toDate);
			return toDay - fromDay;
		}
		
		/**
		 *当前日期是否在指定时间内
		 * @param startDt
		 * @param endDt
		 * @return 
		 * 
		 */		
		public static function isInDate(startDt:Date,endDt:Date):Boolean
		{
//            var currTime:Number = CTime.getCurrentTimestamp();
            var currTime:Number = CTime.getCurrServerTimestamp();
			if(startDt && endDt && currTime >= startDt.time && currTime < endDt.time)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * 获取相差多少秒， date2 - date1 
		 * @param date1
		 * @param date2
		 * @param isChangeToZero
		 * @return 
		 * 
		 */		
		public static function getSecondsDis(date1:Date, date2:Date, isChangeToZero:Boolean=false):int
		{
			var res:int = (date2.time - date1.time) * 0.001;
			if(isChangeToZero && res < 0)
			{
				res = 0;
			}
			return res;
		}
		
		/**
		 * 返回日期 
		 * 14:00:00（ 格式 ）
		 * @return 
		 * 
		 */		
		public static function getDateByHourAndMin( value:String ):Date
		{
            var nowDate:Date = new Date(CTime.getCurrentTimestamp());
			var time:Array = value.split(":");
			if( time.length == 3 )
			{
				return new Date( nowDate.fullYear, nowDate.month, nowDate.date, Number( time[ 0 ] ), Number( time[ 1 ] ), Number( time[ 2 ] ));
			}
			return new Date( nowDate.fullYear, nowDate.month, nowDate.date, Number( time[ 0 ] ), Number( time[ 1 ] ) );
		}
		
		/**
		 * 返回日期 
		 * 2020-01-21 23:59:59.000（ 格式 ）
		 * @return 
		 * 
		 */		
		public static function getDateByFullTimeString( value:String ):Date
		{
			var valArr:Array = value.split(" ");
			var reg:RegExp = /\s/g;
			var fontStr:String = valArr[0].replace(reg,"");
			var backStr:String = valArr[1].replace(reg,"");
			var fontArr:Array = fontStr.split("-");
			var backArr:Array = backStr.split(":");
			
			var year:int = int(fontArr[0]);
			var mon:int = int(fontArr[1])-1;
			var day:int = int(fontArr[2]);
			
			var hh:int = int(backArr[0]);
			var mm:int = int(backArr[1]);
			
			var secArr:Array = backArr[2].split(".");
			var ss:int = int(secArr[0]);
			var mss:int = int(secArr[1]);
			
			return new Date(year,mon,day,hh,mm,ss,mss);
		}

        /**
         * 返回日期
         * 2020-01-21（ 格式 ）
         * @return
         *
         */
        public static function getDateByShortTimeString( value:String ):Date
        {
            var reg:RegExp = /\s/g;
            var dateStr:String = value.replace(reg,"");
            var strArr:Array = dateStr.split("-");

            var year:int = int(strArr[0]);
            var mon:int = int(strArr[1]) - 1;
            var day:int = int(strArr[2]);

            return new Date(year,mon,day);
        }
		
		/**
		 * 把时间日期解析成字符串类型(格式：年-月-日 hh:mm:ss)
		 */	
		public static function getStrTimeByDate(date:Date):String
		{
			var str:String = date.fullYear + "-" + (date.month+1) + "-" + date.date + " " + date.hours + ":" + date.minutes + ":" + date.seconds;
			return str;
		}
		
		/**
		 * 复制一个日期
		 */		
		public static function getDateClone(date:Date):Date
		{
			var newDate:Date = new Date(date.fullYear,date.month,date.date,date.hours,date.minutes,date.seconds);
			return newDate;
		}
		
		/**
		 * 设置某个日期0点
		 */		
		public static function setZeroDate(date:Date):void
		{
			date.hours = 0;
			date.minutes = 0;
			date.seconds = 0;
			date.milliseconds = 0;
		}
	}
}