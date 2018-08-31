using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Core {
    public class CAppStage : CBean {

        public T AddSystem<T>() where T : CAppSystem {
            T system = gameObject.AddComponent<T>();
            system.stage = this;
            return system;
        }

        public T GetSystem<T>() where T : CAppSystem {
            T system = gameObject.GetComponentInParent<T>();
            return system;
        }
    }

}
