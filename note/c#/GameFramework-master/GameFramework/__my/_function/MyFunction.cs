using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace __my._function {
    class MyFunction {
        public static void Usage() {
            new MyFunction().TestFunc1("a", "b");
        }

        public void TestFunc1(params string[] args) {
            if (args != null) {
                string str = string.Empty;
                for (int i = 0; i < args.Length; i++) {
                    str += args[i] + ", ";
                }
                
                __my.my.Trace(str);
            } 
        }
    }
}
