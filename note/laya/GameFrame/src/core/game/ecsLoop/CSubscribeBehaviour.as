 
 package core.game.ecsLoop
 {
    import core.framework.IUpdate;
    
    public class CSubscribeBehaviour extends CGameComponent implements IUpdate {
        public function CSubscribeBehaviour(name:String, branchData:Boolean = false) {
            super(name, branchData);
        }

        public virtual function update(delta:Number) : void {

        }
    }   
 }