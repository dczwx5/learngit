using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code._delegate.mornuiHandler
{
    // ================================�첽mornui handler=======================================
    public delegate void ASyncMornHandlerFinish();

    class CAsyncMornHandler : CMornHandler {
        public CAsyncMornHandler(MornHandler callback, ArrayList args = null,
            ASyncMornHandlerFinish onFinish = null) : base(callback, args) {
            m_onFinish = onFinish;
        }
        protected override void Invoke(ArrayList args) {
            if (null != m_handler) {
                IAsyncResult ret = m_handler.BeginInvoke(args, AsyncCallback, null);
                m_handler.EndInvoke(ret);
            }
        }
      
        private void AsyncCallback(IAsyncResult ar) {
            if (m_onFinish != null) {
                m_onFinish.Invoke();
            }
        }
        private ASyncMornHandlerFinish m_onFinish;
    }

    // ================================testʵ��=======================================
    public class CAsyncMornHandlerTest {
        public static void Usage() {
            ArrayList args = new ArrayList();
            args.Add(56);
            CAsyncMornHandler m = new CAsyncMornHandler(testAyncMornFunc, args, testOnFinishAyncMornHandler);
            ArrayList addedArgs = new ArrayList();
            addedArgs.Add(111);
            m.execute(addedArgs);
        }
        private static void testAyncMornFunc(ArrayList args) {
            my.Trace("testAyncMornFunc : call ");
            foreach (Object v in args) {
                my.Trace(v);
            }
        }
        private static void testOnFinishAyncMornHandler() {
            my.Trace("testOnFinishAyncMornHandler : call");
        }
    }

}
