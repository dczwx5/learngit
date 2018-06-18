using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code._delegate.mornuiHandler
{
    public delegate void MornHandler(ArrayList args);

    class CMornHandler {
        public CMornHandler(MornHandler callback, ArrayList args = null) {
            m_handler = callback;
            m_args = args;
        }

        public void execute() {
            if (null != m_handler) {
                m_handler(m_args);
            }
        }
        public void executeWith(ArrayList data) {
            if (data == null) {
                execute();
                return;
            }
            if (null != m_handler) {
                ArrayList tempArgs;
                
                if (null != m_args) {
                    tempArgs = (ArrayList)m_args.Clone();
                    for (int i = 0; i < data.Capacity; i++) {
                        tempArgs.Add(data[i]);
                    }
                } else {
                    tempArgs = m_args;
                }
                m_handler(tempArgs);
            }
        }

        private MornHandler m_handler;
        private ArrayList m_args;
    }

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
    }
}
