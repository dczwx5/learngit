using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
namespace __my {
    public class DelegateEventData {
        public DelegateEventData(Object rOwner, String rType, Object rData) {
            owner = rOwner;
            type = rType;
            data = rData;
        }
        public Object owner;
        public String type;
        public Object data;
    }
}
