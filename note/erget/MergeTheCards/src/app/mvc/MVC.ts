namespace App{

    export class MVC extends VoyaMVC.MVC{

        public startup() {
            this.configureModuls();
            this.core.sendMsg(create(StartupMsg.Startup));
        }

        private configureModuls(){
            this.configure([
                new TestModuleCfg(),
                new SystemModuleMvcCfg(),
                new MainModuleCfg(),
                new BattleModuleCfg(),
                new HelpModuleMvcCfg()
            ]);
        }
    }
}
