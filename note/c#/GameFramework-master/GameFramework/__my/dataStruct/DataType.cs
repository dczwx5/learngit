using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my.dataStruct {
    class DataType {
        // Type == typeof(DataType) == (new DataType()).GetType();
        // Type.Name Type.FullName
        public static void Usage() {
            // typeof(类型) 返回Type对象
            // Type : 类型对象, Name : 类名, FullName : 包含完整命名空间的名字
            Type t = typeof(DataType); 
            my.Trace(t.Name + ", " + t.FullName);
            // 输出 Name : DataType
            // 输出 FullName : code.dataStruct.DataType

            DataType dt = new DataType();
            Type typeOfDT = dt.GetType();
            my.Trace(typeOfDT.FullName);

        }
    }

    
}
