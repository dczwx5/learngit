using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my.sync {
    public delegate void SyncHandler();
    class MySync {
        public MySync() {
            Testc();
        }
         
        private void Testc() {
            SyncHandler handler = DoSomething;
            AsyncCallback callback = SyncCallbackHandler;
            IAsyncResult ret = handler.BeginInvoke(callback, this);
            handler.EndInvoke(ret);

            my.TraceCurrentTime("finish");
        }
        public void SyncCallbackHandler(IAsyncResult ar) {
            my.TraceCurrentTime("SyncCallbackHandler");

        }

        private void DoSomething() {
            int count = 0;

            while (true) {
                System.Threading.Thread.Sleep(100);
                count++;
                my.TraceCurrentTime("DoSomething : " + count);
                if (count > 10) {
                    break;
                }
            }
            
        }
    }
}
