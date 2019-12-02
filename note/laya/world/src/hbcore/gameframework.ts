import { fsm as FSM } from "./framework/Fsm";
import { config as CONFIG } from "./framework/config";
import { framework as FRAMEWORK } from "./framework/FrameWork";
import { log as LOG } from "./framework/log";
import { pool as POOL } from "./framework/pool";
import { procedure as PROCEDURE } from "./framework/Procedure";
import { sequential as SEQUENTIAL } from "./framework/sequential";
import { sound as SOUND } from "./framework/sound";
import Lang from "./framework/Lang";
import { mvc as MVC } from "./framework/pattern/mvc";
import { facade as FACADE } from "./framework/pattern/facade";
import { strategy as STRATEGY } from "./framework/pattern/strategy";

export module gameframework {
    export let fsm = FSM;
    export let config = CONFIG;
    export let framework = FRAMEWORK;
    export let log = LOG;
    export let pool = POOL;
    export let procedure = PROCEDURE;
    export let sequential = SEQUENTIAL;
    export let sound = SOUND;
    export let lang = Lang;
    export let pattern = {mvc:MVC, facade:FACADE, strategy:STRATEGY};  
}
