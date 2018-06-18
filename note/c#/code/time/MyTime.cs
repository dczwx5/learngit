using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code.time {
    class MyTime {
        public static string GetCurTimeStamp() {
            DateTime currentTime = System.DateTime.Now;
            return GetTimeStamp(currentTime);
        }
        public static long GetCurTimeStampToLong() {
            DateTime currentTime = System.DateTime.Now;
            return ConvertDateTimeToInt(currentTime);
        }
        /// 获取时间戳
        /// </summary>
        /// <returns></returns>
        public static string GetTimeStamp(System.DateTime time) {
            long ts = ConvertDateTimeToInt(time);
            return ts.ToString();
        }
        /// <summary>  
        /// 将c# DateTime时间格式转换为Unix时间戳格式  
        /// </summary>  
        /// <param name="time">时间</param>  
        /// <returns>long</returns>  
        public static long ConvertDateTimeToInt(System.DateTime time) {
            System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1, 0, 0, 0, 0));
            long t = (time.Ticks - startTime.Ticks) / 10000;   //除10000调整为13位      
            return t;
        }

    }
}
/**
－－DateTime 数字型

System.DateTime currentTime = new System.DateTime();

1.1 取当前年月日时分秒
    currentTime = System.DateTime.Now;

1.2 取当前年
    int 年 = currentTime.Year;

1.3 取当前月
    int 月 = currentTime.Month;

1.4 取当前日
    int 日 = currentTime.Day;

1.5 取当前时
    int 时 = currentTime.Hour;

1.6 取当前分
    int 分 = currentTime.Minute;

1.7 取当前秒
    int 秒 = currentTime.Second;

1.8 取当前毫秒
    int 毫秒 = currentTime.Millisecond;

（变量可用中文）

1.9 取中文日期显示_年月日时分
    string strY = currentTime.ToString("f"); //不显示秒

1.10 取中文日期显示_年月
    string strYM = currentTime.ToString("y");

1.11 取中文日期显示_月日
    string strMD = currentTime.ToString("m");

1.12 取当前年月日，格式为：2003-9-23
    string strYMD = currentTime.ToString("d");

1.13 取当前时分，格式为：14:24
    string strT = currentTime.ToString("t");

//今天
DateTime.Now.Date.ToShortDateString();

//昨天，就是今天的日期减一
    DateTime.Now.AddDays(-1).ToShortDateString();

//明天，同理，加一
DateTime.Now.AddDays(1).ToShortDateString();

//本周，要知道本周的第一天就得先知道今天是星期几，从而得知本周的第一天就是几天前的那一天，要注意的是这里的每一周是从周日始至周六止
DateTime.Now.AddDays(Convert.ToDouble((0 - Convert.ToInt16(DateTime.Now.DayOfWeek)))).ToShortDateString();
DateTime.Now.AddDays(Convert.ToDouble((6 - Convert.ToInt16(DateTime.Now.DayOfWeek)))).ToShortDateString();

//如果你还不明白，再看一下中文显示星期几的方法就应该懂了
//由于DayOfWeek返回的是数字的星期几，我们要把它转换成汉字方便我们阅读，有些人可能会用switch来一个一个地对照，其实不用那么麻烦的
string[] Day = new string[] { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" };
Day[Convert.ToInt16(DateTime.Now.DayOfWeek)];

//上周，同理，一个周是7天，上周就是本周再减去7天，下周也是一样
    DateTime.Now.AddDays(Convert.ToDouble((0 - Convert.ToInt16(DateTime.Now.DayOfWeek))) - 7).ToShortDateString();
DateTime.Now.AddDays(Convert.ToDouble((6 - Convert.ToInt16(DateTime.Now.DayOfWeek))) - 7).ToShortDateString();

//下周
DateTime.Now.AddDays(Convert.ToDouble((0 - Convert.ToInt16(DateTime.Now.DayOfWeek))) + 7).ToShortDateString();
DateTime.Now.AddDays(Convert.ToDouble((6 - Convert.ToInt16(DateTime.Now.DayOfWeek))) + 7).ToShortDateString();

//本月，很多人都会说本月的第一天嘛肯定是1号，最后一天就是下个月一号再减一天。当然这是对的
DateTime.Now.Year.ToString() + DateTime.Now.Month.ToString() + "1"; //第一天
    DateTime.Parse(DateTime.Now.Year.ToString() + DateTime.Now.Month.ToString() + "1").AddMonths(1).AddDays(-1).ToShortDateString();//最后一天
    */