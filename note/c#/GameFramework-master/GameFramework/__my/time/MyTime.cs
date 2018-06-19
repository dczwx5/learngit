using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my.time {
    class MyTime {
        public static string GetCurTimeStamp() {
            DateTime currentTime = System.DateTime.Now;
            return GetTimeStamp(currentTime);
        }
        public static long GetCurTimeStampToLong() {
            DateTime currentTime = System.DateTime.Now;
            return ConvertDateTimeToInt(currentTime);
        }
        /// <summary>  
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
