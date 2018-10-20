//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.fsm {


/**
 * Finite State Machine.
 *
 * @see https://github.com/jakesgordon/javascript-state-machine
 * @author Jeremy
 */
public class CDynamicFiniteStateMachine {

    /** @private */
    public static const VERSION:String = "2.3.3";

    public static const Result:Object = {
        SUCCEEDED: 1,
        NO_TRANSITION: 2,
        CANCELLED: 3,
        PENDING: 4
    };

    public static const Error:Object = {
        INVALID_TRANSITION: 100,
        PENDING_TRANSITION: 200,
        INVALID_CALLBACK: 300
    };

    public static var WILDCARD:String = "*";
    public static var ASYNC:String = "async";

    private static function doCallback(fsm:CDynamicFiniteStateMachine, func:Function, name:String, from:String, to:String, args:Array):* {
        if (null != func) {
            try {
                return func.apply(fsm, [name, from, to].concat(args));
            } catch (e:*) {
                return fsm.m_listStates.error(name, from, to, args, CDynamicFiniteStateMachine.Error.INVALID_CALLBACK,
                        "an exception occurred in a caller-provided callback function", e);
            }
        }
    }

    public static function beforeAnyEvent(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onBeforeEvent'], name, from, to, args);
    }

    public static function afterAnyEvent(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onAfterEvent'], name, from, to, args);
    }

    public static function leaveAnyState(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onLeaveState'], name, from, to, args);
    }

    public static function enterAnyState(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onEnterState'], name, from, to, args);
    }

    public static function changeState(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onChangeState'], name, from, to, args);
    }

    public static function beforeThisEvent(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onBefore'], name, from, to, args);
    }

    public static function afterThisEvent(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onAfter'], name, from, to, args);
    }

    public static function leaveThisEvent(fsm:CDynamicFiniteStateMachine, name:String, from:String, to:String, args:Array):* {
        return CDynamicFiniteStateMachine.doCallback(fsm, fsm['onLeave'], name, from, to, args);
    }

    public static function buildEvent(name:String, map:Object):void {

    }

    // cfg.initial
    private var m_initial:Object;
    // cfg.final
    private var m_terminal:Object;
    // cfg.events
    private var m_listEvents:Array;
    // internal states.
    private var m_listStates:Object;
    // cfg.callbacks
    private var m_mapCallbacks:Object;
    // map
    private var m_map:Object;
    // cfg
    private var m_cfg:Object;
    // Transition flag.
    private var m_bTransition:Boolean;

    /** Constructor */
    public function CDynamicFiniteStateMachine(cfg:Object) {
        this.m_cfg = cfg;
        init();
    }

    protected function init():void {
        // allow for a simple string, or an object with { state: 'foo', event: 'setup', defer: true|false }
        this.m_initial = (m_cfg.initial is String) ? {state: m_cfg.initial} : m_cfg.initial;
        this.m_terminal = m_cfg.terminal || m_cfg['final'];
        this.m_listEvents = m_cfg.events || [];
        this.m_listStates = m_listStates || {};
        this.m_mapCallbacks = m_cfg.callbacks || {};
        this.m_map = {};

        if (this.m_initial) {
            m_initial.event = m_initial.event || 'startup';
            add({
                name: m_initial.event,
                from: 'none',
                to: m_initial.state
            });
        }

        for (var n:int = 0; n < m_listEvents.length; ++n) {
            add(m_listEvents[n]);
        }

        var name:String;
        for (name in m_map) {
            if (m_map.hasOwnProperty(name))
                m_listStates[name] = CDynamicFiniteStateMachine.buildEvent(name, m_map[name]);
        }

        for (name in m_mapCallbacks) {
            if (m_mapCallbacks.hasOwnProperty(name))
                m_listStates[name] = m_mapCallbacks[name];
        }

        m_listStates.current = 'none';
        m_listStates.error = m_cfg.error || function (name:String, from:String, to:String, args:Array, error:String, msg:String, e:*):void {
            throw e || msg;
        };

        // default behavior when something unexpected happens is to throw an exception, but caller can override this behavior if desired ( see github issue #3 and #17 )

        if (m_initial && !m_initial.defer)
            m_listStates[m_initial.event]();
    }

    private function add(e:Object):void {
        // allow 'wildcard' transition if 'from' it not specified
        var from:Array = (e.from is Array) ? e.from : (e.from ? [e.from] : [CDynamicFiniteStateMachine.WILDCARD]);
        m_map[e.name] = m_map[e.name] || {};
        for (var n:int = 0; n < from.length; ++n) {
            m_map[e.name][from[n]] = e.to || from[n]; // allow no-op transition if 'to' is not specified
        }
    }

    [Inline]
    final public function isCurrent(state:*):Boolean {
        return (state is Array) ? (state.indexOf(m_listStates.current) >= 0) : (m_listStates.current == state);
    }

    [Inline]
    final public function can(event:String):Boolean {
        return !this.m_bTransition && (m_map[event].hasOwnProperty(m_listStates.current) || m_map[event].hasOwnProperty(CDynamicFiniteStateMachine.WILDCARD));
    }

    [Inline]
    final public function get finished():Boolean {
        return this['isCurrent'](m_terminal);
    }

}
}
