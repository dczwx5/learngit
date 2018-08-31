
namespace Core {
    public class CAppSystem : CBean {

        public T AddComponent<T>() where T : CBean {
            T comp = gameObject.AddComponent<T>();
            comp.system = this;
            return comp;
        }
        public T RemoveComponent<T>() where T : CBean {
            T comp = gameObject.GetComponentInChildren<T>();
            if (null != comp) {
                Destroy(comp);
            }
            return comp;
        }

        public CAppStage stage {
            get;
            set;
        }


        private void OnDestroy() {

        }
    }

}
