using __my.time;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my {
    class my {
        public static void Trace(Object v) {
            System.Console.WriteLine(v);

        }
        public static void TraceCurrentTime(Object v = null) {
            if (null != v) {
                Trace(v + " - " + MyTime.GetCurTimeStamp());
            }
            else {
                Trace(MyTime.GetCurTimeStamp());
            }
        }
        public static String ReadLine() {
            return System.Console.ReadLine();
        }
    }
}
