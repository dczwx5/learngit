using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code._delegate.mornuiHandler
{
    // ===============================mornui Handler实现===================================
    public delegate void MornHandler(ArrayList args);

    public class CMornHandler {
        public CMornHandler(MornHandler callback, ArrayList args = null) {
            m_handler = callback;
            m_args = args;
        }

        public void execute() {
            Invoke(m_args);
        }
        public void execute(ArrayList data) {
            if (data == null) {
                execute();
                return;
            }
            if (null != m_handler) {
                ArrayList tempArgs;
                
                if (null != m_args) {
                    tempArgs = (ArrayList)m_args.Clone();
                    for (int i = 0; i < data.Count; i++) {
                        tempArgs.Add(data[i]);
                    }
                } else {
                    tempArgs = m_args;
                }
                Invoke(tempArgs);
            }
        }

        protected virtual void Invoke(ArrayList args) {
            if (null != m_handler) {
                m_handler.Invoke(args);
            }
        }

        protected MornHandler m_handler;
        protected ArrayList m_args;
    }

    // ==================================使用实例==================================================

    public class CMornHandlerUsage {
        public static void Usage() {
            ArrayList args = new ArrayList();
            args.Add(5);
            CMornHandler mornHandler = new CMornHandler(Callback, args);
            mornHandler.execute();

        }
        public static void Callback(ArrayList args) {
            my.Trace("Callback");
        }

    }

    /**
    // imimimimimim
    public class CMornEevenHandlerArgs {
        private Object m_owner;
        private Object m_data;
        private Object m_userArgs;

        public Object owner {
            get {
                return m_owner;
            }
            private set {

            }
        }
        public Object data {
            get {
                return m_data;
            }
            private set {

            }
        }
        public Object userArgs {
            get {
                return m_userArgs;
            }
            private set {

            }
        }
    }*/
}
